local Config = lib.require('config')
local isHired, holdingPizza, pizzaDelivered, activeOrder = false, false, false, false
local pizzaProp, pizzaBoss, startZone, pizzaCar, currZone
local oxtarget = GetResourceState('ox_target') == 'started'

local pizzajobBlip = AddBlipForCoord(vec3(Config.BossCoords.x, Config.BossCoords.y, Config.BossCoords.z)) 
SetBlipSprite(pizzajobBlip, 267)
SetBlipAsShortRange(pizzajobBlip, true)
SetBlipScale(pizzajobBlip, 0.6)
SetBlipColour(pizzajobBlip, 2)
BeginTextCommandSetBlipName('STRING')
AddTextComponentString('Livraison de pizza')
EndTextCommandSetBlipName(pizzajobBlip)

local function doEmote(bool)
    if bool then
        local model = `prop_pizza_box_02`
        lib.requestModel(model)
        local coords = GetEntityCoords(cache.ped)
        pizzaProp = CreateObject(model, coords.x, coords.y, coords.z, true, true, true)
        AttachEntityToEntity(pizzaProp, cache.ped, GetPedBoneIndex(cache.ped, 28422), 0.0100,-0.1000, -0.1590, 20.0000007, 0.0, 0.0, true, true, false, true, 0, true)
        lib.requestAnimDict('anim@heists@box_carry@')
        TaskPlayAnim(cache.ped, 'anim@heists@box_carry@', 'idle', 5.0, 5.0, -1, 51, 0, 0, 0, 0)
        SetModelAsNoLongerNeeded(model)
        CreateThread(function()
            while DoesEntityExist(pizzaProp) do
                if not IsEntityPlayingAnim(cache.ped, 'anim@heists@box_carry@', 'idle', 3) then
                    TaskPlayAnim(cache.ped, 'anim@heists@box_carry@', 'idle', 5.0, 5.0, -1, 51, 0, 0, 0, 0)
                end
                Wait(1000)
            end
            RemoveAnimDict('anim@heists@box_carry@')
        end)
    else
        if DoesEntityExist(pizzaProp) then
            DetachEntity(cache.ped, true, false)
            DeleteEntity(pizzaProp)
            pizzaProp = nil
            ClearPedTasksImmediately(cache.ped)
        end
    end
    holdingPizza = bool
end

local function resetJob()
    if oxtarget then
        exports.ox_target:removeZone(currZone)
    else
        exports['qb-target']:RemoveZone(currZone)
    end
    currZone = nil
    RemoveBlip(JobBlip)
    isHired = false
    holdingPizza = false
    pizzaDelivered = false
    activeOrder = false
    if startZone then startZone:remove() startZone = nil end
end

local function TakePizza()
    if IsPedInAnyVehicle(cache.ped, false) or IsEntityDead(cache.ped) or holdingPizza then
        return
    end
    
    local pos = GetEntityCoords(cache.ped)

    if #(pos - vec3(currentDelivery.x, currentDelivery.y, currentDelivery.z)) >= 30.0 then
        return exports["basic"]:_notify("Vous n'êtes pas assez proche de la maison du client !")
    end
    
    doEmote(true)
end

