-- StarterPlayer/StarterPlayerScripts/UI/HUDController.lua
-- Creates a simple HUD ScreenGui at runtime and listens to relevant events to update values.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local EVT_RoundState = ReplicatedStorage:WaitForChild("EVT_RoundState")
local EVT_PlayerHit = ReplicatedStorage:FindFirstChild("EVT_PlayerHit")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CSHUD"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Name = "TopBar"
frame.Size = UDim2.new(1,0,0,40)
frame.Position = UDim2.new(0,0,0,0)
frame.BackgroundTransparency = 0.6
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Parent = screenGui

local moneyLabel = Instance.new("TextLabel")
moneyLabel.Name = "Money"
moneyLabel.Font = Enum.Font.SourceSansBold
moneyLabel.TextSize = 20
moneyLabel.TextColor3 = Color3.fromRGB(255, 223, 0)
moneyLabel.BackgroundTransparency = 1
moneyLabel.Position = UDim2.new(0,10,0,6)
moneyLabel.Size = UDim2.new(0,200,1, -12)
moneyLabel.Text = "$0"
moneyLabel.Parent = frame

local roundLabel = Instance.new("TextLabel")
roundLabel.Name = "Round"
roundLabel.Font = Enum.Font.SourceSans
roundLabel.TextSize = 18
roundLabel.TextColor3 = Color3.fromRGB(255,255,255)
roundLabel.BackgroundTransparency = 1
roundLabel.Position = UDim2.new(0.5, -100,0,6)
roundLabel.Size = UDim2.new(0,200,1,-12)
roundLabel.Text = "Round: -"
roundLabel.Parent = frame

local healthLabel = Instance.new("TextLabel")
healthLabel.Name = "Health"
healthLabel.Font = Enum.Font.SourceSans
healthLabel.TextSize = 18
healthLabel.TextColor3 = Color3.fromRGB(255,255,255)
healthLabel.BackgroundTransparency = 1
healthLabel.Position = UDim2.new(1, -220,0,6)
healthLabel.Size = UDim2.new(0,200,1,-12)
healthLabel.Text = "HP: 100"
healthLabel.Parent = frame

-- Update health on humanoid
local function onCharacterAdded(char)
    local humanoid = char:WaitForChild("Humanoid")
    healthLabel.Text = "HP: " .. tostring(math.floor(humanoid.Health))
    humanoid.HealthChanged:Connect(function(health)
        healthLabel.Text = "HP: " .. tostring(math.floor(health))
    end)
end

if player.Character then
    onCharacterAdded(player.Character)
end
player.CharacterAdded:Connect(onCharacterAdded)

-- Listen for round events
EVT_RoundState.OnClientEvent:Connect(function(data)
    if data.state == "start" then
        roundLabel.Text = "Round: " .. tostring(data.round) .. " - " .. tostring(data.time) .. "s"
        -- countdown
        spawn(function()
            local t = data.time
            while t > 0 do
                roundLabel.Text = "Round: " .. tostring(data.round) .. " - " .. tostring(t) .. "s"
                wait(1)
                t = t - 1
            end
        end)
    elseif data.state == "end" then
        roundLabel.Text = "Round End - Winner: " .. tostring(data.winner)
    end
end)

-- Player hit feedback (small popup)
if EVT_PlayerHit then
    EVT_PlayerHit.OnClientEvent:Connect(function(info)
        -- could show damage popup; simple print for now
        print("You were hit by: ", info.from, "for", info.dmg)
    end)
end

return screenGui
