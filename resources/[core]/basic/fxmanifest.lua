fx_version 'cerulean'
game 'gta5'
author 'Azey'
description 'All'
version '0.0.1'
lua54 "yes"

files {
    "zUI/menus/theme.json",
    "zUI/notifications/theme.json",
    "zUI/contextMenus/theme.json",
    "zUI/modals/theme.json",
    "zUI/user-interface/build/index.html",
    "zUI/user-interface/build/**/*",
}

ui_page "zUI/user-interface/build/index.html"

client_scripts {
    "zUI/*.lua",
    "zUI/items/*.lua",
    "zUI/menus/_init.lua",
    "zUI/menus/menu.lua",
    "zUI/menus/methods/*.lua",
    "zUI/menus/functions/*.lua",
    "zUI/notifications/*.lua",
    "zUI/contextMenus/components/*.lua",
    "zUI/contextMenus/*.lua",
    "zUI/contextMenus/functions/*.lua",
    "zUI/modals/*.lua",
}

shared_scripts {
    "@ox_lib/init.lua", 
    "@es_extended/imports.lua",
    "shared/*.lua",
}

server_scripts {
	"@oxmysql/lib/MySQL.lua",
    "addon/**/server/*.lua",
    "lib/logs.lua",
}

client_scripts {
    "lib/function.lua",
    "addon/**/client/*.lua",
}
