-- EnemyX Server Zone Handler
-- Handles zone-based spawning and zone events

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
    self.zoneModule = nil  -- Will be set when zone module loads

    return self
end

-- Initialize the zone handler
function ZoneHandler:Initialize()
    if self.initialized then return end

    print("[EnemyX Server Zone Handler] Initializing...")

    -- Wait for zone module to be available
    Citizen.CreateThread(function()
        while not self.zoneModule do
            -- Try to get zone module from exports
            local resourceState = GetResourceState('enemyx')
            if resourceState == 'started' then
                self.zoneModule = exports['enemyx'] and exports['enemyx']:GetZoneModule()
            end
            Citizen.Wait(100)
        end
        print("[EnemyX Server Zone Handler] Zone module acquired")
    end)

    -- Set up event listeners
    self:_SetupEventListeners()

    -- Start zone update loop for automatic spawning
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000)  -- Check every second
            self:_UpdateZones()
        end
    end)

    self.initialized = true
    print("[EnemyX Server Zone Handler] Initialized")
end

-- Set up event listeners
function ZoneHandler:_SetupEventListeners()
    -- Listen for zone creation/deletion from config
    self.eventSystem:on(EnemyX.Events.CONFIG_RELOADED, function(newConfig, oldConfig)
        self:_OnConfigReload(newConfig, oldConfig)
    end)

    -- Listen for manual zone creation from admin/commands
    self.eventSystem:on(EnemyX.Events.ZONE_ENTERED, function(data)
        if data.config then
            self:_HandleZoneCreated(data.zoneName, data.config)
        end
    end)

    -- Listen for zone entry/exit events for player tracking
    self.eventSystem:on(EnemyX.Events.PLAYER_ENTERED_ZONE, function(data)
        self:_HandlePlayerZoneEntry(data.playerId, data.zoneName, data.coords)
    end)

    self.eventSystem:on(EnemyX.Events.PLAYER_EXITED_ZONE, function(data)
        self:_HandlePlayerZoneExit(data.playerId, data.zoneName, data.coords)
    end)
end

-- Handle zone created from config/admin
function ZoneHandler:_HandleZoneCreated(zoneName, zoneConfig)
    if not self.zoneModule then return end

    -- Add zone to zone module
    if self.zoneModule.AddZone then
        self.zoneModule:AddZone(zoneName, zoneConfig)
    end
end

-- Handle player entering zone
function ZoneHandler:_HandlePlayerZoneEntry(playerId, zoneName, coords)
    -- This could trigger events or spawn reinforcements based on zone settings
    -- For now, just log it
    print(("[EnemyX Server Zone Handler] Player %s entered zone %s"):format(
        playerId, zoneName))
end

-- Handle player exiting zone
function ZoneHandler:_HandlePlayerZoneExit(playerId, zoneName, coords)
    -- This could trigger events or remove temporary spawns
    print(("[EnemyX Server Zone Handler] Player %s exited zone %s"):format(
        playerId, zoneName))
end

-- Update zones (called periodically)
function ZoneHandler:_UpdateZones()
    if not self.zoneModule then return end

    -- Get all zones
    local zones = self.zoneModule:GetZones()
    if not zones then return end

    -- Update each zone's spawn logic
    for zoneName, zoneData in pairs(zones) do
        self:_ProcessZoneSpawn(zoneName, zoneData)
    end
end

-- Process zone for spawning
function ZoneHandler:_ProcessZoneSpawn(zoneName, zoneData)
    -- Check if spawning is enabled
    if not zoneData.spawn or zoneData.spawn.enabled == false then return end

    -- Get current time
    local currentTime = GetGameTimer()

    -- Check if enough time has passed since last spawn
    local lastSpawn = self:_GetLastSpawnTime(zoneName) or 0
    local interval = zoneData.spawn.interval or 5000

    if currentTime - lastSpawn < interval then
        return  -- Not time to spawn yet
    end

    -- Check if we're under NPC/vehicle limits
    local currentNPCs, currentVehicles = self:_CountZoneEntities(zoneName, zoneData)
    local maxNPCs = zoneData.spawn.maxNPCs or 10
    local maxVehicles = zoneData.spawn.maxVehicles or 3

    if currentNPCs >= maxNPCs and currentVehicles >= maxVehicles then
        return  -- At capacity
    end

    -- Check spawn density (probability)
    local density = zoneData.spawn.density or 0.5
    if math.random() > density then
        return  -- Skip spawn based on density
    end

    -- Determine how many to spawn
    local npcSlots = math.max(0, maxNPCs - currentNPCs)
    local vehicleSlots = math.max(0, maxVehicles - currentVehicles)
    local totalSlots = npcSlots + vehicleSlots

    if totalSlots <= 0 then return end

    -- Spawn entities based on zone configuration
    self:_SpawnZoneEntities(zoneName, zoneData, npcSlots, vehicleSlots)

    -- Update last spawn time
    self:_SetLastSpawnTime(zoneName, currentTime)
