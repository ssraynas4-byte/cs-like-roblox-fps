-- ServerScriptService/Modules/HitRewind.lua
-- Improved HitRewind: keeps per-player sampled transforms and supports timestamp-based interpolation.
-- Uses capsule-like hit checks for better accuracy. Production should replace simple checks with OBB/capsule vs ray intersection.

local HitRewind = {}
HitRewind.BufferDuration = 1.5 -- seconds
HitRewind.SampleRate = 60 -- samples per second (higher for better accuracy)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- history[userId] = { {t=timestamp, hrpCFrame=CFrame, headPos=Vector3, rootPos=Vector3}, ... }
local history = {}

-- Sampling loop
do
    local acc = 0
    RunService.Heartbeat:Connect(function(dt)
        acc = acc + dt
        if acc < 1/HitRewind.SampleRate then return end
        acc = 0
        local now = tick()
        for _, player in pairs(Players:GetPlayers()) do
            local char = player.Character
            if char and char.PrimaryPart then
                history[player.UserId] = history[player.UserId] or {}
                local entry = {
                    t = now,
                    hrpCFrame = char.PrimaryPart.CFrame,
                }
                local head = char:FindFirstChild("Head")
                if head then entry.headPos = head.Position end
                table.insert(history[player.UserId], entry)
                -- trim old
                while #history[player.UserId] > 0 and now - history[player.UserId][1].t > HitRewind.BufferDuration do
                    table.remove(history[player.UserId],1)
                end
            else
                history[player.UserId] = nil
            end
        end
    end)
end

local function lerpVec3(a, b, alpha)
    return a + (b - a) * alpha
end

local function getInterpolated(userId, targetTime)
    local buf = history[userId]
    if not buf or #buf == 0 then return nil end
    if targetTime <= buf[1].t then return buf[1] end
    if targetTime >= buf[#buf].t then return buf[#buf] end
    -- binary search could be used; linear ok for small buffers
    for i = 1, #buf - 1 do
        local a = buf[i]
        local b = buf[i+1]
        if targetTime >= a.t and targetTime <= b.t then
            local alpha = (targetTime - a.t) / (b.t - a.t)
            local interp = {
                t = targetTime,
                hrpCFrame = a.hrpCFrame:Lerp(b.hrpCFrame, alpha),
                headPos = (a.headPos and b.headPos) and lerpVec3(a.headPos, b.headPos, alpha) or (a.headPos or b.headPos)
            }
            return interp
        end
    end
    return buf[#buf]
end

-- Utility: returns closest point on ray segment [origin, origin + direction*maxDist]
local function closestPointOnRaySegment(origin, dirUnit, maxDist, point)
    local toPoint = point - origin
    local t = toPoint:Dot(dirUnit)
    if t <= 0 then return origin end
    if t >= maxDist then return origin + dirUnit * maxDist end
    return origin + dirUnit * t
end

-- Capsule test: treat target's head as small sphere, also test torso/HRP
function HitRewind:RaycastWithRewind(shooterUserId, origin, directionUnit, maxDistance, shootTime)
    -- shootTime must be a timestamp from client (tick()) or server time; clamp to valid range
    local now = tick()
    if not shootTime or type(shootTime) ~= "number" then shootTime = now end
    local result = nil
    for _, target in pairs(Players:GetPlayers()) do
        if target.UserId ~= shooterUserId and target.Character and target.Character.PrimaryPart then
            local interp = getInterpolated(target.UserId, shootTime)
            if interp then
                local headPos = interp.headPos or interp.hrpCFrame.p
                -- check head sphere first
                local cp = closestPointOnRaySegment(origin, directionUnit, maxDistance, headPos)
                local dist = (cp - headPos).Magnitude
                local headRadius = 0.35 -- adjustable per-hitbox
                if dist <= headRadius then
                    result = {player = target, part = "Head", position = headPos}
                    return result
                end
                -- check torso/hrp as larger sphere
                local torsoPos = interp.hrpCFrame.p
                cp = closestPointOnRaySegment(origin, directionUnit, maxDistance, torsoPos)
                dist = (cp - torsoPos).Magnitude
                local torsoRadius = 0.6
                if dist <= torsoRadius then
                    result = {player = target, part = "Torso", position = torsoPos}
                    return result
                end
                -- Optionally: iterate limbs or use OBB for improved accuracy
            end
        end
    end
    return nil
end

return HitRewind
