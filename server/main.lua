-- EnemyX Server Main Entry Point
-- Initializes server-side systems and handles framework integration

local EnemyX = require 'shared/constants'
local Utils = require 'shared/utils'
local EventSystem = require 'core/events'
local ConfigLoader = require 'core/config_loader'
local EntityManager = require 'core/entity_manager'
local ModuleLoader = require 'core/module_loader'
local ZoneHandler = require 'server/zone_handler'
local NPCHandler = require 'server/npc_handler'

-- Initialize core systems
local eventSystem = EventSystem:new()
local configLoader = ConfigLoader:new()
local entityManager = EntityManager:new()
local moduleLoader = ModuleLoader:new(eventSystem, configLoader, entityManager)
local zoneHandler = ZoneHandler:new({eventSystem = eventSystem, entityManager = entityManager, configLoader = configLoader, constants = EnemyX, utils = Utils})
local npcHandler = NPCHandler:new({eventSystem = eventSystem, entityManager = entityManager, configLoader = configLoader, constants = EnemyX, utils = Utils})

-- Framework adapter
local frameworkAdapter = nil

-- Server state
local isInitialized = false

-- Initialize EnemyX
local function Initialize()
    if isInitialized then return end

    print("[EnemyX] Initializing server...")

    -- Load configuration
    configLoader:LoadAll()

    -- Initialize entity manager
    entityManager:new()

    -- Initialize framework adapter
    _InitializeFrameworkAdapter()

    -- Load modules
    moduleLoader:LoadAllModules()

    -- Start modules
    moduleLoader:StartAll()

    -- Initialize handlers
    zoneHandler:Initialize()
    npcHandler:Initialize()

    -- Set up event listeners
    _SetupEventListeners()

    -- Set up player connection handlers
    _SetupPlayerHandlers()

    isInitialized = true
    print("[EnemyX] Server initialized successfully")
end

-- Initialize framework adapter based on configuration or auto-detection
function _InitializeFrameworkAdapter()
    local frameworkName = configLoader:Get("Framework", "auto")

    if frameworkName == "auto" then
        frameworkName = _DetectFramework()
    end

    print(("[EnemyX] Detected framework: %s"):format(frameworkName))

    frameworkAdapter = _LoadFrameworkAdapter(frameworkName)
    if not frameworkAdapter then
        print(("[EnemyX] Warning: No adapter for framework %s, using standalone"):format(frameworkName))
        frameworkAdapter = _LoadFrameworkAdapter("standalone")
    end

    -- Initialize the adapter
    if frameworkAdapter and type(frameworkAdapter.Initialize) == "function" then
        frameworkAdapter.Initialize({
            eventSystem = eventSystem,
            configLoader = configLoader,
            entityManager = entityManager,
            constants = EnemyX,
            utils = Utils
        })
    end
end

-- Auto-detect framework by checking for known resources
function _DetectFramework()
    -- Check for ESX
    if GetResourceState('es_extended') == 'started' then
        return 'esx'
    end

    -- Check for QBCore
    if GetResourceState('qb-core') == 'started' then
        return 'qbcore'
    end

    -- Check for QBox
    if GetResourceState('qbox') == 'started' then
        return 'qbox'
    end

    -- Check for vRP
    if GetResourceState('vrp') == 'started' then
        return 'vrp'
    end

    -- Check for ND (NoPixel-inspired)
    if GetResourceState('nd_core') == 'started' then
        return 'nd'
    end

    -- Default to standalone
    return 'standalone'
end

-- Load framework adapter module
function _LoadFrameworkAdapter(frameworkName)
    local adapterPath = string.format("adapters/%s", frameworkName)
    local success, adapter = pcall(function()
        return require(adapterPath)
    end)

    if success and type(adapter) == "table" then
        return adapter
    end

    return nil
end

-- Set up event listeners
function _SetupEventListeners()
    -- Listen for config reloads
    eventSystem:on(EnemyX.Events.CONFIG_RELOADED, function()
        print("[EnemyX] Configuration reloaded on server")
        configLoader:Reload()
        -- Notify framework adapter
        if frameworkAdapter and type(frameworkAdapter.OnConfigReload) == "function" then
            frameworkAdapter.OnConfigReload(configLoader:Dump())
        end
        -- Notify handlers
        zoneHandler:OnConfigReload(configLoader:Dump(), {})
        npcHandler:OnConfigReload(configLoader:Dump(), {})
    end)

    -- Listen for enemy spawns from clients (if authoritative)
    eventSystem:on(EnemyX.Events.ENEMY_SPAWNED, function(data)
        -- Server might want to validate or broadcast to other clients
        -- For now, just pass through
    end)

    -- Listen for enemy deaths
    eventSystem:on(EnemyX.Events.ENEMY_DIED, function(data)
        -- Handle death events (could give XP, drop loot, etc.)
    end)

    -- Admin commands
    RegisterCommand('enemyxstatus', function(source, args, raw)
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 255, 0},
            args = {"[EnemyX]", "Status check - see server console"}
        })
        local status = moduleLoader:GetStatus()
        print(("[EnemyX] Server Status: %d/%d modules loaded"):format(
            status.count, status.total))
        for _, moduleName in ipairs(status.loaded) do
            print(("  - %s"):format(moduleName))
        end
    end, false)

    RegisterCommand('enemyxspawn', function(source, args, raw)
        -- Simple spawn command for testing
        local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(source)))
        local target = vector3(x + 5, y, z)
        TriggerClientEvent('enemyx:client:spawnNPC', source, {
            model = "g_m_y_mexgoon_01",
            weapon = "WEAPON_ASSAULTRIFLE",
            coords = {x = target.x, y = target.y, z = target.z}
        })
    end, false)

    RegisterCommand('enemyxclear', function(source, args, raw)
        local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(source)))
        TriggerClientEvent('enemyx:client:clearEnemiesInArea', source, {
            coords = {x = x, y = y, z = z},
            radius = 50.0
        })
    end, false)
end

-- Set up player connection handlers
function _SetupPlayerHandlers()
    -- Player connected
    AddEventHandler('playerConnecting', function(name, setCallback, deferrals)
        deferrals.defer()
        Wait(0)
        deferrals.done()
    end)

    -- Player joined
    AddEventHandler('playerJoined', function(source)
        -- Initialize player data if needed
        print(("[EnemyX] Player %s joined"):format(GetPlayerName(source)))
    end)

    -- Player dropped
    AddEventHandler('playerDropped', function(source, reason)
        -- Cleanup player data if needed
        print(("[EnemyX] Player %s dropped (%s)"):format(GetPlayerName(source), reason))
    end)
end

-- Export functions for other resources
exports('GetFrameworkAdapter', function()
    return frameworkAdapter
end)

exports('IsInitialized', function()
    return isInitialized
end)

-- Start initialization when resource starts
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        Initialize()
    end
end)

-- Cleanup when resource stops
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        print("[EnemyX] Shutting down server...")
        if frameworkAdapter and type(frameworkAdapter.Cleanup) == "function" then
            frameworkAdapter.Cleanup()
        end
        moduleLoader:CleanupAll()
        entityManager:CleanupAll()
        zoneHandler:Cleanup()
        npcHandler:Cleanup()
        isInitialized = false
    end
end)

-- Handle config reload command from server console
RegisterCommand('enemyxreload', function(source, args, raw)
    if source == 0 then  -- Console command
        configLoader:Reload()
        print("[EnemyX] Configuration reloaded via console command")
        -- Notify listeners
        eventSystem:emit(EnemyX.Events.CONFIG_RELOADED, {})
    end
end, false)