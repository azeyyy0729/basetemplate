Config = {}

Config.Blips = {
    {name = "Location", color = 0, scale = 0.6, id = 56, pos = vector3(-1062.4418, -2740.6943, 21.3679)},  
    --{name = "Shop Idée 1", color = 0, scale = 0.6, id = 56, pos = vector3(-717.1570, -922.1028, 19.0139)}, 
    --{name = "Orpi", color = 0, scale = 0.6, id = 56, pos = vector3(-255.3022, -913.4297, 32.3135)},   
    --{name = "EDF", color = 0, scale = 0.6, id = 56, pos = vector3(-825.6256, -731.5641, 28.0549)},   
}

Config.adminGroups = {"staff" , "mod" , "admin" ,"dev", "owner"}

Config.Location = {
    ["Location 1"] = { -- Airport
        shop = vector3(-1062.4418, -2740.6943, 21.3679),
        ped = vector4(-1061.3572, -2741.2158, 21.3679, 63.6611),
        spawn = vector4(-1030.7371, -2731.1560, 20.1065, 236.5129),
        vehicles = {
            {label = "BMX", name = "bmx", price = 4,  image = "https://i.ibb.co/cwmcTyF/BMX.webp"},
            {label = "Faggio", name = "faggio2", price = 10,  image = "https://i.ibb.co/5M90mBQ/faggio.webp"}
        },
    },
}

Config.Commande = {    
    PedPos = {
        pos_1 = {
            ped = vector4(-737.1636, -916.8389, 19.5849, 110.6315),
            marker = vector3(-738.1085, -918.2120, 19.5119)
        },
        pos_2 = {
            ped = vector4(212.9780, -796.8253, 30.8630, 42.5141),
            marker = vector3(212.9780, -796.8253, 30.8630)
        },
        pos_3 = {
            ped = vector4(212.9780, -796.8253, 30.8630, 42.5141),
            marker = vector3(212.9780, -796.8253, 30.8630)
        },
        pos_4 = {
            ped = vector4(212.9780, -796.8253, 30.8630, 42.5141),
            marker = vector3(212.9780, -796.8253, 30.8630)
        },
    },
    items = {
        { label = "bread", name = "Pain", price = 100, quantity = 0 },
        { label = "water", name = "Eau", price = 50, quantity = 0 },
        { label = "sandwich", name = "Sandwich", price = 75, quantity = 0 }
    }
}

Config.Shops = {
    ['lidl'] = {
        label = 'Lidl',
        coffre = {
            coords = vector3(-709.7682, -904.1822, 19.2156)
        },
        bossMenu = {
            enabled = true,
            coords = vector3(-710.0888, -906.7722, 19.2156),
        },
        locations = {
            stash = {
                coords = vector3(-718.0144, -911.5319, 19.2156),
            },
            shop = {
                coords = vector3(-707.4089, -914.6390, 19.2156),
            }
        }
    }
}

Config.F6 = {
    LTD = {
        lidl = {job = "lidl", banner = "https://i.ibb.co/M5N59wcB/Des-pictogrammes-clients-Une-silhouette-de-famille-un-client-heureux-ou-une-maison-pour-voquer-la-pr.png"}
    },
}

Config.Orpi = {
    VenteEntreprise = {marker = vector3(-229.0143, -910.0706, 32.3084)}
}

Config.EDF = {
    distance = 1.5,
    car = "minivan",
    Pay = math.random(10,20),
    account = 'bank',
    spawnveh = vector4(-829.1070, -757.0458, 22.3568, 88.1725),
    ped = vector4(-825.6256, -731.5641, 28.0549, 184.5158), 
    marker = vector3(-825.6180, -731.9606, 28.0549),
    clothes = {
        male = {
            ['tshirt_1'] = 0, ['tshirt_2'] = 0,
            ['torso_1'] = 122, ['torso_2'] = 0,
            ['arms'] = 1, ['pants_1'] = 5,
        },
        female = {
            ['tshirt_1'] = 15, ['tshirt_2'] = 0,
            ['torso_1'] = 4, ['torso_2'] = 14,
            ['arms'] = 4, ['pants_1'] = 25, ['pants_2'] = 1,
            ['shoes_1'] = 16, ['shoes_2'] = 4,
        }
    },
    props = {
        {prop = 'prop_streetlight_01', scenario = 'PROP_HUMAN_SEAT_BENCH', position = vector3(-825.55, -731.86, 27.07)},
        {prop = 'prop_streetlight_01b', scenario = 'PROP_HUMAN_SEAT_BENCH', position = vector3(-820.0, -725.0, 27.5)},
        {prop = 'prop_streetlight_03b', scenario = 'PROP_HUMAN_SEAT_BENCH', position = vector3(-830.0, -735.0, 27.0)},
        {prop = 'prop_telegraph_01b', scenario = 'PROP_HUMAN_SEAT_BENCH', position = vector3(350.46, 932.27, 203.43)}
    }
}
