--- Display a pulsing notification.
---@param content string @The content of the notification.
---@param styles { Color: string } @The styles of the notification.
function zUI.ShowHelpNotification(content, styles)
    SendNUIMessage({
        action = "zUI-DisplayHelpNotification",
        data = {
            content = content,
            styles = styles
        }
    })
end

RegisterNetEvent("zUI:ShowHelpNotification")
AddEventHandler("zUI:ShowHelpNotification", function(content, styles)
    zUI.ShowHelpNotification(content, styles)
end)
