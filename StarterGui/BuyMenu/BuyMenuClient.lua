-- StarterGui/BuyMenu/BuyMenuClient.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local REQ_BuyItem = ReplicatedStorage:WaitForChild("REQ_BuyItem")
local EVT_RoundState = ReplicatedStorage:WaitForChild("EVT_RoundState")

-- Build a simple BuyMenu screen gui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BuyMenu"
screenGui.Enabled = false
screenGui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 300)
frame.Position = UDim2.new(0.5, -200, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Text = "Buy Menu"
title.Size = UDim2.new(1,0,0,40)
title.Parent = frame

auto local function createButton(name, price, y)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 180, 0, 40)
    btn.Position = UDim2.new(0, 10 + (y%2)*190, 0, 50 + math.floor(y/2)*50)
    btn.Text = name .. " - $" .. tostring(price)
    btn.Parent = frame
    btn.MouseButton1Click:Connect(function()
        REQ_BuyItem:FireServer(name)
    end)
    return btn
end

-- sample items
createButton("ak47", 2700, 0)
createButton("pistol", 300, 1)
createButton("vest", 1000, 2)
createButton("flashbang", 200, 3)

-- toggle buy menu on 'B' when in buy state
local UserInputService = game:GetService("UserInputService")
local canOpen = false
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.B and canOpen then
        screenGui.Enabled = not screenGui.Enabled
    end
end)

EVT_RoundState.OnClientEvent:Connect(function(data)
    if data.state == "buy" then
        canOpen = true
    else
        canOpen = false
        screenGui.Enabled = false
    end
end)

return screenGui
