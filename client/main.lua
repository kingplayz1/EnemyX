-- EnemyX Client Main Entry Point
-- Initializes client-side systems and starts update loops

local EnemyX = require 'shared/constants'
local Utils = require 'shared/utils'
local EventSystem = require 'core/events'
local ConfigLoader = require 'core/config_loader'
local EntityManager = require 'core/entity_manager'
local ModuleLoader = require 'core/module_loader'
local ZoneHandler = require 'client/zone_handler'
local NPCHandler = require 'client/npc_handler'

-- Initialize core systems
local eventSystem = EventSystem:new()
local configLoader = ConfigLoader:new()
local entityManager = EntityManager:new()
local moduleLoader = ModuleLoader:new(eventSystem, configLoader, entityManager)
local zoneHandler = ZoneHandler:new({eventSystem = eventSystem, entityManager = entityManager, configLoader = configLoader, constants = EnemyX, utils = Utils})
local npcHandler = NPCHandler:new({eventSystem = eventSystem, entityManager = entityManager, configLoader = configLoader, constants = EnemyX, utils = Utils})

-- Client state
local isInitialized = false
local localPlayerPed = nil
local localPlayerCoords = nil
local updateTimer = 0
local debugOverlayEnabled = false

-- Initialize EnemyX
local function Initialize()
    if isInitialized then return end

    print("[EnemyX] Initializing client...")

    -- Load configuration
    configLoader:LoadAll()

    -- Initialize entity manager
    entityManager:new()

    -- Initialize handlers
    zoneHandler:Initialize()
    npcHandler:Initialize()

    -- Load modules
    moduleLoader:LoadAllModules()

    -- Start modules
    moduleLoader:StartAll()

    -- Set up event listeners
    _SetupEventListeners()

    -- Set up update loop
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            _UpdateLoop()
        end
    end)

    isInitialized = true
    print("[EnemyX] Client initialized successfully")
end

-- Set up event listeners
function _SetupEventListeners()
    -- Listen for config reloads (from admin panel or server)
    eventSystem:on(EnemyX.Events.CONFIG_RELOADED, function()
        print("[EnemyX] Configuration reloaded")
        configLoader:Reload()
        -- Modules may need to reconfigure based on new settings
        for _, moduleName in ipairs(moduleLoader.LoadOrder) do
            local module = moduleLoader:GetModule(moduleName)
            if module and type(module.OnConfigReload) == "function" then
                module.OnConfigReload(configLoader:Dump())
            end
        end
    end)

    -- Listen for player entering/exiting zones
    eventSystem:on(EnemyX.Events.PLAYER_ENTERED_ZONE, function(data)
        -- Handle zone entry (could trigger encounters, etc.)
    end)

    eventSystem:on(EnemyX.Events.PLAYER_EXITED_ZONE, function(data)
        -- Handle zone exit
    end)

    -- Debug commands
    RegisterCommand('enemyxdebug', function()
        debugOverlayEnabled = not debugOverlayEnabled
        print(("[EnemyX] Debug overlay: %s"):format(debugOverlayEnabled and "ON" or "OFF"))
    end, false)

    -- Server-triggered debug toggle
    RegisterNetEvent('enemyx:client:toggleDebug', function()
        debugOverlayEnabled = not debugOverlayEnabled
        print(("[EnemyX] Debug overlay toggled via server: %s"):format(debugOverlayEnabled and "ON" or "OFF"))
    end)

    RegisterCommand('enemyxreload', function()
        configLoader:Reload()
        print("[EnemyX] Configuration reloaded via command")
    end, false)

    RegisterCommand('enemyxstatus', function()
        local status = moduleLoader:GetStatus()
        print(("[EnemyX] Status: %d/%d modules loaded"):format(
            status.count, status.total))
        for _, moduleName in ipairs(status.loaded) do
            print(("  - %s"):format(moduleName))
        end
    end, false)
end

-- Main update loop
function _UpdateLoop()
    if not isInitialized then return end

    local currentTime = GetGameTimer()
    local playerPed = PlayerPedId()

    -- Update player state
    if playerPed and playerPed ~= 0 then
        localPlayerPed = playerPed
        localPlayerCoords = GetEntityCoords(localPlayerPed, true)
    end

    -- Update entity distances to player
    if localPlayerCoords then
        entityManager:UpdatePlayerDistances(localPlayerCoords)
    end

    -- Update entities that need it
    local entitiesToUpdate = entityManager:GetEntitiesForUpdate(currentTime)
    for _, entityId in ipairs(entitiesToUpdate) do
        eventSystem:emit(EnemyX.Events.ENEMY_UPDATED, {
            entityId = entityId,
            currentTime = currentTime
        })
    end

    -- Update timer for periodic tasks
    updateTimer = updateTimer + 1
    if updateTimer >= 100 then  -- Every 100 frames (~1.6 seconds at 60fps)
        updateTimer = 0
        _PeriodicUpdate()
    end
