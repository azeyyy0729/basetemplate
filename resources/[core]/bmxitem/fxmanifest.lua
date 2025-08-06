fx_version 'cerulean'
game 'gta5'
author 'Azey'
description 'All'
version '0.0.1'
lua54 "yes"

shared_scripts {
    "@ox_lib/init.lua", 
    "@es_extended/imports.lua",
    "shared/*.lua",
}

server_scripts {
	"@oxmysql/lib/MySQL.lua",
    "addon/**/server/*.lua",
}

client_scripts {
    "addon/**/client/*.lua",
}

dependencies {
    'ox_target',
}