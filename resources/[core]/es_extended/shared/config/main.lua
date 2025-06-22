Config = {}

-- for ox inventory, use Config.CustomInventory = "ox", for others, set to "resource_name"
Config.CustomInventory = "ox"

Config.Accounts = {
    bank = {
        label = TranslateCap("account_bank"),
        round = true,
    },
    black_money = {
        label = TranslateCap("account_black_money"),
        round = true,
    },
    money = {
        label = TranslateCap("account_money"),
        round = true,
    },
}

Config.StartingAccountMoney = { bank = 2500, money = 2500 }

Config.StartingInventoryItems = false -- table/false

Config.DefaultSpawns = { -- If you want to have more spawn positions and select them randomly uncomment commented code or add more locations
    --{ x = 2607.5173, y = 884.6102, z = 6.0816, heading = 93.4896 },
    {x = 224.9865, y = -865.0871, z = 30.2922, heading = 1.0},
    --{x = 227.8436, y = -866.0400, z = 30.2922, heading = 1.0},
    --{x = 230.6051, y = -867.1450, z = 30.2922, heading = 1.0},
    --{x = 233.5459, y = -868.2626, z = 30.2922, heading = 1.0}
}

Config.AdminGroups = {
    ["owner"] = true,
    ["admin"] = true,
}

Config.LogPaycheck = false -- Logs paychecks to a nominated Discord channel via webhook (default is false)
Config.MaxWeight = 48 -- the max inventory weight without a backpack
Config.SaveDeathStatus = true -- Save the death status of a player
Config.EnableDebug = false -- Use Debug options?

Config.DefaultJobDuty = true -- A players default duty status when changing jobs

Config.EnablePaycheck = true -- enable paycheck
Config.PaycheckInterval = 7 * 60000 -- how often to receive paychecks in milliseconds
Config.EnableSocietyPayouts = false -- pay from the society account that the player is employed at? Requirement: esx_society
Config.AllowanceForUnemployedFromCityHallAccount = false -- Do you want unemployed players to receive paychecks from your city hall account?

Config.VMSCityhall = GetResourceState("vms_cityhall") ~= "missing"
Config.VMSDocumentsV2 = GetResourceState("vms_documentsv2") ~= "missing"
Config.VMSBossMenu = GetResourceState("vms_bossmenu") ~= "missing"
Config.VMSGaragesV2 = GetResourceState("vms_garagesv2") ~= "missing"

Config.Multichar = GetResourceState("esx_multicharacter") ~= "missing"
Config.Identity = true -- Select a character identity data before they have loaded in (this happens by default with multichar)
Config.DistanceGive = 4.0 -- Max distance when giving items, weapons etc.

Config.AdminLogging = false -- Logs the usage of certain commands by those with group.admin ace permissions (default is false)

--------------------------------------------------------------------
-- DO NOT CHANGE BELOW THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING
--------------------------------------------------------------------
Config.EnableDefaultInventory = Config.CustomInventory == false -- Display the default Inventory ( F2 )

local txAdminLocale = GetConvar("txAdmin-locale", "fr")
local esxLocale = GetConvar("esx:locale", "invalid")

Config.Locale = (esxLocale ~= "invalid") and esxLocale or (txAdminLocale ~= "custom" and txAdminLocale) or "fr"
