-- ServerScriptService/Modules/Persistence.lua
local Persistence = {}
local DataStoreService = game:GetService("DataStoreService")
local playersStore = DataStoreService:GetDataStore("CSLikePlayerStore_v1")

function Persistence:SavePlayer(player)
    local key = "player_" .. player.UserId
    local data = {
        money = player:GetAttribute("Money") or 0,
        inventory = player:GetAttribute("Inventory") or {}
    }
    local success, err = pcall(function() playersStore:SetAsync(key, data) end)
    return success, err
end

function Persistence:LoadPlayer(player)
    local key = "player_" .. player.UserId
    local success, data = pcall(function() return playersStore:GetAsync(key) end)
    if success and data then
        player:SetAttribute("Money", data.money or 0)
        player:SetAttribute("Inventory", data.inventory or {})
        return true
    end
    -- defaults
    player:SetAttribute("Money", 800)
    player:SetAttribute("Inventory", {})
    return false
end

return Persistence