local function PullOutVehicle(netid, data)
    pizzaCar = lib.waitFor(function()
        if NetworkDoesEntityExistWithNetworkId(netid) then
            return NetToVeh(netid)
        end
    end, 'Impossible de charger l\'entité dans le temps imparti.', 1000)

    if pizzaCar == 0 then
        return exports["basic"]:_notify('Erreur lors de l\'apparition du véhicule.')
    end

    SetVehicleNumberPlateText(pizzaCar, 'PIZZA'..tostring(math.random(1000, 9999)))
    SetVehicleColours(pizzaCar, 111, 111)
    SetVehicleDirtLevel(pizzaCar, 1)
    handleVehicleKeys(pizzaCar)
    SetVehicleEngineOn(pizzaCar, true, true)
    isHired = true
    NextDelivery(data)
    Wait(500)
    if Config.FuelScript.enable then
        exports[Config.FuelScript.script]:SetFuel(pizzaCar, 100.0)
    else
        Entity(pizzaCar).state.fuel = 100
    end

    if oxtarget then
        exports.ox_target:addEntity(netid, {
            {
                icon = 'fa-solid fa-pizza-slice',
                label = 'Prendre la pizza',
                onSelect = TakePizza,
                canInteract = function() 
                    return isHired and activeOrder and not holdingPizza
                end,
                distance = 2.5
            },
            {
                icon = 'fa-solid fa-pizza-slice',
                label = 'Reposer la pizza',
                onSelect = function(entity) 
                    doEmote(false)
                end,
                canInteract = function() 
                    return isHired and activeOrder and holdingPizza
                end,
                distance = 2.5
            },
        })
    else
        exports['qb-target']:AddTargetEntity(pizzaCar, {
            options = {
                {
                    icon = 'fa-solid fa-pizza-slice',
                    label = 'Take Pizza',
                    action = TakePizza,
                    canInteract = function() 
                        return isHired and activeOrder and not holdingPizza
                    end,
                    
                },
                {
                    icon = 'fa-solid fa-pizza-slice',
                    label = 'Return Pizza',
                    action = function(entity) 
                        doEmote(false)
                    end,
                    canInteract = function() 
                        return isHired and activeOrder and holdingPizza
                    end,
                    
                },
            },
            distance = 2.5
        })
    end
end

local function finishWork()
    local ped = cache.ped
    local pos = GetEntityCoords(ped)

    local finishspot = vec3(Config.BossCoords.x, Config.BossCoords.y, Config.BossCoords.z)
    if #(pos - finishspot) > 10.0 or not isHired then return end

    if oxtarget then
        exports.ox_target:removeEntity(NetworkGetNetworkIdFromEntity(pizzaCar), {'Prendre la pizza', 'Reposer la pizza'})
    else
        exports['qb-target']:RemoveTargetEntity(pizzaCar, {'Take Pizza', 'Return Pizza'})
    end

    local success = lib.callback.await('randol_pizzajob:server:clockOut', false)
    if success then
        RemoveBlip(JobBlip)
        doEmote(false)
        isHired, activeOrder = false, false
        exports["basic"]:_notify('Vous avez terminé votre service.')
        pizzaCar = nil
    end
end

local function yeetPed()
    if DoesEntityExist(pizzaBoss) then
        DeleteEntity(pizzaBoss)
        pizzaBoss = nil
    end
end

local function spawnPed()
    if DoesEntityExist(pizzaBoss) then return end
    
    lib.requestModel(Config.BossModel)
    pizzaBoss = CreatePed(0, Config.BossModel, Config.BossCoords, false, false)
    SetEntityAsMissionEntity(pizzaBoss)
    SetPedFleeAttributes(pizzaBoss, 0, 0)
    SetBlockingOfNonTemporaryEvents(pizzaBoss, true)
    SetEntityInvincible(pizzaBoss, true)
    FreezeEntityPosition(pizzaBoss, true)
    lib.requestAnimDict('amb@world_human_leaning@female@wall@back@holding_elbow@idle_a')        
    TaskPlayAnim(pizzaBoss, 'amb@world_human_leaning@female@wall@back@holding_elbow@idle_a', 'idle_a', 8.0, 1.0, -1, 01, 0, 0, 0, 0)
    RemoveAnimDict('amb@world_human_leaning@female@wall@back@holding_elbow@idle_a')
    SetModelAsNoLongerNeeded(Config.BossModel)
end

local function deliverPizza()
    if holdingPizza and isHired and not pizzaDelivered then
        lib.requestAnimDict('timetable@jimmy@doorknock@')
        TaskPlayAnim(cache.ped, 'timetable@jimmy@doorknock@', 'knockdoor_idle', 3.0, 1.0, -1, 49, 0, true, true, true)
        RemoveAnimDict('timetable@jimmy@doorknock@')
        pizzaDelivered = true
        if lib.progressCircle({
            duration = 7000,
            position = 'bottom',
            label = 'Delivering pizza',
            useWhileDead = true,
            canCancel = false,
            disable = { move = true, car = true, mouse = false, combat = true, },
        }) then
            local success, data = lib.callback.await('randol_pizzajob:server:Payment', false)
            if not success then return end
            RemoveBlip(JobBlip)
            if oxtarget then
                exports.ox_target:removeZone(currZone)
            else
                exports['qb-target']:RemoveZone(currZone)
            end
            currZone = nil
            activeOrder = false
            pizzaDelivered = false
            doEmote(false)
            if data then
                NextDelivery(data)
            end
        end
    else
        exports["basic"]:_notify('Tu as besoin de la pizza dans la voiture, idiot.')
    end
