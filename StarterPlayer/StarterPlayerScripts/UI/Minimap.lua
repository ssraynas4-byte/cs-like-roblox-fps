-- StarterPlayer/StarterPlayerScripts/UI/Minimap.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Minimap"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local mapFrame = Instance.new("Frame")
mapFrame.Size = UDim2.new(0, 200, 0, 200)
mapFrame.Position = UDim2.new(0, 10, 0.7, 0)
mapFrame.BackgroundTransparency = 0.7
mapFrame.Parent = screenGui

-- Simple dots for teammates
local function update()
    mapFrame:ClearAllChildren()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and p.Character.PrimaryPart then
            local dot = Instance.new("Frame")
            dot.Size = UDim2.new(0, 6, 0, 6)
            dot.BackgroundColor3 = p == player and Color3.new(0,1,0) or Color3.new(0,0,1)
            dot.Position = UDim2.new(0, 100 + (p.Character.PrimaryPart.Position.X % 80), 0, 100 + (p.Character.PrimaryPart.Position.Z % 80))
            dot.Parent = mapFrame
        end
    end
end

spawn(function()
    while true do
        update()
        wait(0.5)
    end
end)

return screenGui
