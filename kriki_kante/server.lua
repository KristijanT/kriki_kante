ESX = nil

local treasureItems = {
    [1] = {chance = 4, id = 'fanta', name = 'Fanta', quantity = math.random(1,3), limit = 111},
    [2] = {chance = 4, id = 'copper', name = 'Bakar', quantity = math.random(1,3), limit = 111},
    [3] = {chance = 3, id = 'steel', name = 'Celik', quantity = math.random(1,3), limit = 111},
    [4] = {chance = 3, id = 'iron', name = 'Metal', quantity = math.random(1,3), limit = 111},
    [5] = {chance = 1, id = 'lockpick', name = 'Lockpick', quantity = math.random(1,3), limit = 111},
    [6] = {chance = 1, id = 'plastic', name = 'Female Seed', quantity = math.random(1,3), limit = 111},
    [7] = {chance = 1, id = 'hamburger', name = 'Hamburger', quantity = math.random(1,3), limit = 111},
    [8] = {chance = 1, id = 'bread', name = 'Hleb', quantity = math.random(1,3), limit = 111},
    [9] = {chance = 2, id = 'water', name = 'Voda', quantity = math.random(1,3), limit = 111},
    [10] = {chance = 1, id = 'chips', name = 'Cips', quantity = math.random(1,3), limit = 111},
   }

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterUsableItem('wallet', function(source) --Hammer high time to unlock but 100% call cops
    local source = tonumber(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local cash = math.random(20, 120)
    local chance = math.random(1,2)

    if chance == 2 then
        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'You find $' .. cash .. ' inside the wallet'})
        xPlayer.addMoney(cash)
        local cardChance = math.random(1, 40)
        if cardChance == 20 then
            TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'You find a Green Keycard inside the wallet'})
            xPlayer.addInventoryItem('green-keycard', 1)
        end
    else
        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'The wallet was empty'})
    end

    xPlayer.removeInventoryItem('wallet', 1)
end)

RegisterServerEvent('onyx:startTreasureTimer')
AddEventHandler('onyx:startTreasureTimer', function(treasure)
    startTimer(source, treasure)
end)

RegisterServerEvent('onyx:giveTreasureReward')
AddEventHandler('onyx:giveTreasureReward', function()
    local source = tonumber(source)
    local item = {}
    local xPlayer = ESX.GetPlayerFromId(source)
    local gotID = {}
    local rolls = math.random(1, 2)
    local foundItem = false

    for i = 1, rolls do
        item = treasureItems[math.random(1, #treasureItems)]
        if math.random(1, 10) >= item.chance then
            if item.isWeapon and not gotID[item.id] then
                if item.limit > 0 then
                    local count = xPlayer.getInventoryItem(item.id).count
                    if count >= item.limit then
                        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'You find a ' .. item.name .. ' but cannot carry any more of this item'})
                    else
                        gotID[item.id] = true
                        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'You find a ' .. item.name})
                        foundItem = true
                        xPlayer.addWeapon(item.id, 50)
                    end
                else
                    gotID[item.id] = true
                    TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'You find a ' .. item.name})
                    foundItem = true
                    xPlayer.addWeapon(item.id, 50)
                end
            elseif not gotID[item.id] then
                if item.limit > 0 then
                    local count = xPlayer.getInventoryItem(item.id).count
                    if count >= item.limit then
                        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'You find ' .. item.quantity .. 'x ' .. item.name .. ' but cannot carry any more of this item'})
                    else
                        gotID[item.id] = true
                        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'You find ' .. item.quantity .. 'x ' .. item.name})
                        xPlayer.addInventoryItem(item.id, item.quantity)
                        foundItem = true
                    end
                else
                    gotID[item.id] = true
                    TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'You find ' .. item.quantity .. 'x ' .. item.name})
                    xPlayer.addInventoryItem(item.id, item.quantity)
                    foundItem = true
                end
            end
        end
        if i == rolls and not gotID[item.id] and not foundItem then
            TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'You find nothing'})
        end
    end
end)

function startTimer(id, object)
    local timer = 10 * 60000

    while timer > 0 do
        Wait(1000)
        timer = timer - 1000
        if timer == 0 then
            TriggerClientEvent('onyx:removeTreasure', id, object)
        end
    end
end