end

function NextDelivery(data)
    if activeOrder then return end
    currentDelivery = data.current
    JobBlip = AddBlipForCoord(currentDelivery.x, currentDelivery.y, currentDelivery.z)
    SetBlipSprite(JobBlip, 1)
    SetBlipDisplay(JobBlip, 4)
    SetBlipScale(JobBlip, 0.8)
    SetBlipFlashes(JobBlip, true)
    SetBlipAsShortRange(JobBlip, true)
    SetBlipColour(JobBlip, 2)
    SetBlipRoute(JobBlip, true)
    SetBlipRouteColour(JobBlip, 2)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('Next Customer')
    EndTextCommandSetBlipName(JobBlip)
    if oxtarget then
    currZone = exports.ox_target:addSphereZone({
        coords = vec3(currentDelivery.x, currentDelivery.y, currentDelivery.z),
        radius = 1.3,
        debug = false,
        options = {
            {
                icon = 'fa-solid fa-pizza-slice',
                label = 'Livrer la pizza',
                onSelect = deliverPizza,
                distance = 1.5,
            },
        }
    })
    else
        exports['qb-target']:AddCircleZone('deliverZone', vec3(currentDelivery.x, currentDelivery.y, currentDelivery.z), 1.3,{
            name = 'deliverZone', 
            debugPoly = false, 
            useZ=true, 
        }, { options = {
            { 
                icon = 'fa-solid fa-pizza-slice', 
                label = 'Deliver Pizza',
                action = deliverPizza,
            },}, 
            distance = 1.5 
        })
        currZone = 'deliverZone'
    end
    activeOrder = true
    exports["basic"]:_notify('Vous avez une nouvelle livraison !')
end

local function startJobPoint()
    startZone = lib.points.new({
        coords = Config.BossCoords.xyz,
        distance = 50,
        onEnter = spawnPed,
        onExit = yeetPed,
    })
end

function OnPlayerLoaded()
    startJobPoint()
end

function OnPlayerUnload()
    resetJob()
end

AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() ~= resource or not hasPlyLoaded() then return end
    startJobPoint()
end)

AddEventHandler('onResourceStop', function(resourceName) 
    if GetCurrentResourceName() ~= resourceName then return end
    resetJob()
end)

local zUI = exports["zUI-v2"]:getObject()

local MenuPizza = zUI.CreateMenu("", "", "Livraison Pizza", "default", "https://i.ibb.co/C5YQGJRC/shopui-title-pizzathis.png")

zUI.SetItems(MenuPizza, function()
    if not isHired then
        zUI.Button("Commencer la tournée", "Commencer la livraison de pizzas.", {}, function(onSelected)
            if onSelected then
                local netid, data = lib.callback.await('randol_pizzajob:server:spawnVehicle', false)
                if netid and data then
                    PullOutVehicle(netid, data)
                    zUI.SetVisible(MenuPizza, false)
                end
            end
        end)
    else
        zUI.Button("Terminer la tournée", "Rendre le véhicule et terminer son service.", {}, function(onSelected)
            if onSelected then
                finishWork()
                zUI.SetVisible(MenuPizza, false)
            end
        end)
    end
end)

zUI.SetOpenHandler(MenuPizza, function()
    FreezeEntityPosition(PlayerPedId(), true)
end)

zUI.SetCloseHandler(MenuPizza, function()
    FreezeEntityPosition(PlayerPedId(), false)
end)


CreateThread(function()
    local coords = Config.MarkerCoords

    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local dist = #(playerCoords - coords)

        if dist < 6.0 then
            exports["basic"]:_drawMarker(1, coords)

            if dist < 1.5 then
                exports["basic"]:_showHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour parler avec le pizzaiolo")
                if IsControlJustPressed(0, 38) then
                    zUI.SetVisible(MenuPizza, true)
                end
            end

            Wait(0)
        else
            Wait(500)
        end
    end
end)
