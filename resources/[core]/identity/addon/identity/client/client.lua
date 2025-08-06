local zUI = exports["zUI-v2"]:getObject()

local identityMenu = zUI.CreateMenu("", "", "Définir vos informations personnelles", "default", "https://i.ibb.co/j8W6ZRq/header.jpg")

local nom, prenom, taille, nationalite, birthdate = "", "", 170, "", nil
local genderIndex = 0
local valide = false
local isFirstSpawn = true

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

local showIdentityInfo = false 
local lastIdentityState = nil  

Citizen.CreateThread(function()
    while true do
        if showIdentityInfo then
            local dateStr = birthdate and formatDateServerSide(math.floor(birthdate / 1000)) or "Non définie"

            zUI.ShowInfoBox(
                "Aperçu Identité",
                "Informations de votre personnage.",
                "default",
                {
                    { type = "text",  title = "Nom",              value = nom ~= "" and nom or "Non défini" },
                    { type = "text",  title = "Prénom",           value = prenom ~= "" and prenom or "Non défini" },
                    { type = "text",  title = "Date de naissance", value = dateStr },
                    { type = "text",  title = "Taille",           value = taille and (taille .. " cm") or "Non définie" },
                    { type = "text",  title = "Nationalité",      value = nationalite ~= "" and nationalite or "Non définie" },
                    { type = "text",  title = "Genre",            value = genderIndex == 0 and "Femme" or "Homme" }
                }
            )
        end
        Citizen.Wait(200)
    end
end)


local function validateIdentity()
    if nom == "" then
        exports["basic"]:_notify("Le nom ne peut pas être vide.")
        return false
    end

    if prenom == "" then
        exports["basic"]:_notify("Le prénom ne peut pas être vide.")
        return false
    end

    if not birthdate then
        exports["basic"]:_notify("Veuillez définir votre date de naissance.")
        return false
    end

    local age = calculateAgeServerSide(math.floor(birthdate / 1000))
    if age < 16 then
        exports["basic"]:_notify("Vous devez avoir au moins 16 ans.")
        return false
    end

    if age > 100 then
        exports["basic"]:_notify("L'âge ne peut pas dépasser 100 ans.")
        return false
    end

    if not taille or taille < 130 or taille > 240 then
        exports["basic"]:_notify("La taille doit être comprise entre 130 cm et 240 cm.")
        return false
    end

    return true
end

local function saveIdentityToServer()
    local data = {
        firstName = prenom,
        lastName = nom,
        dateOfBirth = math.floor(birthdate / 1000),
        sex = genderIndex == 0 and "f" or "m",
        height = taille,
        nationality = nationalite,
    }

    local success = lib.callback.await("esx_identity:registerIdentity", false, data)
    return success
end

zUI.SetItems(identityMenu, function()
    zUI.Separator("Informations personnelles")

    zUI.Button("Nom", "Définir votre nom", {}, function(onSelected)
        if onSelected then
            zUI.ManageFocus(false)
            local input = lib.inputDialog('Nom', {
                { type = "input", label = "Nom", placeholder = "Dupont", required = true }
            })
            if input then
                zUI.ManageFocus(true)
                nom = input[1]
                exports["basic"]:_notify("Nom défini : " .. nom)
            end
        end
    end)

    zUI.Button("Prénom", "Définir votre prénom", {}, function(onSelected)
        if onSelected then
            zUI.ManageFocus(false)
            local input = lib.inputDialog('Prénom', {
                { type = "input", label = "Prénom", placeholder = "Jean", required = true }
            })
            if input then
                zUI.ManageFocus(true)
                prenom = input[1]
                exports["basic"]:_notify("Prénom défini : " .. prenom)
            end
        end
    end)

    zUI.Button("Date de naissance", "Sélectionnez votre date de naissance", {}, function(onSelected)
        if onSelected then
            zUI.ManageFocus(false)
            local input = lib.inputDialog('Date de naissance', {
                { type = 'date', label = 'Date de naissance', required = true, format = "DD/MM/YYYY", default = true }
            })
            if input then
                zUI.ManageFocus(true)
                birthdate = input[1]
                exports["basic"]:_notify("Date de naissance définie.")
            end
        end
    end)

    zUI.Button("Taille", "Définir votre taille (cm)", {}, function(onSelected)
        if onSelected then
            zUI.ManageFocus(false)
            local input = lib.inputDialog("Taille", {
                { type = "number", label = "Taille (en cm)", min = 130, max = 240, default = taille, required = true }
            })
            if input then
                zUI.ManageFocus(true)
                taille = tonumber(input[1])
                exports["basic"]:_notify("Taille définie : " .. taille .. " cm")
            end
        end
    end)

    zUI.Button("Nationalité", "Définir votre nationalité", {}, function(onSelected)
        if onSelected then
            zUI.ManageFocus(false)
            local input = lib.inputDialog('Nationalité', {
                { type = "input", label = "Nationalité", placeholder = "Française", required = true }
            })
            if input then
                zUI.ManageFocus(true)
                nationalite = input[1]
                exports["basic"]:_notify("Nationalité définie : " .. nationalite)
            end
        end
    end)

    zUI.List("Genre", "Choisissez votre genre", { "Femme", "Homme" }, genderIndex +1, {}, function(_, onChange, i)
        if onChange then
            genderIndex = i -1
            exports["basic"]:_notify("Genre sélectionné : " .. (genderIndex == 0 and "Homme" or "Femme"))
        end
    end)

    zUI.Button("Valider", "Valider vos informations", {}, function(onSelected)
        if onSelected then
            if validateIdentity() then
                local saved = saveIdentityToServer()
                if saved then
                    valide = true
                    exports["basic"]:_notify("Identité enregistrée avec succès.")
                    zUI.SetVisible(identityMenu, false)
                    TriggerEvent('esx_skin:openSaveableMenu',
                        function()
                            exports["basic"]:_notify("Personnalisation enregistrée.")
                        end,
                        function()
                            exports["basic"]:_notify("Personnalisation annulée.")
                        end
                    )
                else
                    exports["basic"]:_notify("Erreur lors de l'enregistrement, veuillez réessayer.")
                end
            end
        end
    end)
end)

zUI.SetOpenHandler(identityMenu, function()
    exports["basic"]:_notify("Bienvenue dans la création de votre identité.")
    local playerPed = PlayerPedId()
    FreezeEntityPosition(playerPed, true)
    showIdentityInfo = true 
end)

zUI.SetCloseHandler(identityMenu, function()
    if not valide then
        exports["basic"]:_notify("Vous devez compléter votre identité pour continuer.")
        Citizen.SetTimeout(100, function()
            zUI.SetVisible(identityMenu, true)
        end)
    else
        local playerPed = PlayerPedId()
        FreezeEntityPosition(playerPed, false)
        showIdentityInfo = false 
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
            zUI.SetVisible(identityMenu, true)
        end
    end
end)


RegisterCommand("openIdentite", function()
    local playerPed = PlayerPedId()
    local x, y, z, heading = -811.7599, 175.1936, 75.7454, 107.1220
    SetEntityCoords(playerPed, x, y, z, false, false, false, true)
    SetEntityHeading(playerPed, heading)
    zUI.SetVisible(identityMenu, true)
end)
