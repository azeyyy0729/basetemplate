local hunger, thirst = 0, 0
local Framework = nil
local Framework_Obj = nil
local _GetResourceState = GetResourceState

Citizen.CreateThread(function()
  if _GetResourceState('qb-core'):find('start') then
    Framework = 'QB'
    Framework_Obj = exports['qb-core']:GetCoreObject()
    Framework_Obj.IsPlayerLoaded = function()
      return true
    end
  elseif _GetResourceState('es_extended'):find('start') then
    Framework = 'ESX'
    Framework_Obj = exports['es_extended']:getSharedObject()
  else
    -- put your code here
  end
end)

local getStatus = function()
  if Framework == 'QB' then
    local metadata = Framework_Obj.Functions.GetPlayerData()?.metadata
    if type(metadata) == "table" then
      hunger = metadata.hunger
      thirst = metadata.thirst
    end
  elseif Framework == 'ESX' then
    TriggerEvent('esx_status:getStatus', 'hunger', function(status)
      hunger = status.val / 10000
    end)
    TriggerEvent('esx_status:getStatus', 'thirst', function(status)
      thirst = status.val / 10000
    end)
  else
    -- put your code here
  end
end

Citizen.CreateThread(function()
    while true do
        getStatus()

        local voiceVolume = NetworkGetPlayerLoudness(PlayerId())
        local isTalking = voiceVolume > 0

        SendNUIMessage({
            stats = Framework_Obj.IsPlayerLoaded(),
            heal = GetEntityHealth(cache.ped) - 100,
            armour = GetPedArmour(cache.ped),
            thirst = thirst,
            food = hunger,
            voice = isTalking and 1 or 0,
        })

        Wait(1000) 
    end
end)


-- Citizen.CreateThread(function()
--   while true do
--   Citizen.Wait(3)
--       local playerPed = GetPlayerPed(-1)
--       local playerVeh = GetVehiclePedIsIn(playerPed, false)
--       if IsPedInAnyVehicle(playerPed, true) then
--           DisplayRadar(true)
--       else
--           DisplayRadar(false)
--       end
--   end
-- end)
