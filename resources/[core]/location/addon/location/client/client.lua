local LocationMenu = zUI.CreateMenu("", "", "Location de véhicules", "https://i.ibb.co/fnhTn69/header-location.jpg")

local SelectedLocation = "Location 1"
local SelectedVehicle = nil
local RentalPrice = 0

LocationMenu:SetItems(function(Items)
    Items:AddSeparator("Sélectionnez un véhicule")

    for _, vehicle in ipairs(Config.Location[SelectedLocation].vehicles) do
        Items:AddButton(vehicle.label, "Louer un véhicule: " .. vehicle.label, { RightLabel = "$" .. vehicle.price },
            function(onSelected)
                if onSelected then
                    SelectedVehicle = vehicle.name
                    RentalPrice = vehicle.price

                    local paymentOptions = {
                        { label = "Liquide", value = 'liquide' },
                        { label = "Banque", value = 'banque' }
                    }

                    local input = lib.inputDialog("Confirmation de location", {
                        { type = 'checkbox', label = "Confirmer la location de " .. vehicle.label, required = true },
                        { type = 'select', label = "Méthode de paiement", required = true, options = paymentOptions }
                    })

                    if input and input[1] then
                        local paymentType = input[2]
                        local success, message = lib.callback.await("vecRent:server:rentVehicle", false, {
                            vehicle = SelectedVehicle,
                            spawn = Config.Location[SelectedLocation].spawn,
                            price = RentalPrice,
                            heading = Config.Location[SelectedLocation].spawn.w
                        }, paymentType)

                        exports["basic"]:_notify(message)
                        if success then
                            LocationMenu:SetVisible(false)
                        end
                    end
                end
            end
        )
    end
end)

for _, location in pairs(Config.Location) do
    local coords = vector3(location.ped.x, location.ped.y, location.ped.z)
    local heading = location.ped.w
    exports["basic"]: _spawnPed("csb_sol", coords, heading)
end

for locationName, locationData in pairs(Config.Location) do
    local coords = vector3(locationData.shop.x, locationData.shop.y, locationData.shop.z)

    CreateThread(function()
        while true do
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local dist = #(playerCoords - coords)

            if dist < 6.0 then
                exports["basic"]:_drawMarker(1, coords)

                if dist < 1.5 then
                    exports["basic"]:_showHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour accéder à la location")

                    if IsControlJustPressed(0, 38) then
                        SelectedLocation = locationName
                        LocationMenu:SetVisible(true)
                    end
                end

                Wait(0)
            else
                Wait(500)
            end
        end
    end)
end

LocationMenu:OnOpen(function()
    FreezeEntityPosition(PlayerPedId(), true)
end)

LocationMenu:OnClose(function()
    FreezeEntityPosition(PlayerPedId(), false)
end)

lib.callback.register("vecRent:client:createVehicle", function(vehicleData)
    local modelHash = GetHashKey(vehicleData.vehicle)

    if not IsModelInCdimage(modelHash) or not IsModelAVehicle(modelHash) then
        return false
    end

    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do Wait(0) end

    local veh = CreateVehicle(modelHash, vehicleData.spawn.x, vehicleData.spawn.y, vehicleData.spawn.z, vehicleData.heading, true, false)
    if veh then
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        SetVehicleNumberPlateText(veh, "LOCATION")
        SetModelAsNoLongerNeeded(modelHash)
        return true
    end

    return false
end)
