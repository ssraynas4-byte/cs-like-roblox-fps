-- StarterPlayer/StarterPlayerScripts/UI/Spectator.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpectatorUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local info = Instance.new("TextLabel")
info.Size = UDim2.new(0, 200, 0, 40)
info.Position = UDim2.new(0.5, -100, 0, 10)
info.Text = "Spectating"
info.BackgroundTransparency = 0.5
info.Parent = screenGui

-- simple toggle follow next/prev player
local currentIndex = 1
local function spectateIndex(idx)
    local list = Players:GetPlayers()
    if #list == 0 then return end
    local target = list[(idx - 1) % #list + 1]
    local camera = workspace.CurrentCamera
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        camera.CameraType = Enum.CameraType.Attach
        camera.CameraSubject = target.Character:FindFirstChildOfClass("Humanoid")
        info.Text = "Spectating: " .. target.Name
    end
end

return screenGui
