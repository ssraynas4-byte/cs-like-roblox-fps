-- ServerScriptService/GameServer.lua
-- Bootstrapper: ensures RemoteEvents exist and hooks up basic services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local remoteNames = {
    "REQ_FireWeapon", "EVT_SpawnBulletFX", "EVT_PlayerHit", "EVT_PlayerKilled",
    "REQ_PlantBomb", "REQ_DefuseBomb", "EVT_BombPlanted", "EVT_BombDefused",
    "REQ_BuyItem", "EVT_RoundState", "REQ_GrenadeThrow", "EVT_PlayerFlash",
    "EVT_SmokeSpawn", "REQ_SpawnRequest"
}

local remotesFolder = ReplicatedStorage:FindFirstChild("RemoteEvents") or Instance.new("Folder", ReplicatedStorage)
remotesFolder.Name = "RemoteEvents"

for _, name in ipairs(remoteNames) do
    if not remotesFolder:FindFirstChild(name) then
        local evt = Instance.new("RemoteEvent")
        evt.Name = name
        evt.Parent = remotesFolder
    end
end

-- require modules to start services
local modules = ServerScriptService:WaitForChild("Modules")
local RoundManager = require(modules:WaitForChild("RoundManager"))
local Persistence = require(modules:WaitForChild("Persistence"))
local Bomb = require(modules:WaitForChild("Bomb"))

-- Player join handling
local Players = game:GetService("Players")
Players.PlayerAdded:Connect(function(player)
    -- load persistence
    Persistence:LoadPlayer(player)
end)

-- start a round loop after server boots
spawn(function()
    wait(2)
    RoundManager:StartRound()
end)
