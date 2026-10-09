-- EnemyX Client NPC Handler
-- Handles NPC-related events from server

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

    return self
end

-- Initialize the NPC handler
function NPCHandler:Initialize()
    if self.initialized then return end

    print("[EnemyX NPC Handler] Initializing...")

    -- Set up event listeners for server-triggered events
    self:_SetupEventListeners()

    self.initialized = true
    print("[EnemyX NPC Handler] Initialized")
end

-- Set up event listeners
function NPCHandler:_SetupEventListeners()
    -- Listen for direct NPC spawn requests
    RegisterNetEvent('enemyx:client:spawnNPC', function(data)
        self:_HandleDirectNPCSpawn(data)
    end)

    -- Listen for group spawn requests
    RegisterNetEvent('enemyx:client:spawnGroup', function(data)
        self:_HandleGroupSpawn(data)
    end)

    -- Listen for clear enemies requests
    RegisterNetEvent('enemyx:client:clearEnemiesInArea', function(data)
        self:_HandleClearEnemies(data)
    end)

    -- Listen for debug overlay toggle
    RegisterNetEvent('enemyx:client:setDebugOverlay', function(data)
        self:_HandleSetDebugOverlay(data)
    end)

    -- Listen for admin panel toggle
    RegisterNetEvent('enemyx:client:toggleAdmin', function()
        exports['enemyx']:ToggleNUI()
    end)
end

-- Handle direct NPC spawn
function NPCHandler:_HandleDirectNPCSpawn(data)
    -- Validate data
    if not data or not data.model then
        print("[EnemyX NPC Handler] Error: Invalid NPC spawn data")
        return
    end

    local coords = data.coords
    if type(coords) == "table" then
        coords = vector3(coords.x, coords.y, coords.z or 0)
    elseif not coords then
        coords = GetEntityCoords(PlayerPedId(), true)  -- Fallback to player position
    end

    -- Spawn the NPC
    local npcId = exports['enemyx']:SpawnEnemy({
        model = data.model,
        weapon = data.weapon or "WEAPON_PISTOL",
        ammo = data.ammo or 30,
        secondaryWeapon = data.secondaryWeapon,
        secondaryAmmo = data.secondaryAmmo,
        behavior = data.behavior or "passive",
        enemyType = data.enemyType or "direct_spawn",
        coords = coords
    })

    if npcId then
        print(("[EnemyX NPC Handler] Spawned NPC %s (%s)"):format(
            npcId, data.model))
    end
end

-- Handle group spawn
function NPCHandler:_HandleGroupSpawn(data)
    -- Validate data
    if not data or not data.groupName then
        print("[EnemyX NPC Handler] Error: Invalid group spawn data")
        return
    end

    local coords = data.coords
    if type(coords) == "table" then
        coords = vector3(coords.x, coords.y, coords.z or 0)
    elseif not coords then
        coords = GetEntityCoords(PlayerPedId(), true)  -- Fallback to player position
    end

    local count = data.count or 1

    -- Spawn the group
    local groupIds = exports['enemyx']:SpawnGroup(data.groupName, coords, {
        min = count,
        max = count
    })

    if groupIds then
        print(("[EnemyX NPC Handler] Spawned group %s (%d NPCs)"):format(
            data.groupName, #groupIds))
    end
end

-- Handle clear enemies in area
function NPCHandler:_HandleClearEnemies(data)
    local coords = data.coords
    if type(coords) == "table" then
        coords = vector3(coords.x, coords.y, coords.z or 0)
    elseif not coords then
        coords = GetEntityCoords(PlayerPedId(), true)  -- Fallback to player position
    end

    local radius = data.radius or 50.0

    -- Clear enemies in area
    local removedCount = exports['enemyx']:ClearEnemiesInArea(coords, radius)

    print(("[EnemyX NPC Handler] Cleared %d enemies within %.1f radius"):format(
        removedCount, radius))
end

-- Handle debug overlay toggle
function NPCHandler:_HandleSetDebugOverlay(enabled)
    -- This would be handled by the admin module or debug system
    -- For now, just log it
    print(("[EnemyX NPC Handler] Debug overlay set to: %s"):format(tostring(enabled)))
end

return NPCHandler