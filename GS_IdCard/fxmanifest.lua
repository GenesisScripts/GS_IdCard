fx_version 'cerulean'
game 'gta5'
use_experimental_fxv2_oal 'yes'
lua54 'yes'

author "Genesis ID Script"
description 'ID system for ESX to prove identity.'
version '1.0.0'

ui_page 'web/index.html'

shared_script {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua',
}

server_scripts {
    'server.lua',
    '@oxmysql/lib/MySQL.lua'
}


files {
    'web/index.html',
    'web/*.css',
    'web/*.js',
    'web/img/*.png',
    'web/stream/*.ydr',
    'web/fonts/roboto/*.woff',
    'web/fonts/roboto/*.woff2',
}


dependencies {
    'ox_lib',
    'ox_inventory',
    'oxmysql',
}
