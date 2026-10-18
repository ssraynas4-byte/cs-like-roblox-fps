-- ServerScriptService/Modules/Economy.lua
local Economy = {}

local ITEM_COST = {
    ak47 = 2700,
    pistol = 300,
    vest = 1000,
    flashbang = 200,
    smoke = 300,
    hegrenade = 300,
    defuse = 400
}

function Economy:GetMoney(player)
    return player:GetAttribute("Money") or 0
end

function Economy:AddMoney(player, amount)
    local cur = self:GetMoney(player)
    player:SetAttribute("Money", cur + amount)
end

function Economy:CanBuy(player, itemId, isInBuyZone)
    if not ITEM_COST[itemId] then return false, "unknown" end
    if not isInBuyZone then return false, "not_in_buy_zone" end
    local money = self:GetMoney(player)
    if money < ITEM_COST[itemId] then return false, "no_money" end
    return true
end

function Economy:Buy(player, itemId)
    local ok, reason = self:CanBuy(player, itemId, true)
    if not ok then return false, reason end
    local cost = ITEM_COST[itemId]
    self:AddMoney(player, -cost)
    -- grant item: for weapons, call adapter to weapon system (not implemented here)
    return true
end

function Economy:GetItemCost(itemId)
    return ITEM_COST[itemId]
end

return Economy
