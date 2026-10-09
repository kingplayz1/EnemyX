-- EnemyX Client Zone Handler
-- Handles zone-related events from server

local EnemyX = require 'shared/constants'
local Utils = require 'shared/utils'
local EventSystem = require 'core.events'

local ZoneHandler = {}
ZoneHandler.__index = ZoneHandler

-- Create a new zone handler instance
function ZoneHandler:new(dependencies)
    local self = setmetatable({}, ZoneHandler)
    self.eventSystem = dependencies.eventSystem
    self.entityManager = dependencies.entityManager
    self.configLoader = dependencies.configLoader
    self.constants = dependencies.constants
    self.utils = dependencies.utils
    self.initialized = false

    return self
end

-- Initialize the zone handler
function ZoneHandler:Initialize()
    if self.initialized then return end

    print("[EnemyX Zone Handler] Initializing...")

    -- Set up event listeners for server-triggered events
    self:_SetupEventListeners()

    self.initialized = true
    print("[EnemyX Zone Handler] Initialized")
end

-- Set up event listeners
function ZoneHandler:_SetupEventListeners()
    -- Listen for NPC spawn requests from server (zone spawning)
    RegisterNetEvent('enemyx:zone:spawnNPC', function(data)
        self:_HandleZoneNPCSpawn(data)
    end)

    -- Listen for vehicle spawn requests from server (zone spawning)
    RegisterNetEvent('enemyx:zone:spawnVehicle', function(data)
        self:_HandleZoneVehicleSpawn(data)
    end)

    -- Listen for clear area requests
    RegisterNetEvent('enemyx:zone:clearArea', function(data)
        self:_HandleClearArea(data)
    end)
end

-- Handle NPC spawn from zone
function ZoneHandler:_HandleZoneNPCSpawn(data)
    -- Validate data
    if not data or not data.model then
        print("[EnemyX Zone Handler] Error: Invalid NPC spawn data")
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
        weapon = data.primaryWeapon or "WEAPON_PISTOL",
        ammo = data.primaryAmmo or 30,
        secondaryWeapon = data.secondaryWeapon,
        secondaryAmmo = data.secondaryAmmo,
        behavior = data.behavior or "passive",
        enemyType = data.enemyType or "zone_spawn",
        coords = coords
    })

    if npcId then
        print(("[EnemyX Zone Handler] Spawned NPC %s (%s) from zone %s"):format(
            npcId, data.model, data.zoneName or "unknown"))
    end
end

-- Handle vehicle spawn from zone
function ZoneHandler:_HandleZoneVehicleSpawn(data)
    -- Validate data
    if not data or not data.model then
        print("[EnemyX Zone Handler] Error: Invalid vehicle spawn data")
        return
    end

    local coords = data.coords
    if type(coords) == "table" then
        coords = vector3(coords.x, coords.y, coords.z or 0)
    elseif not coords then
        coords = GetEntityCoords(PlayerPedId(), true)  -- Fallback to player position
    end

    -- Spawn the vehicle
    local vehicleId = exports['enemyx']:SpawnVehicle({
        model = data.model,
        coords = coords,
        networked = true
    })

    if vehicleId then
        -- Set vehicle color if provided
        local vehicleHandle = nil
        if data.color then
            vehicleHandle = NetworkGetEntityFromNetworkId(vehicleId)
            if vehicleHandle and vehicleHandle ~= 0 then
                SetVehicleCustomPrimaryColour(vehicleHandle,
                    math.floor(data.color / 65536) % 256,
                    math.floor(data.color / 256) % 256,
                    data.color % 256)
            end
        end

        print(("[EnemyX Zone Handler] Spawned vehicle %s (%s) from zone %s"):format(
            vehicleId, data.model, data.zoneName or "unknown"))
    end
end

-- Handle clear area request
function ZoneHandler:_HandleClearArea(data)
    local coords = data.coords
    if type(coords) == "table" then
        coords = vector3(coords.x, coords.y, coords.z or 0)
    elseif not coords then
        coords = GetEntityCoords(PlayerPedId(), true)  -- Fallback to player position
    end

    local radius = data.radius or 50.0

    -- Clear enemies in area
    local removedCount = exports['enemyx']:ClearEnemiesInArea(coords, radius)

    print(("[EnemyX Zone Handler] Cleared %d enemies within %.1f radius"):format(
        removedCount, radius))
end

return ZoneHandler