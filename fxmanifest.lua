fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Nexora Scripts'
description 'Police Loot Box for Qbox & ox_inventory with dynamic police armory loot distribution'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

dependencies {
    'ox_lib',
    'ox_inventory',
    'qbx_core'
}