end

-- Periodic updates (less frequent than main loop)
function _PeriodicUpdate()
    -- Could be used for cleanup, stats, etc.
    -- For now, just a placeholder
end

-- Draw debug overlay
function _DrawDebugOverlay()
    if not debugOverlayEnabled or not localPlayerCoords then return end

    local yOffset = 0.02
    local lineHeight = 0.02

    -- Draw title
    DrawTxt("EnemyX Debug", 0.02, 0.02 + yOffset, 0.5, {255, 255, 0, 255})
    yOffset = yOffset + lineHeight

    -- Draw player position
    DrawTxt(string.format("Player: %s", Utils.FormatVector(localPlayerCoords)),
        0.02, 0.02 + yOffset, 0.4, {255, 255, 255, 255})
    yOffset = yOffset + lineHeight

    -- Draw active entity count
    local activeEntities = entityManager:GetActiveEntities()
    DrawTxt(string.format("Active Entities: %d", #activeEntities),
        0.02, 0.02 + yOffset, 0.4, {255, 255, 255, 255})
    yOffset = yOffset + lineHeight

    -- Draw module status
    local status = moduleLoader:GetStatus()
    DrawTxt(string.format("Modules: %d/%d", status.count, status.total),
        0.02, 0.02 + yOffset, 0.4, {255, 255, 255, 255})
    yOffset = yOffset + lineHeight

    -- Draw performance info
    if localPlayerPed and localPlayerPed ~= 0 then
        DrawTxt(string.format("Player Ped: %d", localPlayerPed),
            0.02, 0.02 + yOffset, 0.4, {200, 200, 200, 255})
        yOffset = yOffset + lineHeight
    end
end

-- Text drawing helper
function DrawTxt(text, x, y, scale, color)
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(color[1], color[2], color[3], color[4] or 255)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

-- Export functions for other resources and admin panel
exports('SpawnEnemy', function(options)
    if not isInitialized then
        print("[EnemyX] Warning: SpawnEnemy called before initialization")
        Initialize()
    end

    -- Validate and set defaults
    options = options or {}
    local model = options.model or EnemyX.Defaults.PED_MODEL
    local weapon = options.weapon or EnemyX.Defaults.WEAPON
    local ammo = options.ammo or EnemyX.Defaults.AMMO
    local coords = options.coords or GetEntityCoords(localPlayerPed, true)
    local behavior = options.behavior or EnemyX.Defaults.BEHAVIOR
    local enemyType = options.enemyType or "custom"

    -- Create entity through entity manager
    local entityId = entityManager:CreateEntity(
        EntityManager.EntityType.PED,
        model,
        coords,
        true,  -- networked
        {
            weapon = weapon,
            ammo = ammo,
            behavior = behavior,
            enemyType = enemyType,
            health = EnemyX.Defaults.HEALTH,
            armor = EnemyX.Defaults.ARMOR,
            accuracy = EnemyX.Defaults.ACCURACY,
            relationship = EnemyX.Defaults.RELATIONSHIP
        }
    )

    -- Notify modules about new enemy
    eventSystem:emit(EnemyX.Events.ENEMY_SPAWNED, {
        entityId = entityId,
        model = model,
        weapon = weapon,
        behavior = behavior,
        enemyType = enemyType,
        coords = coords
    })

    return entityId
end)

exports('SpawnGroup', function(groupName, coords, sizeOverride)
    if not isInitialized then
        print("[EnemyX] Warning: SpawnGroup called before initialization")
        Initialize()
    end

    -- Get group configuration
    local groupConfig = configLoader:Get(string.format("Groups.%s", groupName))
    if not groupConfig then
        print(("[EnemyX] Warning: Group %s not found in config"):format(groupName))
        return nil
    end

    -- Use coords or default to player position
    coords = coords or GetEntityCoords(localPlayerPed, true)
    sizeOverride = sizeOverride or {}

    -- Determine group size
    local sizeMin = sizeOverride.min or groupConfig.size.min or 1
    local sizeMax = sizeOverride.max or groupConfig.size.max or 1
    local groupSize = math.random(sizeMin, sizeMax)

    local spawnedEntities = {}

    -- Spawn each member of the group
    for i = 1, groupSize do
        -- Determine role in group (simple round-robin for now)
        local roleIndex = ((i - 1) % #groupConfig.roles) + 1
        local role = groupConfig.roles[roleIndex]

        -- Get ped model for this role
        local model = role.ped or groupConfig.defaultPed or EnemyX.Defaults.PED_MODEL

        -- Get weapon for this role
        local weapon = role.weapon or groupConfig.defaultWeapon or EnemyX.Defaults.WEAPON
        local ammo = role.ammo or groupConfig.defaultAmmo or EnemyX.Defaults.AMMO

        -- Calculate offset for formation
        local offset = vector3(0, 0, 0)
        if role.offset then
            offset = vector3(role.offset.x or 0, role.offset.y or 0, role.offset.z or 0)
        end

        local spawnCoords = vector3(
            coords.x + offset.x,
            coords.y + offset.y,
            coords.z + offset.z
        )

        -- Create entity
        local entityId = entityManager:CreateEntity(
            EntityManager.EntityType.PED,
            model,
            spawnCoords,
            true,  -- networked
            {
                weapon = weapon,
                ammo = ammo,
                behavior = role.behavior or groupConfig.defaultBehavior or EnemyX.BehaviorType.AGGRESSIVE,
                enemyType = groupConfig.enemyType or "custom",
                health = role.health or groupConfig.defaultHealth or EnemyX.Defaults.HEALTH,
                armor = role.armor or groupConfig.defaultArmor or EnemyX.Defaults.ARMOR,
                accuracy = role.accuracy or groupConfig.defaultAccuracy or EnemyX.Defaults.ACCURACY,
                relationship = groupConfig.relationship or EnemyX.Relationship.HOSTILE,
                groupId = string.format("%s_%s", groupName, Utils.GenerateID()),
                groupRole = role.name or ("role_" .. roleIndex)
            }
        )

        table.insert(spawnedEntities, entityId)
    end

    -- Notify modules about group spawn
    eventSystem:emit(EnemyX.Events.ENEMY_SPAWNED, {
        entityIds = spawnedEntities,
        groupName = groupName,
        groupSize = groupSize,
        coords = coords
    })

    return spawnedEntities
end)

exports('CreateZone', function(zoneConfig)
    if not isInitialized then
        print("[EnemyX] Warning: CreateZone called before initialization")
        Initialize()
    end

    -- Validate zone config
    zoneConfig = zoneConfig or {}
    if not zoneConfig.name then
        print("[EnemyX] Warning: Zone config must have a name")
        return nil
    end

    -- Add to configuration
    configLoader:Set(string.format("Zones.%s", zoneConfig.name), zoneConfig)

    -- Notify zone module if loaded
    local zoneModule = moduleLoader:GetModule("zone")
    if zoneModule and type(zoneModule.OnZoneAdded) == "function" then
        zoneModule.OnZoneAdded(zoneConfig.name, zoneConfig)
    end

    -- Emit event
    eventSystem:emit(EnemyX.Events.ZONE_ENTERED, {
        zoneName = zoneConfig.name,
        config = zoneConfig
    })

    return zoneConfig.name
end)

exports('RemoveEnemy', function(entityId)
    if not isInitialized then return false end
    return entityManager:RemoveEntity(entityId)
end)

exports('ClearEnemiesInArea', function(coords, radius)
    if not isInitialized then return 0 end
    coords = coords or GetEntityCoords(localPlayerPed, true)
    radius = radius or 50.0

    local removedCount = 0
    local entities = entityManager:GetActiveEntities()

    for entityId, entityData in pairs(entities) do
        if entityData.isActive and entityData.type == EntityManager.EntityType.PED then
            local dist = Utils.GetDistance(entityData.coords, coords, true)
            if dist <= radius then
                if entityManager:RemoveEntity(entityId) then
                    removedCount = removedCount + 1
                end
            end
        end
    end

    return removedCount
end)

exports('GetActiveEnemies', function()
    if not isInitialized then return {} end
    local enemies = {}
    local entities = entityManager:GetActiveEntities()

    for entityId, entityData in pairs(entities) do
        if entityData.isActive and entityData.type == EntityManager.EntityType.PED then
            enemies[entityId] = {
                entityId = entityId,
                model = entityData.model,
                coords = entityData.coords,
                health = GetEntityHealth(entityData.properties.handle or 0),
                maxHealth = GetEntityMaxHealth(entityData.properties.handle or 0),
                armor = GetPedArmour(entityData.properties.handle or 0),
                behavior = entityData.properties.behavior or "unknown",
                enemyType = entityData.properties.enemyType or "unknown",
                distanceToPlayer = entityData.distanceToPlayer or 0
            }
        end
    end

    return enemies
end)

exports('IsInitialized', function()
    return isInitialized
end)

exports('SpawnVehicle', function(options)
    if not isInitialized then
        print("[EnemyX] Warning: SpawnVehicle called before initialization")
        Initialize()
    end

    options = options or {}
    local model = options.model or "schafter2"
    local coords = options.coords or GetEntityCoords(localPlayerPed, true)
    local networked = options.networked ~= false

    local entityId = entityManager:CreateEntity(
        EntityManager.EntityType.VEHICLE,
        model,
        coords,
        networked,
        {
            color = options.color
        }
    )

    return entityId
end)

-- Start initialization when resource starts
AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        Initialize()
    end
end)

-- Cleanup when resource stops
AddEventHandler('onClientResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        print("[EnemyX] Shutting down client...")
        moduleLoader:CleanupAll()
        entityManager:CleanupAll()
        zoneHandler:Cleanup()
        npcHandler:Cleanup()
        isInitialized = false
    end
end)