end

-- Count entities currently in zone
function ZoneHandler:_CountZoneEntities(zoneName, zoneData)
    if not self.zoneModule or not self.zoneModule.IsPositionInZone then
        return 0, 0
    end

    local npcCount = 0
    local vehicleCount = 0

    -- Get all active entities
    local entities = self.entityManager:GetActiveEntities()

    for entityId, entityData in pairs(entities) do
        if entityData.isActive then
            local inZone = false
            local pos = entityData.coords

            if self.zoneModule.IsPositionInZone then
                inZone = self.zoneModule:IsPositionInZone(pos, zoneName)
            end

            if inZone then
                if entityData.type == self.constants.EntityType.PED then
                    npcCount = npcCount + 1
                elseif entityData.type == self.constants.EntityType.VEHICLE then
                    vehicleCount = vehicleCount + 1
                end
            end
        end
    end

    return npcCount, vehicleCount
end

-- Spawn entities in zone
function ZoneHandler:_SpawnZoneEntities(zoneName, zoneData, npcSlots, vehicleSlots)
    -- Determine what to spawn based on zone configuration
    local spawnNPCs = math.min(npcSlots, zoneData.spawn.maxNPCs or 10)
    local spawnVehicles = math.min(vehicleSlots, zoneData.spawn.maxVehicles or 3)

    -- Spawn NPCs
    for i = 1, spawnNPCs do
        self:_SpawnNPCInZone(zoneName, zoneData)
    end

    -- Spawn vehicles
    for i = 1, spawnVehicles do
        self:_SpawnVehicleInZone(zoneName, zoneData)
    end
end

