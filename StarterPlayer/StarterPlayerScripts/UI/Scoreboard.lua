-- StarterPlayer/StarterPlayerScripts/UI/Scoreboard.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Scoreboard"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Position = UDim2.new(1, -310, 0.1, 0)
frame.BackgroundTransparency = 0.6
frame.Parent = screenGui

local uiList = Instance.new("UIListLayout")
uiList.Parent = frame

local function refresh()
    frame:ClearAllChildren()
    uiList.Parent = frame
    for _, p in pairs(Players:GetPlayers()) do
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -10, 0, 24)
        lbl.Text = p.Name .. " - K:0 D:0"
        lbl.Parent = frame
    end
end

Players.PlayerAdded:Connect(function()
    refresh()
end)
Players.PlayerRemoving:Connect(function()
    refresh()
end)

refresh()
return screenGui
