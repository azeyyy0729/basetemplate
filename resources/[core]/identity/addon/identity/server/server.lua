ESX = exports["es_extended"]:getSharedObject()

local function calculateAge(dateOfBirth)
    if type(dateOfBirth) == "number" then
        dateOfBirth = os.date("%d/%m/%Y", dateOfBirth)
    elseif type(dateOfBirth) ~= "string" or dateOfBirth == "" then
        return 0
    end

    local day, month, year = dateOfBirth:match("^(%d%d)/(%d%d)/(%d%d%d%d)$")
    if not day or not month or not year then
        return 0
    end

    local now = os.date("*t")
    local age = now.year - tonumber(year)

    if tonumber(month) > now.month or (tonumber(month) == now.month and tonumber(day) > now.day) then
        age = age - 1
    end

    return age
end

lib.callback.register('identity:calculateAge', function(_, timestamp)
    local now = os.time()
    local age = os.difftime(now, timestamp) / (365.25 * 24 * 3600)
    return math.floor(age)
end)

lib.callback.register('identity:formatDate', function(_, timestamp)
    return os.date('%d/%m/%Y', timestamp)
end)

lib.callback.register('esx_identity:registerIdentity', function(source, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return false
    end
    if not data.firstName or data.firstName == '' or
       not data.lastName or data.lastName == '' or
       not data.dateOfBirth or data.dateOfBirth == '' or
       not data.sex or (data.sex ~= 'm' and data.sex ~= 'f') or
       not data.height or tonumber(data.height) < 130 or tonumber(data.height) > 240 then
        return false
    end

    local age = calculateAge(data.dateOfBirth)
    if age < 16 or age > 100 then
        return false
    end

    local identifier = xPlayer.identifier

    local finished = false
    local success = false

    MySQL.Async.execute('UPDATE users SET firstname = @firstname, lastname = @lastname, dateofbirth = @dateofbirth, sex = @sex, height = @height WHERE identifier = @identifier', {
        ['@firstname'] = data.firstName,
        ['@lastname'] = data.lastName,
        ['@dateofbirth'] = data.dateOfBirth,
        ['@sex'] = data.sex,
        ['@height'] = tonumber(data.height),
        ['@identifier'] = identifier
    }, function(rowsChanged)
        success = rowsChanged > 0
        if success then
            local logMessage = string.format(
                "👤 **Création / Mise à jour de personnage**\nNom: %s %s\nID: %s\nDate de naissance: %s\nSexe: %s\nTaille: %d cm",
                data.firstName,
                data.lastName,
                identifier,
                data.dateOfBirth,
                data.sex,
                tonumber(data.height)
            )
            exports['basic']:SendLogs(
                3447003, 
                "Création de personnage",
                logMessage,
                Logs.CharacterCreation.webhookURL
            )
        end
        finished = true
    end)

    while not finished do
        Citizen.Wait(10)
    end

    return success
end)



lib.callback.register("esx_identity:hasCompletedIdentity", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    local firstName = xPlayer.get('firstName')
    local lastName = xPlayer.get('lastName')

    if firstName ~= nil and firstName ~= '' and lastName ~= nil and lastName ~= '' then
        return true
    else
        return false
    end
end)
