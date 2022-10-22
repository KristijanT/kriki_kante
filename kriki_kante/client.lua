ESX = nil

local searched = {3423423424}
local canSearch = true
local treasures = {93927950}
local searchTime = 14000

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if canSearch then
            local ped = GetPlayerPed(-1)
            local pos = GetEntityCoords(ped)
            local treasureFound = false

            for i = 1, #treasures do
                local treasure = GetClosestObjectOfType(pos.x, pos.y, pos.z, 1.0, treasures[i], false, false, false)
                local dumpPos = GetEntityCoords(treasure)
                local dist = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, dumpPos.x, dumpPos.y, dumpPos.z, true)

                if dist < 1.8 then
                    DrawText3Ds(dumpPos.x, dumpPos.y, dumpPos.z + 1.0, 'Press [~y~E~w~] search')
                    if IsControlJustReleased(0, 38) then
                        for i = 1, #searched do
                            if searched[i] == treasure then
                                treasureFound = true
                            end
                            if i == #searched and treasureFound then
                                exports['mythic_notify']:Alert({
    style  =  'error',
    sound = true,
    message  =  'ALREADY SEARCHED'
})
                            elseif i == #searched and not treasureFound then
                                exports['mythic_notify']:Alert({
    style  =  'success',
    sound = true,
    message  =  '✔️ Searching'
})
                                startSearching(searchTime, 'amb@prop_human_bum_bin@base', 'base', 'onyx:giveTreasureReward')
                                TriggerServerEvent('onyx:startTreasureTimer', treasure)
                                table.insert(searched, treasure)
                            end
                        end
                    end
                end
            end
        end
    end
end)

RegisterNetEvent('onyx:removeTreasure')
AddEventHandler('onyx:removeTreasure', function(object)
    for i = 1, #searched do
        if searched[i] == object then
            table.remove(searched, i)
        end
    end
end)

-- Functions

function startSearching(time, dict, anim, cb)
    local animDict = dict
    local animation = anim
    local ped = GetPlayerPed(-1)

    canSearch = false

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(0)
    end
    exports['progressBars']:startUI(time, "Searching")
    TaskPlayAnim(ped, animDict, animation, 8.0, 8.0, time, 1, 1, 0, 0, 0)

    local ped = GetPlayerPed(-1)

    Wait(time)
    ClearPedTasks(ped)
    canSearch = true
    TriggerServerEvent(cb)
end

function DrawText3Ds(x, y, z, text)
	local onScreen,_x,_y=World3dToScreen2d(x,y,z)
	local factor = #text / 460
	local px,py,pz=table.unpack(GetGameplayCamCoords())
	
	SetTextScale(0.3, 0.3)
	SetTextFont(6)
	SetTextProportional(1)
	SetTextColour(255, 255, 255, 160)
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(_x,_y)
	DrawRect(_x,_y + 0.0115, 0.02 + factor, 0.027, 28, 28, 28, 95)
end