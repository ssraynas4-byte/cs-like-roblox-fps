-- StarterPlayer/StarterPlayerScripts/UI/Killfeed.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Killfeed"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local feedFrame = Instance.new("Frame")
feedFrame.Size = UDim2.new(0, 300, 0, 200)
feedFrame.Position = UDim2.new(1, -310, 0, 10)
feedFrame.BackgroundTransparency = 1
feedFrame.Parent = screenGui

local function pushEntry(text)
    local lbl = Instance.new("TextLabel")
    lbl.Text = text
    lbl.Size = UDim2.new(1, 0, 0, 24)
    lbl.Parent = feedFrame
    delay(6, function() lbl:Destroy() end)
end

local EVT_PlayerKilled = ReplicatedStorage:FindFirstChild("EVT_PlayerKilled")
if EVT_PlayerKilled then
    EVT_PlayerKilled.OnClientEvent:Connect(function(info)
        pushEntry(info.killer .. " → " .. info.victim)
    end)
end

return screenGui
