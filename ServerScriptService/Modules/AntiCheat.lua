-- ServerScriptService/Modules/AntiCheat.lua
-- Basic anti-cheat checks: rate-limiting per-player weapon fire and movement sanity.

local AntiCheat = {}
local Players = game:GetService("Players")

-- simple rate limiter table: [player.UserId] = {lastShotTime = number, shotsInWindow = int}
local rateData = {}
local SHOT_WINDOW = 1 -- seconds
local MAX_SHOTS_PER_WINDOW = 30 -- adjust per weapon; this is a coarse check

function AntiCheat:CheckFireRate(player)
    local now = tick()
    rateData[player.UserId] = rateData[player.UserId] or {lastWindow = now, shots = 0}
    local d = rateData[player.UserId]
    if now - d.lastWindow <= SHOT_WINDOW then
        d.shots = d.shots + 1
        if d.shots > MAX_SHOTS_PER_WINDOW then
            -- suspicious: too many shots
            return false, "rate_exceeded"
        end
    else
        d.lastWindow = now
        d.shots = 1
    end
    return true
end

-- Movement sanity: check for excessive speed (very coarse)
function AntiCheat:CheckMovement(player)
    local char = player.Character
    if not char or not char.PrimaryPart then return true end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local speed = humanoid.WalkSpeed
        if speed > 50 then -- arbitrary large value; tune per game
            return false, "speed_hack"
        end
    end
    return true
end

return AntiCheat
