-- ServerScriptService/ServerWeaponHandler.lua
-- Receives fire requests from clients, validates, uses HitRewind for lag compensation, and applies damage.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local REQ_Fire = ReplicatedStorage:WaitForChild("REQ_FireWeapon")
local EVT_PlayerHit = ReplicatedStorage:FindFirstChild("EVT_PlayerHit")
local EVT_PlayerKilled = ReplicatedStorage:FindFirstChild("EVT_PlayerKilled")

local HitRewind = require(script.Parent.Modules:WaitForChild("HitRewind"))
local WeaponConfig = require(ReplicatedStorage:WaitForChild("Configs"):WaitForChild("WeaponConfig"))

local function validateRequest(player, payload)
    if not payload or type(payload) ~= "table" then return false end
    if not payload.weaponId or not WeaponConfig[payload.weaponId] then return false end
    -- Add rate limiting, ammo checks, and basic sanity checks
    return true
end

REQ_Fire.OnServerEvent:Connect(function(player, payload)
    if not validateRequest(player, payload) then return end
    local weaponId = payload.weaponId
    local cfg = WeaponConfig[weaponId]
    local origin = Vector3.new(unpack(payload.origin))
    local dir = Vector3.new(unpack(payload.direction))
    local maxDist = cfg.range or 400

    -- Use client's timestamp for rewind if provided
    local shootTime = payload.timestamp or tick()

    local hit = HitRewind:RaycastWithRewind(player.UserId, origin, dir.Unit, maxDist)
    if hit then
        local targetPlayer = hit.player
        local dmg = cfg.damage or 20
        if hit.part == "Head" then dmg = dmg * (cfg.headMult or 2.0) end
        local char = targetPlayer.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                humanoid:TakeDamage(dmg)
                if EVT_PlayerHit then
                    EVT_PlayerHit:FireClient(targetPlayer, {from = player.Name, dmg = dmg})
                end
                if humanoid.Health - dmg <= 0 then
                    if EVT_PlayerKilled then
                        EVT_PlayerKilled:FireAllClients({killer = player.Name, victim = targetPlayer.Name})
                    end
                end
            end
        end
    end
end)
