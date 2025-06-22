local UIDS = {}
local UIDtoID = {}

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        MySQL.Async.execute([[
            CREATE TABLE IF NOT EXISTS players_id (
                uid INT NOT NULL AUTO_INCREMENT,
                name VARCHAR(64) NOT NULL,
                identifier VARCHAR(100) NOT NULL UNIQUE,
                PRIMARY KEY (uid)
            )
        ]], {}, function()
            print("[es_extended] Table `players_id` vérifiée/créée.")
        end)
    end
end)

lib.callback.register('es_extended:getPlayerUID', function(source)
    local name = GetPlayerName(source)

    local identifier
    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local id = GetPlayerIdentifier(source, i)
        if string.sub(id, 1, 8) == "license:" then
            identifier = id
            break
        end
    end

    if not identifier then
        print("[es_extended:getPlayerUID] Aucun identifiant Rockstar trouvé pour le joueur:", source)
        return nil
    end

    if UIDS[source] then
        return UIDS[source]
    end

    local result = MySQL.Sync.fetchAll('SELECT uid FROM players_id WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    })

    if result and result[1] then
        local uid = result[1].uid
        UIDS[source] = uid
        UIDtoID[uid] = source
        return uid
    else
        MySQL.Sync.execute('INSERT INTO players_id (name, identifier) VALUES (@name, @identifier)', {
            ['@name'] = name,
            ['@identifier'] = identifier
        })

        local inserted = MySQL.Sync.fetchAll('SELECT uid FROM players_id WHERE identifier = @identifier', {
            ['@identifier'] = identifier
        })

        if inserted and inserted[1] then
            local uid = inserted[1].uid
            UIDS[source] = uid
            UIDtoID[uid] = source
            return uid
        end
    end

    return nil
end)


exports('GetUIDfromID', function(id)
    return UIDS[id]
end)

exports('GetIDfromUID', function(uid)
    return UIDtoID[uid]
end)

exports('GetUIDFromIdentifier', function(identifier)
    return MySQL.Sync.fetchScalar('SELECT uid FROM players_id WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }) or nil
end)


lib.callback.register('es_extended:getPlayerUIDFromID', function(_, id)
    return UIDS[id]
end)

lib.callback.register('es_extended:getIDFromUID', function(_, uid)
    return UIDtoID[uid]
end)
