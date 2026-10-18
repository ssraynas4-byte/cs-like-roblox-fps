-- ServerScriptService/Modules/Grenades.lua
local Grenades = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EVT_PlayerHit = ReplicatedStorage:FindFirstChild("EVT_PlayerHit")

function Grenades:ThrowHE(position, blastRadius, damage)
    blastRadius = blastRadius or 10
    damage = damage or 80
    -- naive server authoritative explosion after short fuse
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and p.Character.PrimaryPart then
            local dist = (p.Character.PrimaryPart.Position - position).Magnitude
            if dist <= blastRadius then
                local humanoid = p.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    local dmg = math.floor(damage * (1 - dist / blastRadius))
                    humanoid:TakeDamage(dmg)
                    EVT_PlayerHit and EVT_PlayerHit:FireClient(p, {from = "grenade", dmg = dmg})
                end
            end
        end
    end
end

function Grenades:ThrowFlash(position, radius, maxBlind)
    radius = radius or 8
    maxBlind = maxBlind or 5
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and p.Character.PrimaryPart then
            local dist = (p.Character.PrimaryPart.Position - position).Magnitude
            if dist <= radius then
                local blind = math.clamp(maxBlind * (1 - dist / radius), 0, maxBlind)
                -- send blind info to client (EVT_PlayerHit can be reused with type)
                local evt = ReplicatedStorage:FindFirstChild("EVT_PlayerFlash")
                if evt then evt:FireClient(p, {duration = blind}) end
            end
        end
    end
end

function Grenades:ThrowSmoke(position, radius, duration)
    -- spawn smoke event for clients to render (clients may use particle volume)
    local evt = ReplicatedStorage:FindFirstChild("EVT_SmokeSpawn")
    if evt then evt:FireAllClients({pos = position, radius = radius, duration = duration}) end
end

return Grenades
