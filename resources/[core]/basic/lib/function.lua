function _notify(message, title, icon)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(false, true)
end

function _showHelpNotification(msg)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

function _showAdvancedNotify(message, title, icon)
    if not message or message == "" then
        print("Erreur : Message vide ou nul")
        return
    end
    if not title or title == "" then
        print("Erreur : Titre vide ou nul")
        return
    end
    if not icon or icon == "" then
        print("Erreur : Icône vide ou nulle")
        icon = "CHAR_DEFAULT" -- Icône par défaut si aucune n'est fournie
    end
    AddTextEntry("AdvancedNotification", message) 
    BeginTextCommandThefeedPost("AdvancedNotification")
    SetNotificationTextEntry("STRING")
    AddTextComponentSubstringPlayerName(message)

    SetNotificationMessage(icon, icon, true, 1, title, " ")
    DrawNotification(false, true)
end


function _drawMarker(type, coords)
    DrawMarker(type, coords.x, coords.y, coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 255, 255, 255, 200, false, false, 2, false, nil, nil, false)
end

function _spawnPed(model, coords, heading)
    local hash = GetHashKey(model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(0) end

    local ped = CreatePed(4, hash, coords.x, coords.y, coords.z - 1.0, heading, false, true)
    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedFleeAttributes(ped, 0, 0)
    SetPedDiesWhenInjured(ped, false)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_STAND_IMPATIENT", 0, true)

    return ped
end

lib.callback.register('basic:ShowNotify', function(message, title, icon)
    _showAdvancedNotify(message, title, icon)
    return true
end)

lib.callback.register('basic:showAdvancedNotify', function(message, title, icon)
    _notify(message, title, icon)
    return true
end)

exports('_notify', _notify)
exports("_showAdvancedNotify", _showAdvancedNotify)
exports('_drawMarker', _drawMarker)
exports("_showHelpNotification", _showHelpNotification)
exports("_spawnPed", _spawnPed)

