fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'ownz and Dlznn'
description 'discord.gg/ownzshop'
version '1.0.0'

ui_page 'html/ui.html'

files {
	'html/style.css',
	'html/main.js',
	'html/ui.html',
}

shared_scripts {
	'@es_extended/imports.lua',
	'@ox_lib/init.lua'
}

client_scripts {
	"stream/hud_reticle.gfx",
    "stream/minimap.gfx",
	'client.lua'
}