-- Spawn a single NPC in zone
function ZoneHandler:_SpawnNPCInZone(zoneName, zoneData)
    -- Get spawn position within zone
    local spawnPos = self:_GetRandomPositionInZone(zoneName, zoneData)
    if not spawnPos then return end

    -- Determine what type of NPC to spawn
    local enemyType = "generic"  -- Default
    local behavior = EnemyX.BehaviorType.PASSIVE  -- Default

    -- Check if zone has specific population settings
    if zoneData.populations then
        -- Time-based or trigger-based populations could go here
        -- For V1, we'll use a simple default or first available
        for popKey, popData in pairs(zoneData.populations) do
            if popData.enemyType then
                enemyType = popData.enemyType
                break
            end
        end
    end

    -- Get enemy configuration
    local enemyConfig = self.configLoader:Get(string.format("Enemies.%s", enemyType))
    if not enemyConfig then
        -- Fallback to first available enemy or default
        local enemies = self.configLoader:Get("Enemies", {})
        for _, config in pairs(enemies) do
            enemyConfig = config
            break
        end
        if not enemyConfig then
            enemyConfig = {
                label = "Generic Enemy",
                peds = {"a_m_m_business_01"},
                weapons = {primary = {weapon = "WEAPON_PISTOL", ammo = 30}},
                armor = 0,
                health = 100,
                accuracy = 50,
                relationship = EnemyX.Relationship.HOSTILE,
                combat = {aggressive = true, cover = true, flee = false, chase = true}
            }
        }
    end

    -- Select random ped model
    local pedModel = enemyConfig.peds[math.random(#enemyConfig.peds)]
    if not pedModel then pedModel = "a_m_m_business_01" end

    -- Determine weapons
    local primaryWeapon = enemyConfig.weapons and enemyConfig.weapons.primary and enemyConfig.weapons.primary.weapon or "WEAPON_PISTOL"
    local primaryAmmo = enemyConfig.weapons and enemyConfig.weapons.primary and enemyConfig.weapons.primary.ammo or 30
    local secondaryWeapon = enemyConfig.weapons and enemyConfig.weapons.secondary and enemyConfig.weapons.secondary.weapon
    local secondaryAmmo = enemyConfig.weapons and enemyConfig.weapons.secondary and enemyConfig.weapons.secondary.ammo

    -- Determine behavior
    local behavior = EnemyX.BehaviorType.PASSIVE
    if enemyConfig.behavior then
        behavior = enemyConfig.behavior
    elseif zoneData.defaultBehavior then
        behavior = zoneData.defaultBehavior
    end

    -- Trigger client event to spawn the NPC
    TriggerClientEvent('enemyx:zone:spawnNPC', -1, {
        zoneName = zoneName,
        model = pedModel,
        primaryWeapon = primaryWeapon,
        primaryAmmo = primaryAmmo,
        secondaryWeapon = secondaryWeapon,
        secondaryAmmo = secondaryAmmo,
        behavior = behavior,
        enemyType = enemyType,
        coords = {x = spawnPos.x, y = spawnPos.y, z = spawnPos.z}
    })

    print(("[EnemyX Server Zone Handler] Spawned %s (%s) in zone %s"):format(
        enemyConfig.label or "Unknown", pedModel, zoneName))
end

-- Spawn a single vehicle in zone
function ZoneHandler:_SpawnVehicleInZone(zoneName, zoneData)
    -- Get spawn position within zone
    local spawnPos = self:_GetRandomPositionInZone(zoneName, zoneData)
    if not spawnPos then return end

    -- For V1, we'll spawn a simple default vehicle
    -- In V2, we'll use vehicle configurations similar to enemies
    local vehicleModel = "schafter2"  -- Default vehicle
    local vehicleColor = math.random(0, 159)  -- Random color

    -- Trigger client event to spawn the vehicle
    TriggerClientEvent('enemyx:zone:spawnVehicle', -1, {
        zoneName = zoneName,
        model = vehicleModel,
        color = vehicleColor,
        coords = {x = spawnPos.x, y = spawnPos.y, z = spawnPos.z}
    })

    print(("[EnemyX Server Zone Handler] Spawned vehicle in zone %s"):format(zoneName))
end

-- Get random position within zone
function ZoneHandler:_GetRandomPositionInZone(zoneName, zoneData)
    if not self.zoneModule or not self.zoneModule._GetRandomPositionInZone then
        -- Fallback implementation
        return self:_GetRandomPositionFallback(zoneName, zoneData)
    end

    return self.zoneModule:_GetRandomPositionInZone(zoneName, zoneData)
end

-- Fallback random position implementation
function ZoneHandler:_GetRandomPositionFallback(zoneName, zoneData)
    local zoneType = zoneData.type
    local center = zoneData.center

    if not center then return nil end

    if zoneType == EnemyX.ZoneType.CIRCLE then
        -- Random point within circle
        local radius = zoneData.spawn and zoneData.spawn.radius or zoneData.radius
        if radius <= 0 then return center end

        local angle = math.random() * 2 * math.pi
        local distance = math.sqrt(math.random()) * radius  -- sqrt for uniform distribution

        return vector3(
            center.x + distance * math.cos(angle),
            center.y + distance * math.sin(angle),
            center.z
        )

    elseif zoneType == EnemyX.ZoneType.BOX then
        -- Random point within box
        local sizeX = zoneData.sizeX or 10.0
        local sizeY = zoneData.sizeY or 10.0
        local heading = zoneData.heading or 0

        local offsetX = (math.random() * 2 - 1) * sizeX / 2
        local offsetY = (math.random() * 2 - 1) * sizeY / 2

        -- Rotate by heading
        local cosH = math.cos(math.rad(heading))
        local sinH = math.sin(math.rad(heading))
        local rotatedX = offsetX * cosH - offsetY * sinH
        local rotatedY = offsetX * sinH + offsetY * cosH

        return vector3(
            center.x + rotatedX,
            center.y + rotatedY,
            center.z
        )

    elseif zoneType == EnemyX.ZoneType.POLYGON then
        -- V2: Implement random point in polygon
        return center  -- Placeholder

    elseif zoneType == EnemyX.ZoneType.ENTITY then
        -- V2: Get entity position
        return center  -- Placeholder
    end

    return center
end

-- Get/set last spawn time for a zone (simple in-memory storage)
ZoneHandler._lastSpawnTimes = {}

function ZoneHandler:_GetLastSpawnTime(zoneName)
    return ZoneHandler._lastSpawnTimes[zoneName]
end

function ZoneHandler:_SetLastSpawnTime(zoneName, time)
    ZoneHandler._lastSpawnTimes[zoneName] = time
end

-- Handle configuration reload
function ZoneHandler:_OnConfigReload(newConfig, oldConfig)
    print("[EnemyX Server Zone Handler] Configuration reloaded")

    -- Reload zones from new config
    local newZones = newConfig.Zones or {}
    local oldZones = oldConfig.Zones or {}

    -- Find zones to add
    for zoneName, zoneData in pairs(newZones) do
        if not oldZones[zoneName] then
            self:_HandleZoneCreated(zoneName, zoneData)
        end
    end

    -- Find zones to remove
    for zoneName, _ in pairs(oldZones) do
        if not newZones[zoneName] then
            if self.zoneModule and self.zoneModule.RemoveZone then
                self.zoneModule:RemoveZone(zoneName)
            end
        end
    end

    -- Update existing zones
    for zoneName, zoneData in pairs(newZones) do
        if oldZones[zoneName] then
            if self.zoneModule and self.zoneModule.UpdateZone then
                self.zoneModule:UpdateZone(zoneName, zoneData)
            end
        end
    end
end

return ZoneHandler