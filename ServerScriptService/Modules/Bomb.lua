-- ServerScriptService/Modules/Bomb.lua
local Bomb = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EVT_BombPlanted = ReplicatedStorage:FindFirstChild("EVT_BombPlanted")
local Players = game:GetService("Players")

Bomb.plantTime = 3.5
Bomb.defuseTime = 10
Bomb.plantSites = {A = CFrame.new(0,0,0), B = CFrame.new(0,0,0)} -- placeholder
Bomb.isPlanted = false
Bomb.plantOwner = nil
Bomb.timeLeft = 0

function Bomb:RequestPlant(player, siteName)
    -- validate near site and has bomb (adapter required). Here we assume valid.
    if self.isPlanted then return false, "already_planted" end
    -- start planting
    local start = tick()
    local interrupted = false
    local duration = self.plantTime
    -- simple loop to allow interruption (damage or move checks should be implemented)
    for i = 1, math.ceil(duration/0.1) do
        wait(0.1)
        -- check if player still exists and near site (not implemented fully)
        if not player or not player.Character then interrupted = true; break end
    end
    if interrupted then return false, "interrupted" end
    -- plant successful
    self.isPlanted = true
    self.plantOwner = player
    self.timeLeft = 40
    if EVT_BombPlanted then EVT_BombPlanted:FireAllClients({site = siteName, time = self.timeLeft}) end
    spawn(function()
        while self.timeLeft > 0 and self.isPlanted do
            wait(1)
            self.timeLeft = self.timeLeft - 1
        end
        if self.isPlanted and self.timeLeft <= 0 then
            -- detonate: simple effect
            -- apply area damage
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChildOfClass("Humanoid") then
                    -- naive damage: if within 20 studs
                    local hrp = p.Character.PrimaryPart
                    if hrp and (hrp.Position - self.plantOwner.Character.PrimaryPart.Position).Magnitude < 20 then
                        p.Character:FindFirstChildOfClass("Humanoid"):TakeDamage(100)
                    end
                end
            end
            -- round end
            local RoundManager = require(script.Parent:WaitForChild("RoundManager"))
            RoundManager:EndRound("T", "bomb_exploded")
            self.isPlanted = false
        end
    end)
    return true
end

function Bomb:RequestDefuse(player)
    if not self.isPlanted then return false, "not_planted" end
    -- defuse loop
    local kits = player:GetAttribute("HasDefuseKit")
    local defuseTime = kits and 5 or self.defuseTime
    for i = 1, math.ceil(defuseTime/0.1) do
        wait(0.1)
        -- interrupt checks should be done here
    end
    if self.isPlanted then
        -- defuse succeed
        self.isPlanted = false
        -- notify clients
        ReplicatedStorage:FindFirstChild("EVT_BombDefused") and ReplicatedStorage:FindFirstChild("EVT_BombDefused"):FireAllClients({by = player.Name})
        local RoundManager = require(script.Parent:WaitForChild("RoundManager"))
        RoundManager:EndRound("CT", "defuse")
        return true
    end
    return false
end

return Bomb
