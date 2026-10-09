fx_version 'cerulean'
game 'gta5'

author 'EnemyX Team'
description 'Universal AI Encounter & NPC Management Framework for FiveM'
version '1.0.0'

-- Client scripts
client_script 'shared/@shared.lua'  -- Will be auto-loaded by FiveM
client_script 'client/main.lua'

-- Server scripts
server_script 'server/main.lua'

-- Shared scripts
shared_script 'shared/constants.lua'
shared_script 'shared/utils.lua'

-- NUI files for admin panel
ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/app.js'
}

-- Dependencies
dependency 'mysql-async'  -- Optional, for V2 persistence

-- Export functions
exports {
    'SpawnEnemy',
    'SpawnGroup',
    'SpawnVehicle',
    'CreateZone',
    'RemoveEnemy',
    'ClearEnemiesInArea',
    'GetActiveEnemies'
}