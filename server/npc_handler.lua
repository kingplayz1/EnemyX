-- EnemyX Server NPC Handler
-- Handles NPC-related events and logic

local EnemyX = require 'shared/constants'
local Utils = require 'shared/utils'
local EventSystem = require 'core.events'

local NPCHandler = {}
NPCHandler.__index = NPCHandler

-- Create a new NPC handler instance
function NPCHandler:new(dependencies)
    local self = setmetatable({}, NPCHandler)
    self.eventSystem = dependencies.eventSystem
    self.entityManager = dependencies.entityManager
    self.configLoader = dependencies.configLoader
    self.constants = dependencies.constants
    self.utils = dependencies.utils
    self.initialized = false
    self.npcModule = nil  -- Will be set when NPC module loads

    return self
end

-- Initialize the NPC handler
function NPCHandler:Initialize()
    if self.initialized then return end

    print("[EnemyX Server NPC Handler] Initializing...")

    -- Wait for NPC module to be available
    Citizen.CreateThread(function()
        while not self.npcModule do
            -- Try to get NPC module from exports
            local resourceState = GetResourceState('enemyx')
            if resourceState == 'started' then
                self.npcModule = exports['enemyx'] and exports['enemyx']:GetNPCModule()
            end
            Citizen.Wait(100)
        end
        print("[EnemyX Server NPC Handler] NPC module acquired")
    end)

    -- Set up event listeners
    self:_SetupEventListeners()

    self.initialized = true
    print("[EnemyX Server NPC Handler] Initialized")
end

-- Set up event listeners
function NPCHandler:_SetupEventListeners()
    -- Listen for NPC spawn/death events
    self.eventSystem:on(EnemyX.Events.ENEMY_SPAWNED, function(data)
        self:_HandleEnemySpawned(data)
    end)

    self.eventSystem:on(EnemyX.Events.ENEMY_DIED, function(data)
        self:_HandleEnemyDied(data)
    end)

    -- Listen for config reloads
    self.eventSystem:on(EnemyX.Events.CONFIG_RELOADED, function(newConfig, oldConfig)
        self:_OnConfigReload(newConfig, oldConfig)
    end)
end

-- Handle enemy spawned event
function NPCHandler:_HandleEnemySpawned(data)
    -- This could be used for tracking, achievements, or triggering events
    -- For V1, we'll just log it and potentially notify AI Director
    print(("[EnemyX Server NPC Handler] Enemy spawned: %s (%s) at %.2f, %.2f, %.2f"):format(
        data.enemyType or "unknown",
        data.model or "unknown",
        data.coords.x, data.coords.y, data.coords.z))

    -- In V2, this could notify the AI Director about spawns
    -- For now, just a placeholder
end

-- Handle enemy died event
function NPCHandler:_HandleEnemyDied(data)
    -- This could be used for tracking kills, dropping loot, or triggering events
    print(("[EnemyX Server NPC Handler] Enemy died: %s (%s) killed by %s"):format(
        data.enemyType or "unknown",
        data.model or "unknown",
        data.killerId or "unknown"))

    -- In V2, this could trigger reinforcements or update AI Director
    -- For now, just a placeholder
end

-- Handle configuration reload
function NPCHandler:_OnConfigReload(newConfig, oldConfig)
    print("[EnemyX Server NPC Handler] Configuration reloaded")
    -- NPC-specific config handling would go here
end

-- Public functions for spawning NPCs (used by zone handler, admin, etc.)

-- Spawn a single NPC at coordinates
function NPCHandler:SpawnNPCAt(options)
    if not options then return nil end

    -- Set defaults
    options = options or {}
    local model = options.model or EnemyX.Defaults.PED_MODEL
    local weapon = options.weapon or EnemyX.Defaults.WEAPON
    local ammo = options.ammo or EnemyX.Defaults.AMMO
    local coords = options.coords or vector3(0, 0, 0)
    local behavior = options.behavior or EnemyX.Defaults.BEHAVIOR
    local enemyType = options.enemyType or "custom"

    -- Validate coords
    if type(coords) ~= "userdata" then
        coords = vector3(coords.x or 0, coords.y or 0, coords.z or 0)
    end

    -- Trigger client event to spawn NPC (since we're on server)
    TriggerClientEvent('enemyx:client:spawnNPC', -1, {
        model = model,
        weapon = weapon,
        ammo = ammo,
        secondaryWeapon = options.secondaryWeapon,
        secondaryAmmo = options.secondaryAmmo,
        behavior = behavior,
        enemyType = enemyType,
        coords = {x = coords.x, y = coords.y, z = coords.z}
    })

    return true  -- Indicate spawn requested
end

-- Spawn a group of NPCs
function NPCHandler:SpawnGroupAt(groupName, coords, size)
    if not groupName or groupName == "" then return nil end

    coords = coords or vector3(0, 0, 0)
    if type(coords) ~= "userdata" then
        coords = vector3(coords.x or 0, coords.y or 0, coords.z or 0)
    end

    size = size or {min = 1, max = 1}
    local count = math.random(size.min, size.max)

    -- Trigger client event to spawn group
    TriggerClientEvent('enemyx:client:spawnGroup', -1, {
        groupName = groupName,
        coords = {x = coords.x, y = coords.y, z = coords.z},
        count = count
    })

    return true  -- Indicate spawn requested
end

-- Clear NPCs in area
function NPCHandler:ClearNPsInArea(coords, radius)
    coords = coords or vector3(0, 0, 0)
    if type(coords) ~= "userdata" then
        coords = vector3(coords.x or 0, coords.y or 0, coords.z or 0)
    end

    radius = radius or 50.0

    -- Trigger client event to clear area
    TriggerClientEvent('enemyx:client:clearEnemiesInArea', -1, {
        coords = {x = coords.x, y = coords.y, z = coords.z},
        radius = radius
    })

    return true  -- Indicate clear requested
end

-- Get active NPCs count
function NPCHandler:GetActiveNPCsCount()
    if self.entityManager then
        local entities = self.entityManager:GetActiveEntities()
        local count = 0
        for _, entityData in pairs(entities) do
            if entityData.isActive and entityData.type == self.constants.EntityType.PED then
                count = count + 1
            end
        end
        return count
    end
    return 0
end

return NPCHandler