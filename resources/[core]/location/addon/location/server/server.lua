local rentedVehicles = {}
local rentalCooldowns = {} -- Stocke les délais avant une nouvelle location

function hasActiveRental(playerId)
    local currentTime = os.time()

    if rentalCooldowns[playerId] and currentTime < rentalCooldowns[playerId] then
        return true, "Veuillez patienter avant de louer un nouveau véhicule."
    end

    return false
end

lib.callback.register("vecRent:server:rentVehicle", function(source, vehicleData, paymentType)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    local rentalAllowed, message = hasActiveRental(source)
    if rentalAllowed then
        return false, message or "Vous avez déjà un véhicule loué ou devez attendre avant d'en relouer un."
    end

    local price = vehicleData.price
    local hasEnoughMoney = false

    if paymentType == "liquide" then
        if xPlayer.getMoney() >= price then
            xPlayer.removeMoney(price)
            hasEnoughMoney = true
        else
            return false, "Vous n'avez pas assez d'argent liquide."
        end
    elseif paymentType == "banque" then
        if xPlayer.getAccount('bank').money >= price then
            xPlayer.removeAccountMoney('bank', price)
            hasEnoughMoney = true
        else
            return false, "Vous n'avez pas assez d'argent sur votre compte bancaire."
        end
    end

    if hasEnoughMoney then
        table.insert(rentedVehicles, { playerId = source, vehicleData = vehicleData })

        rentalCooldowns[source] = os.time() + 30 -- Ajoute un délai de 30 secondes avant la prochaine location

        local logMessage = string.format(
            "🚗 **Location de véhicule**\nNom: %s\nID: %s\nPosition: X: %.2f Y: %.2f Z: %.2f\nVéhicule loué: %s\nMéthode de paiement: %s",
            xPlayer.getName(),
            xPlayer.identifier,
            vehicleData.spawn.x,
            vehicleData.spawn.y,
            vehicleData.spawn.z,
            vehicleData.vehicle,
            paymentType
        )

        exports['basic']:SendLogs(1752220, "Location de véhicules", logMessage, Logs.Location.webhookURL)

        local created = lib.callback.await("vecRent:client:createVehicle", source, vehicleData)
        if created then
          --  exports.mVehicle.AddTemporalVehicle(source, vehicleData.vehicle) -- Enregistre le véhicule temporaire
            return true, "Véhicule loué avec succès !"
        else
            return false, "Une erreur est survenue lors de la création du véhicule."
        end
    else
        return false, "Fonds insuffisants."
    end
end)

