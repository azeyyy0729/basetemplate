local UID = nil
local ID = GetPlayerServerId(PlayerId())

exports('GetMyUID', function()
    return UID
end)

exports('GetUIDfromID', function(id)
    return lib.callback.await('es_extended:getPlayerUIDFromID', false, id)
end)

exports('GetIDfromUID', function(uid)
    return lib.callback.await('es_extended:getIDFromUID', false, uid)
end)

CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do
        Wait(0)
    end
    UID = lib.callback.await('es_extended:getPlayerUID', false)
    print("Mon UID est :", UID)
end)
