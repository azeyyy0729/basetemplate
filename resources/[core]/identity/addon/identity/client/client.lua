local identityMenu = zUI.CreateMenu("", "", "Définir vos informations personnelles", "https://i.ibb.co/j8W6ZRq/header.jpg")

local nom, prenom, taille, nationalite, birthdate = "", "", 170, "", nil
local genderIndex = 0
local valide = false
local isFirstSpawn = true

local function _notify(message)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(false, true)
end

local function calculateAgeServerSide(timestamp)
    local age = lib.callback.await('identity:calculateAge', false, timestamp)
    return age or 0
end

local function formatDateServerSide(timestamp)
    return lib.callback.await('identity:formatDate', false, timestamp) or "Non définie"
end

local function hasCompletedIdentity()
    return lib.callback.await("esx_identity:hasCompletedIdentity", false) or false
end

local function showIdentityPreview()
    local dateStr = birthdate and formatDateServerSide(math.floor(birthdate / 1000)) or "Non définie"
    zUI.ShowInfo("Aperçu Identité", nil, {
        { "Nom", nom ~= "" and nom or "Non défini" },
        { "Prénom", prenom ~= "" and prenom or "Non défini" },
        { "Date de naissance", dateStr },
        { "Taille", taille and (taille .. " cm") or "Non définie" },
        { "Nationalité", nationalite ~= "" and nationalite or "Non définie" },
        { "Genre", genderIndex == 0 and "Homme" or "Femme" }
    })
end

local function validateIdentity()
    if nom == "" then
        _notify("Le nom ne peut pas être vide.")
        return false
    end

    if prenom == "" then
        _notify("Le prénom ne peut pas être vide.")
        return false
    end

    if not birthdate then
        _notify("Veuillez définir votre date de naissance.")
        return false
    end

    local age = calculateAgeServerSide(math.floor(birthdate / 1000))
    if age < 16 then
        _notify("Vous devez avoir au moins 16 ans.")
        return false
    end

    if age > 100 then
        _notify("L'âge ne peut pas dépasser 100 ans.")
        return false
    end

    if not taille or taille < 130 or taille > 240 then
        _notify("La taille doit être comprise entre 130 cm et 240 cm.")
        return false
    end

    return true
end

local function saveIdentityToServer()
    local data = {
        firstName = prenom,
        lastName = nom,
        dateOfBirth = math.floor(birthdate / 1000),
        sex = genderIndex == 0 and "m" or "f",
        height = taille,
        nationality = nationalite,
    }

    local success = lib.callback.await("esx_identity:registerIdentity", false, data)
    return success
end

identityMenu:SetItems(function(Items)
    Items:AddSeparator("Informations personnelles")

    Items:AddButton("Nom", "Définir votre nom", {}, function(onSelected, onHovered)
        if onHovered then showIdentityPreview() end
        if onSelected then
            local input = lib.inputDialog('Nom', {
                { type = "input", label = "Nom", placeholder = "Dupont", required = true }
            })
            if input then
                nom = input[1]
                _notify("Nom défini : " .. nom)
            end
        end
    end)

    Items:AddButton("Prénom", "Définir votre prénom", {}, function(onSelected, onHovered)
        if onHovered then showIdentityPreview() end
        if onSelected then
            local input = lib.inputDialog('Prénom', {
                { type = "input", label = "Prénom", placeholder = "Jean", required = true }
            })
            if input then
                prenom = input[1]
                _notify("Prénom défini : " .. prenom)
            end
        end
    end)

    Items:AddButton("Date de naissance", "Sélectionnez votre date de naissance", {}, function(onSelected, onHovered)
        if onHovered then showIdentityPreview() end
        if onSelected then
            local input = lib.inputDialog('Date de naissance', {
                { type = 'date', label = 'Date de naissance', required = true, format = "DD/MM/YYYY", default = true }
            })
            if input then
                birthdate = input[1]
                _notify("Date de naissance définie.")
            end
        end
    end)

    Items:AddButton("Taille", "Définir votre taille (cm)", {}, function(onSelected, onHovered)
        if onHovered then showIdentityPreview() end
        if onSelected then
            local input = lib.inputDialog("Taille", {
                { type = "number", label = "Taille (en cm)", min = 130, max = 240, default = taille, required = true }
            })
            if input then
                taille = tonumber(input[1])
                _notify("Taille définie : " .. taille .. " cm")
            end
        end
    end)

    Items:AddButton("Nationalité", "Définir votre nationalité", {}, function(onSelected, onHovered)
        if onHovered then showIdentityPreview() end
        if onSelected then
            local input = lib.inputDialog('Nationalité', {
                { type = "input", label = "Nationalité", placeholder = "Française", required = true }
            })
            if input then
                nationalite = input[1]
                _notify("Nationalité définie : " .. nationalite)
            end
        end
    end)

    Items:AddList("Genre", "Choisissez votre genre", genderIndex +1, { "Femme", "Homme" }, {}, function(_, onHovered, onListChange, i)
        if onHovered then showIdentityPreview() end
        if onListChange then
            genderIndex = i - 1
            _notify("Genre sélectionné : " .. (genderIndex == 0 and "Homme" or "Femme"))
        end
    end)

    Items:AddButton("Valider", "Valider vos informations", {}, function(onSelected, onHovered)
        if onHovered then showIdentityPreview() end
        if onSelected then
            if validateIdentity() then
                local saved = saveIdentityToServer()
                if saved then
                    valide = true
                    zUI.ShowInfo("Succès", "Vos informations ont été enregistrées avec succès.")
                    _notify("Identité enregistrée avec succès.")
                    identityMenu:SetVisible(false)
                    TriggerEvent('esx_skin:openSaveableMenu',
                        function()
                            _notify("Personnalisation enregistrée.")
                        end,
                        function()
                            _notify("Personnalisation annulée.")
                        end
                    )
                else
                    _notify("Erreur lors de l'enregistrement, veuillez réessayer.")
                end
            end
        end
    end)
end)

identityMenu:OnOpen(function()
    _notify("Bienvenue dans la création de votre identité.")
    local playerPed = PlayerPedId()
    FreezeEntityPosition(playerPed, true)
end)

identityMenu:OnClose(function()
    if not valide then
        _notify("Vous devez compléter votre identité pour continuer.")
        Citizen.SetTimeout(100, function()
            identityMenu:SetVisible(true)
        end)
    else
        local playerPed = PlayerPedId()
        FreezeEntityPosition(playerPed, false)
    end
end)

AddEventHandler('playerSpawned', function()
    if isFirstSpawn then
        isFirstSpawn = false
        local done = hasCompletedIdentity()
        if not done then
            DoScreenFadeOut(500)
            Citizen.Wait(500)  
            local playerPed = PlayerPedId()
            local x, y, z, heading = -811.7599, 175.1936, 75.7454, 107.1220
            SetEntityCoords(playerPed, x, y, z, false, false, false, true)
            SetEntityHeading(playerPed, heading)

            FreezeEntityPosition(playerPed, true)

            DoScreenFadeIn(500) 

            identityMenu:SetVisible(true)
        end
    end
end)


RegisterCommand("openIdentite", function()
    local playerPed = PlayerPedId()
    local x, y, z, heading = -811.7599, 175.1936, 75.7454, 107.1220
    SetEntityCoords(playerPed, x, y, z, false, false, false, true)
    SetEntityHeading(playerPed, heading)
    identityMenu:SetVisible(true)
end)
