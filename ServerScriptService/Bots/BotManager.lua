-- ServerScriptService/Bots/BotManager.lua
local BotManager = {}
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Simple bot spawner that clones a player-like NPC and moves along path to target
function BotManager:SpawnBot(name)
    local bot = Instance.new("Model")
    bot.Name = name or "Bot"
    local hrp = Instance.new("Part")
    hrp.Name = "HumanoidRootPart"
    hrp.Size = Vector3.new(2,2,1)
    hrp.Position = Vector3.new(0,5,0)
    hrp.Parent = bot
    local humanoid = Instance.new("Humanoid")
    humanoid.Parent = bot
    bot.Parent = workspace
    return bot
end

function BotManager:MoveTo(bot, destination)
    local path = PathfindingService:CreatePath()
    path:ComputeAsync(bot.PrimaryPart.Position, destination)
    local waypoints = path:GetWaypoints()
    for _, wp in ipairs(waypoints) do
        bot:MoveTo(wp.Position)
        bot.MoveToFinished:Wait()
    end
end

return BotManager
