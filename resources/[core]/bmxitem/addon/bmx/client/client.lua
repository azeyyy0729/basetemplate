local carinteract = {}

if Config.item then
    carinteract = {
        {
            name = 'recupbmx',
            icon = 'fa-solid fa-bicycle',
            label = 'Récupérer le BMX',
            canInteract = function(entity, distance, coords, name, bone)
                local model = GetEntityModel(entity)
                return GetDisplayNameFromVehicleModel(model) == "BMX"
            end,
            onSelect = function()
                local playerPed = PlayerPedId()
                ESX.Streaming.RequestAnimDict("pickup_object")
                TaskPlayAnim(playerPed, "pickup_object", "pickup_low", 8.0, 8.0, -1, 0, 1, 0, 0, 0)
                Wait(1000)
                StopAnimTask(playerPed, "pickup_object", "pickup_low", 0.9)
                local coords = GetEntityCoords(PlayerPedId())
                local vehicle, distance = ESX.Game.GetClosestVehicle(coords)
                ESX.Game.DeleteVehicle(vehicle)
                lib.callback.await("AddBmxToPly")
                exports["basic"]:_notify("BMX récupéré avec succès.")
            end,
        }
    }

    exports.ox_target:addGlobalVehicle(carinteract)
end

lib.callback.register("SpawnVelo", function(car)
    local playerPed = PlayerPedId()
    ESX.Streaming.RequestAnimDict("pickup_object")
    TaskPlayAnim(playerPed, "pickup_object", "pickup_low", 8.0, 8.0, -1, 0, 1, 0, 0, 0)
    Wait(1000)
    StopAnimTask(playerPed, "pickup_object", "pickup_low", 0.9)

    local car = GetHashKey(car)
    RequestModel(car)
    while not HasModelLoaded(car) do
        RequestModel(car)
        Citizen.Wait(0)
    end

    local pos = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)
    local vehicle = CreateVehicle(car, pos.x, pos.y + 1.2, pos.z, heading, true, false)

    SetEntityAsMissionEntity(vehicle, true, false)
    SetVehicleModColor_1(vehicle, 0)
    SetVehicleModColor_2(vehicle, 0)
    SetVehicleOnGroundProperly(vehicle)

    exports["basic"]:_notify("BMX sorti avec succès.")
end)
