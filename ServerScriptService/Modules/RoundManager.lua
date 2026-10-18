-- ServerScriptService/Modules/RoundManager.lua
local RoundManager = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")

local EVT_RoundState = ReplicatedStorage:WaitForChild("EVT_RoundState")
local REQ_SpawnRequest = ReplicatedStorage:FindFirstChild("REQ_SpawnRequest")

-- Config
RoundManager.roundTime = 115
RoundManager.buyTime = 15
RoundManager.freezeTime = 5
RoundManager.state = "waiting" -- waiting, freeze, buy, live, round_end
RoundManager.roundNumber = 0
RoundManager.teamScores = {T = 0, CT = 0}

-- Utility: gather spawn points (maps should provide SpawnLocation named Team_T_Spawn or Team_CT_Spawn)
local function getSpawnsForTeam(teamName)
    local spawns = {}
    local map = workspace:FindFirstChild("Map")
    if not map then return spawns end
    for _, v in pairs(map:GetDescendants()) do
        if v:IsA("SpawnLocation") and v.Name:match(teamName) then
            table.insert(spawns, v)
        end
    end
    return spawns
end

local function spawnPlayerAtTeam(player, teamName)
    if not player.Character or not player.Character.Parent then
        -- ensure character spawns
        player:LoadCharacter()
    end
    local spawns = getSpawnsForTeam(teamName)
    if #spawns == 0 then return end
    local idx = math.random(1, #spawns)
    local spawn = spawns[idx]
    if player.Character and player.Character.PrimaryPart then
        player.Character:SetPrimaryPartCFrame(spawn.CFrame + Vector3.new(0,3,0))
    else
        player.CharacterAdded:Wait()
        player.Character:WaitForChild("HumanoidRootPart").CFrame = spawn.CFrame + Vector3.new(0,3,0)
    end
end

function RoundManager:AssignTeams()
    -- simple balancing: alternate assign
    local all = Players:GetPlayers()
    for i, p in ipairs(all) do
        if i % 2 == 0 then
            p.Team = Teams:FindFirstChild("CT") or p.Team
        else
            p.Team = Teams:FindFirstChild("T") or p.Team
        end
    end
end

function RoundManager:StartRound()
    self.roundNumber = self.roundNumber + 1
    self.state = "freeze"
    local time = self.freezeTime
    EVT_RoundState:FireAllClients({state = "freeze", round = self.roundNumber, time = time})

    -- Freeze time: players cannot move (optional) then buy time
    spawn(function()
        wait(self.freezeTime)
        self.state = "buy"
        EVT_RoundState:FireAllClients({state = "buy", time = self.buyTime})
        wait(self.buyTime)
        self.state = "live"
        EVT_RoundState:FireAllClients({state = "live", time = self.roundTime})

        -- Respawn/reset players and set money as needed
        for _, p in pairs(Players:GetPlayers()) do
            -- spawn according to team
            if p.Team and p.Team.Name == "CT" then
                spawnPlayerAtTeam(p, "CT")
            else
                spawnPlayerAtTeam(p, "T")
            end
            -- reset health, ammo, etc.
            if p.Character and p.Character:FindFirstChildOfClass("Humanoid") then
                p.Character:FindFirstChildOfClass("Humanoid").Health = p.Character:FindFirstChildOfClass("Humanoid").MaxHealth
            end
        end

        local t = self.roundTime
        while t > 0 and self.state == "live" do
            wait(1)
            t = t - 1
            -- simple time expiration check
            if t <= 0 then
                -- time out: CT wins if bomb not planted
                self:EndRound("CT", "time")
            end
        end
    end)
end

function RoundManager:EndRound(winner, reason)
    self.state = "round_end"
    if winner and self.teamScores[winner] ~= nil then
        self.teamScores[winner] = self.teamScores[winner] + 1
    end
    EVT_RoundState:FireAllClients({state = "end", winner = winner, reason = reason})
    -- reward money (simple implementation)
    for _, p in pairs(Players:GetPlayers()) do
        local cur = p:GetAttribute("Money") or 0
        if p.Team and p.Team.Name == winner then
            p:SetAttribute("Money", cur + 3250)
        else
            p:SetAttribute("Money", cur + 1400)
        end
    end
    -- prepare next round after short wait
    spawn(function()
        wait(6)
        self.state = "waiting"
        self:StartRound()
    end)
end

return RoundManager
