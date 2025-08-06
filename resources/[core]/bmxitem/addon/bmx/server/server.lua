local velo = { 'bmx' }

Citizen.CreateThread(function()
    for _, v in pairs(velo) do
        ESX.RegisterUsableItem(v, function(source)
            local count = exports.ox_inventory:GetItemCount(source, v)
            if count and count > 0 then
                lib.callback.await('SpawnVelo', source, v)
                exports.ox_inventory:RemoveItem(source, v, 1)
            else
                lib.callback.await('basic:ShowNotify', source, "Tu n'as pas de BMX sur toi.")
            end
        end)
    end
end)

lib.callback.register("AddBmxToPly", function(source)
    local itemName = "bmx"
    local count = exports.ox_inventory:GetItemCount(source, itemName)

    if count < 5 then
        local success, response = exports.ox_inventory:AddItem(source, itemName, 1)
        if success then
            lib.callback.await('basic:ShowNotify', source, "BMX récupéré avec succès.")
        else
            lib.callback.await('basic:ShowNotify', source, "Erreur lors de l'ajout du BMX : " .. tostring(response))
        end
    else
        lib.callback.await('basic:ShowNotify', source, "Tu ne peux pas porter plus de BMX.")
    end
end)
