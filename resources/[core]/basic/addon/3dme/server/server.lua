RegisterCommand('me', function(source, args)
    local text = "L'individu "..table.concat(args, " ")
    TriggerClientEvent('3dme:shareDisplay', -1, text, source)
end)
