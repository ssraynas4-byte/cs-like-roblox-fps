-- StarterPlayerScripts/LocalWeaponClient.lua
-- Basic client-side weapon handler: handles input, local recoil, and sends fire requests to server.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local REQ_Fire = ReplicatedStorage:WaitForChild("REQ_FireWeapon")
local EVT_SpawnBulletFX = ReplicatedStorage:FindFirstChild("EVT_SpawnBulletFX")

local equippedWeapon = "ak47" -- default for testing
local canFire = true
local fireCooldown = 0.1 -- seconds between shots (client-side visual)
local ammo = {ak47 = {clip = 30, reserve = 90}}

local function getCameraRay()
    local viewportPoint = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
    local unitRay = camera:ViewportPointToRay(viewportPoint.X, viewportPoint.Y)
    local origin = unitRay.Origin
    local direction = unitRay.Direction.Unit
    return origin, direction
end

local function sendFire()
    if not canFire then return end
    local weaponId = equippedWeapon
    if ammo[weaponId].clip <= 0 then
        -- play empty click sound (implement later)
        return
    end

    canFire = false
    ammo[weaponId].clip = ammo[weaponId].clip - 1

    local origin, direction = getCameraRay()
    local payload = {
        weaponId = weaponId,
        fireId = HttpService:GenerateGUID(false),
        timestamp = tick(),
        origin = {origin.X, origin.Y, origin.Z},
        direction = {direction.X, direction.Y, direction.Z},
        seed = math.random(0,2^31)
    }
    -- fire locally (recoil/fx)
    if EVT_SpawnBulletFX then
        EVT_SpawnBulletFX:FireAllClients({pos = origin, dir = direction, weaponId = weaponId})
    end

    -- send to server
    REQ_Fire:FireServer(payload)

    -- simple cooldown
    delay(fireCooldown, function()
        canFire = true
    end)
end

-- Bind left mouse button to firing
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        sendFire()
    end
end)

-- Simple reload with R key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.R then
        local weaponId = equippedWeapon
        local need = 30 - ammo[weaponId].clip
        local take = math.min(need, ammo[weaponId].reserve)
        ammo[weaponId].clip = ammo[weaponId].clip + take
        ammo[weaponId].reserve = ammo[weaponId].reserve - take
        -- play reload animation locally (implement later)
    end
end)

-- Expose simple API for other UI scripts
local ClientWeapon = {}
function ClientWeapon:GetAmmo(weaponId)
    return ammo[weaponId] and ammo[weaponId].clip or 0, ammo[weaponId] and ammo[weaponId].reserve or 0
end

return ClientWeapon
