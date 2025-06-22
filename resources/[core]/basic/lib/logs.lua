

function SendLogs(channelId, title, message, webhook)
    local connect = {
        {
            ["color"] = 16711680, -- Couleur du message
            ["title"] = title,
            ["description"] = message,
            ["footer"] = {
            ["text"] = "Logs",
            },
        }
    }
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = "Logs", embeds = connect}), { ['Content-Type'] = 'application/json' })
end

exports('SendLogs', SendLogs)


AddEventHandler('playerDropped', function(reason)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then
        if reason == "Exiting" then
            reason = "F8 QUIT / ALT+F4"
        end
        local name = xPlayer.getName()
        local identifier = xPlayer.identifier
        local formattedMessage = string.format("🔴 **Déconnexion**\nJoueur: %s\nIdentifier: %s\nRaison: %s", name, identifier, reason or "Inconnue")

        SendLogs(15158332, "Déconnexion Joueur", formattedMessage, Logs.Drop.webhookURL)
    end
end)



AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    if xPlayer then
        local formattedMessage = string.format(
            "🔵 **Spawn joueur**\nJoueur: %s\nId: %s",
            xPlayer.getName(),
            xPlayer.identifier
        )
        SendLogs(3447003, "Spawn Joueur", formattedMessage, Logs.Connection.webhookURL)
    end
end)

