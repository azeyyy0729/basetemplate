local Active = false

local sub_b0b5 = { 
    "MP_Plane_Passenger_1", "MP_Plane_Passenger_2", "MP_Plane_Passenger_3", 
    "MP_Plane_Passenger_4", "MP_Plane_Passenger_5", "MP_Plane_Passenger_6", "MP_Plane_Passenger_7"
}


local function applyPedVariations(ped, variations)
    for _, v in ipairs(variations) do
        if v[1] ~= 2 then
            SetPedComponentVariation(ped, v[1], v[2], 0, 0) 
        else
            SetPedComponentVariation(ped, v[1], v[2], 1, 1) 
        end
    end
    for i = 0, 8 do
        ClearPedProp(ped, i)
    end
end


local function setPedOutfit(ped, outfitType)
    local outfits = {
        [0] = {{0, 21}, {2, 9}, {3, 1}, {4, 9}, {6, 4}, {8, 15}, {11, 10}},
        [1] = {{0, 13}, {2, 5}, {3, 1}, {4, 10}, {6, 10}, {7, 11}, {8, 13}, {11, 10}},
        [2] = {{0, 15}, {2, 1}, {3, 1}, {4, 0}, {6, 1}, {8, 2}, {11, 6}},
        [3] = {{0, 14}, {2, 5}, {3, 3}, {4, 1}, {6, 11}, {8, 2}, {11, 3}},
        [4] = {{0, 18}, {2, 15}, {3, 15}, {4, 2}, {6, 4}, {7, 4}, {8, 3}, {11, 4}},
        [5] = {{0, 27}, {2, 7}, {3, 11}, {4, 4}, {6, 13}, {7, 5}, {8, 3}, {11, 2}},
        [6] = {{0, 16}, {2, 15}, {3, 3}, {4, 5}, {6, 2}, {8, 2}, {11, 3}}
    }

    local selectedOutfit = outfits[outfitType] or outfits[0]
    applyPedVariations(ped, selectedOutfit)
end

RegisterNetEvent('cs:introCinematic:start', function()
    local plyrId = PlayerPedId()
    local gender = IsPedModel(plyrId, "mp_m_freemode_01")
    
    local cutsceneType = gender and 31 or 103
    RequestCutsceneWithPlaybackList("MP_INTRO_CONCAT", cutsceneType, 8)

    while not HasCutsceneLoaded() do Wait(10) end

    local entityModel = GetEntityModel(plyrId)
    local cutsceneEntity = gender and 'MP_Male_Character' or 'MP_Female_Character'

    RegisterEntityForCutscene(0, cutsceneEntity, 3, entityModel, 0)
    RegisterEntityForCutscene(plyrId, cutsceneEntity, 0, 0, 0)
    SetCutsceneEntityStreamingFlags(cutsceneEntity, 0, 1)

    local oppositeGenderEntity = RegisterEntityForCutscene(0, gender and "MP_Female_Character" or "MP_Male_Character", 3, 0, 64)
    NetworkSetEntityInvisibleToNetwork(oppositeGenderEntity, true)

    local ped = {}
    for i = 0, 6 do
        local isFemale = (i % 2 == 1)
        local model = isFemale and `mp_f_freemode_01` or `mp_m_freemode_01`
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(10) end
        ped[i] = CreatePed(26, model, -1117.7778, -1557.6249, 3.3819, 0.0, false, false)
        SetEntityAsMissionEntity(ped[i], true, true)
        setPedOutfit(ped[i], i)
        RegisterEntityForCutscene(ped[i], sub_b0b5[i], 0, 0, 64)
    end

    NewLoadSceneStartSphere(-1212.79, -1673.52, 7, 1000, 0)
    SetWeatherTypeNow("EXTRASUNNY")
    StartCutscene(4)
    Wait(8000)
    TriggerEvent('sound:play', 'airfrance', 0.6)
    Wait(26520) -- Durée de la cinématique

    for i = 0, 6 do
        DeleteEntity(ped[i])
    end

    PrepareMusicEvent("AC_STOP")
    TriggerMusicEvent("AC_STOP")
    StopCutsceneImmediately()

    DoScreenFadeOut(250)
    Wait(250)

    ClearPedWetness(plyrId)
    SetEntityCoords(plyrId, CodeStudio.SpawnPedLoc)

    DoScreenFadeIn(1000)
end)

