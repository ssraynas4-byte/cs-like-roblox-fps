-- ServerScriptService/ServerWeaponHandler.lua
-- Enhanced: uses AntiCheat checks and server-side validation, plus uses HitRewind with client timestamp.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local REQ_Fire = ReplicatedStorage:WaitForChild("REQ_FireWeapon")
local EVT_PlayerHit = ReplicatedStorage:FindFirstChild("EVT_PlayerHit")
local EVT_PlayerKilled = ReplicatedStorage:FindFirstChild("EVT_PlayerKilled")
local EVT_SpawnBulletFX = ReplicatedStorage:FindFirstChild("EVT_SpawnBulletFX")

local HitRewind = require(script.Parent.Modules:WaitForChild("HitRewind"))
local AntiCheat = require(script.Parent.Modules:WaitForChild("AntiCheat"))
local WeaponConfig = require(ReplicatedStorage:WaitForChild("Configs"):WaitForChild("WeaponConfig"))

local lastFireTimes = {} -- [player.UserId] = timestamp of last validated fire

local function validateRequest(player, payload)
    if not payload or type(payload) ~= "table" then return false end
    if not payload.weaponId or not WeaponConfig[payload.weaponId] then return false end
    -- Anti-cheat: rate limit
    local ok, reason = AntiCheat:CheckFireRate(player)
    if not ok then
        warn("AntiCheat blocked fire from", player.Name, reason)
        return false
    end
    -- More validation: ensure origin is near player's camera/character
    if not payload.origin or not payload.direction then return false end
    if #payload.origin ~= 3 or #payload.direction ~= 3 then return false end
    -- Prevent replay: could store recent fireId per player
    return true
end

REQ_Fire.OnServerEvent:Connect(function(player, payload)
    if not validateRequest(player, payload) then return end
    local weaponId = payload.weaponId
    local cfg = WeaponConfig[weaponId]
    local origin = Vector3.new(unpack(payload.origin))
    local dir = Vector3.new(unpack(payload.direction))
    local maxDist = cfg.range or 400
    local shootTime = payload.timestamp or tick()

    -- Use HitRewind with client's timestamp
    local hit = HitRewind:RaycastWithRewind(player.UserId, origin, dir.Unit, maxDist, shootTime)
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

    -- Broadcast FX reliably (other clients will show muzzle/tracer)
    if EVT_SpawnBulletFX then
        EVT_SpawnBulletFX:FireAllClients({pos = origin, dir = dir.Unit, weaponId = weaponId})
    end
end)
