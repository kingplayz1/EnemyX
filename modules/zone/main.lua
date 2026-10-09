-- EnemyX Zone Module
-- Handles zone management, spawn rules, and zone-based NPC spawning

local EnemyX = require 'shared/constants'
local Utils = require 'shared/utils'
local EventSystem = require 'core.events'

local ZoneModule = {}
ZoneModule.__index = ZoneModule

-- Zone types
ZoneModule.ZoneType = {
    CIRCLE = "circle",
    BOX = "box",
    POLYGON = "polygon",
    ENTITY = "entity"
}

-- Create a new zone module instance
function ZoneModule:new(dependencies)
    local self = setmetatable({}, ZoneModule)
    self.eventSystem = dependencies.eventSystem
    self.configLoader = dependencies.configLoader
    self.entityManager = dependencies.entityManager
    self.constants = dependencies.constants
    self.utils = dependencies.utils
    self.initialized = false
    self.zones = {}  -- zoneName -> zoneData
    self.spawnTimers = {}  -- zoneName -> lastSpawnTime
    self.playerInZone = {}  -- playerId -> {zoneName -> true}

    return self
end

-- Initialize the zone module
function ZoneModule:Initialize()
    if self.initialized then return end

    print("[EnemyX Zone] Initializing...")

    -- Load zones from configuration
    self:_LoadZonesFromConfig()

    -- Set up event listeners
    self:_SetupEventListeners()

    -- Start zone update loop
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000)  -- Check zones every second
            self:_UpdateZones()
        end
    end)

    self.initialized = true
    print("[EnemyX Zone] Initialized")
end

-- Start the module
function ZoneModule:Start()
    print("[EnemyX Zone] Started")
end

-- Stop the module
function ZoneModule:Stop()
    print("[EnemyX Zone] Stopped")
end

-- Cleanup the module
function ZoneModule:Cleanup()
    self.zones = {}
    self.spawnTimers = {}
    self.playerInZone = {}
    print("[EnemyX Zone] Cleaned up")
end

-- Set up event listeners
function ZoneModule:_SetupEventListeners()
    -- Listen for zone creation requests
    self.eventSystem:on(EnemyX.Events.ZONE_ENTERED, function(data)
        if data.config then
            self:AddZone(data.zoneName, data.config)
        end
    end)

    -- Listen for config reloads
    self.eventSystem:on(EnemyX.Events.CONFIG_RELOADED, function(newConfig, oldConfig)
        self:_OnConfigReload(newConfig, oldConfig)
    end)

    -- Listen for player entering/exiting entities (for entity-based zones)
    -- Would be implemented in V2
end

-- Load zones from configuration
function ZoneModule:_LoadZonesFromConfig()
    local zonesConfig = self.configLoader:Get("Zones", {})
    for zoneName, zoneData in pairs(zonesConfig) do
        self:AddZone(zoneName, zoneData)
    end
    print(("[EnemyX Zone] Loaded %d zones from config"):format(Utils.TableCount(zonesConfig)))
end

-- Add a zone
function ZoneModule:AddZone(zoneName, zoneData)
    if not zoneName or type(zoneName) ~= "string" then
        error("Zone name must be a non-empty string")
    end
    if not zoneData then
        error("Zone data is required")
    end

    -- Validate zone data
    if not self:_ValidateZoneData(zoneName, zoneData) then
        return false
    end

    -- Store zone data
    self.zones[zoneName] = Utils.DeepCopy(zoneData)
    self.spawnTimers[zoneName] = 0  -- Initialize spawn timer

    print(("[EnemyX Zone] Added zone: %s (%s)"):format(zoneName, zoneData.type or "unknown"))
    return true
end

-- Remove a zone
function ZoneModule:RemoveZone(zoneName)
    if not self.zones[zoneName] then
        return false
    end

    self.zones[zoneName] = nil
    self.spawnTimers[zoneName] = nil

    -- Clean up player tracking
    for playerId, zones in pairs(self.playerInZone) do
        zones[zoneName] = nil
    end

    print(("[EnemyX Zone] Removed zone: %s"):format(zoneName))
    return true
end

-- Validate zone data
function ZoneModule:_ValidateZoneData(zoneName, zoneData)
    if not zoneData.type then
        print(("[EnemyX Zone] Warning: Zone %s missing type, defaulting to circle"):format(zoneName))
        zoneData.type = EnemyX.ZoneType.CIRCLE
    end

    if zoneData.type == EnemyX.ZoneType.CIRCLE then
        if not zoneData.center then
            print(("[EnemyX Zone] Error: Circle zone %s missing center"):format(zoneName))
            return false
        end
        if not zoneData.radius or zoneData.radius <= 0 then
            print(("[EnemyX Zone] Error: Circle zone %s missing or invalid radius"):format(zoneName))
            return false
        end
    elseif zoneData.type == EnemyX.ZoneType.BOX then
        if not zoneData.center then
            print(("[EnemyX Zone] Error: Box zone %s missing center"):format(zoneName))
            return false
        end
        if not zoneData.sizeX or zoneData.sizeX <= 0 then
            print(("[EnemyX Zone] Error: Box zone %s missing or invalid sizeX"):format(zoneName))
            return false
        end
        if not zoneData.sizeY or zoneData.sizeY <= 0 then
            print(("[EnemyX Zone] Error: Box zone %s missing or invalid sizeY"):format(zoneName))
            return false
        end
        -- heading is optional, defaults to 0
    elseif zoneData.type == EnemyX.ZoneType.POLYGON then
        if not zoneData.points or #zoneData.points < 3 then
            print(("[EnemyX Zone] Error: Polygon zone %s needs at least 3 points"):format(zoneName))
            return false
        end
    elseif zoneData.type == EnemyX.ZoneType.ENTITY then
        if not zoneData.entityId then
            print(("[EnemyX Zone] Error: Entity zone %s missing entityId"):format(zoneName))
            return false
        end
        -- V2 feature
    else
        print(("[EnemyX Zone] Warning: Unknown zone type %s for zone %s, defaulting to circle"):format(
            zoneData.type, zoneName))
        zoneData.type = EnemyX.ZoneType.CIRCLE
    end

    -- Validate spawn configuration if present
    if zoneData.spawn then
        if not self:_ValidateSpawnConfig(zoneName, zoneData.spawn) then
            return false
        end
    end

    return true
end

-- Validate spawn configuration
function ZoneModule:_ValidateSpawnConfig(zoneName, spawnConfig)
    if spawnConfig.enabled == false then
        return true  -- Disabled spawn is valid
    end

    if spawnConfig.radius and spawnConfig.radius <= 0 then
        print(("[EnemyX Zone] Error: Zone %s spawn radius must be positive"):format(zoneName))
        return false
    end

    if spawnConfig.minDistance and spawnConfig.minDistance < 0 then
        print(("[EnemyX Zone] Error: Zone %s minDistance must be non-negative"):format(zoneName))
        return false
    end

    if spawnConfig.maxDistance and spawnConfig.maxDistance <= 0 then
        print(("[EnemyX Zone] Error: Zone %s maxDistance must be positive"):format(zoneName))
        return false
    end

    if spawnConfig.minDistance and spawnConfig.maxDistance then
        if spawnConfig.minDistance >= spawnConfig.maxDistance then
            print(("[EnemyX Zone] Error: Zone %s minDistance must be less than maxDistance"):format(zoneName))
            return false
        end
    end

    if spawnConfig.maxNPCs and spawnConfig.maxNPCs < 0 then
        print(("[EnemyX Zone] Error: Zone %s maxNPCs must be non-negative"):format(zoneName))
        return false
    end

    if spawnConfig.maxVehicles and spawnConfig.maxVehicles < 0 then
        print(("[EnemyX Zone] Error: Zone %s maxVehicles must be non-negative"):format(zoneName))
        return false
    end

    if spawnConfig.density then
        if spawnConfig.density < 0 or spawnConfig.density > 1 then
            print(("[EnemyX Zone] Error: Zone %s density must be between 0 and 1"):format(zoneName))
            return false
        end
    end

    if spawnConfig.interval and spawnConfig.interval <= 0 then
        print(("[EnemyX Zone] Error: Zone %s spawn interval must be positive"):format(zoneName))
        return false
    end

    return true
end

-- Get zone data by name
function ZoneModule:GetZone(zoneName)
    return self.zones[zoneName]
end

-- Get all zones
function ZoneModule:GetAllZones()
    return Utils.DeepCopy(self.zones)
end

-- Check if position is inside zone
function ZoneModule:IsPositionInZone(position, zoneName)
    local zoneData = self.zones[zoneName]
    if not zoneData then return false end

    if zoneData.type == EnemyX.ZoneType.CIRCLE then
        return self.utils:IsInCircle(position, zoneData.center, zoneData.radius)
    elseif zoneData.type == EnemyX.ZoneType.BOX then
        return self.utils:IsInBox(position, zoneData.center, zoneData.sizeX, zoneData.sizeY, zoneData.heading or 0)
    elseif zoneData.type == EnemyX.ZoneType.POLYGON then
        return self.utils:IsInPolygon(position, zoneData.points)
    elseif zoneData.type == EnemyX.ZoneType.ENTITY then
        -- V2: Check if entity exists and get its position
        return false  -- Placeholder for V2
    end

    return false
end

-- Get closest zone to position
function ZoneModule:GetClosestZone(position, maxDistance)
    local closestZone = nil
    local closestDistance = maxDistance or math.huge

    for zoneName, zoneData in pairs(self.zones) do
        local distance = math.huge

        if zoneData.type == EnemyX.ZoneType.CIRCLE then
            distance = self.utils:GetDistance(position, zoneData.center, true) - zoneData.radius
            if distance < 0 then distance = 0 end  -- Inside zone
        elseif zoneData.type == EnemyX.ZoneType.BOX then
            distance = self.utils:GetDistanceToBox(position, zoneData.center, zoneData.sizeX, zoneData.sizeY, zoneData.heading or 0)
            if distance < 0 then distance = 0 end
        elseif zoneData.type == EnemyX.ZoneType.POLYGON then
            distance = self.utils:GetDistanceToPolygon(position, zoneData.points)
            if distance < 0 then distance = 0 end
        elseif zoneData.type == EnemyX.ZoneType.ENTITY then
            -- V2
            distance = math.huge
        end

        if distance < closestDistance then
            closestDistance = distance
            closestZone = zoneName
        end
    end

    return closestZone, closestDistance
end

-- Update zones (called periodically)
function ZoneModule:_UpdateZones()
    local currentTime = GetGameTimer()

    -- Update each zone's spawn timer
    for zoneName, zoneData in pairs(self.zones) do
        if zoneData.spawn and zoneData.spawn.enabled ~= false then
            self:_CheckZoneSpawn(zoneName, zoneData, currentTime)
        end
    end
end

-- Check if zone should spawn NPCs
function ZoneModule:_CheckZoneSpawn(zoneName, zoneData, currentTime)
    local spawnConfig = zoneData.spawn
    if not spawnConfig then return end

    -- Check if enough time has passed since last spawn
    local lastSpawn = self.spawnTimers[zoneName] or 0
    local interval = spawnConfig.interval or 5000  -- Default 5 seconds

    if currentTime - lastSpawn < interval then
        return  -- Not time to spawn yet
    end

    -- Check if we're under NPC/vehicle limits
    local currentNPCs, currentVehicles = self:_CountZoneEntities(zoneName)
    local maxNPCs = spawnConfig.maxNPCs or 10
    local maxVehicles = spawnConfig.maxVehicles or 3

    if currentNPCs >= maxNPCs and currentVehicles >= maxVehicles then
        return  -- At capacity
    end

    -- Check spawn density (probability)
    local density = spawnConfig.density or 0.5
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

    -- Update spawn timer
    self.spawnTimers[zoneName] = currentTime
end

-- Count entities currently in zone
function ZoneModule:_CountZoneEntities(zoneName)
    local npcCount = 0
    local vehicleCount = 0
    local zoneData = self.zones[zoneName]

    if not zoneData then return 0, 0 end

    -- Get all active entities
    local entities = self.entityManager:GetActiveEntities()

    for entityId, entityData in pairs(entities) do
        if entityData.isActive then
            local inZone = false
            local pos = entityData.coords

            if zoneData.type == EnemyX.ZoneType.CIRCLE then
                inZone = self.utils:IsInCircle(pos, zoneData.center, zoneData.radius)
            elseif zoneData.type == EnemyX.ZoneType.BOX then
                inZone = self.utils:IsInBox(pos, zoneData.center, zoneData.sizeX, zoneData.sizeY, zoneData.heading or 0)
            elseif zoneData.type == EnemyX.ZoneType.POLYGON then
                inZone = self.utils:IsInPolygon(pos, zoneData.points)
            elseif zoneData.type == EnemyX.ZoneType.ENTITY then
                -- V2
                inZone = false
            end

            if inZone then
                if entityData.type == EnemyX.EntityType.PED then
                    npcCount = npcCount + 1
                elseif entityData.type == EnemyX.EntityType.VEHICLE then
                    vehicleCount = vehicleCount + 1
                end
            end
        end
    end

    return npcCount, vehicleCount
end

-- Spawn entities in zone
function ZoneModule:_SpawnZoneEntities(zoneName, zoneData, npcSlots, vehicleSlots)
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
function ZoneModule:_SpawnNPCInZone(zoneName, zoneData)
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
            if popData.npcType then
                enemyType = popData.npcType
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
        end
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

    -- Spawn the NPC via client (since we're on server)
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
        coords = spawnPos
    })

    print(("[EnemyX Zone] Spawned %s (%s) in zone %s"):format(
        enemyConfig.label or "Unknown", pedModel, zoneName))
end

-- Spawn a single vehicle in zone
function ZoneModule:_SpawnVehicleInZone(zoneName, zoneData)
    -- Get spawn position within zone
    local spawnPos = self:_GetRandomPositionInZone(zoneName, zoneData)
    if not spawnPos then return end

    -- For V1, we'll spawn a simple default vehicle
    -- In V2, we'll use vehicle configurations similar to enemies
    local vehicleModel = "schafter2"  -- Default vehicle
    local vehicleColor = math.random(0, 159)  -- Random color

    -- Spawn the vehicle via client
    TriggerClientEvent('enemyx:zone:spawnVehicle', -1, {
        zoneName = zoneName,
        model = vehicleModel,
        color = vehicleColor,
        coords = spawnPos
    })

    print(("[EnemyX Zone] Spawned vehicle in zone %s"):format(zoneName))
end

-- Get random position within zone
function ZoneModule:_GetRandomPositionInZone(zoneName, zoneData)
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

-- Handle player entering/exiting zones
function ZoneModule:_UpdatePlayerZoneState(playerId, playerCoords)
    local playerPed = GetPlayerPed(playerId)
    if not playerPed or playerPed == 0 then return end

    if not playerCoords then
        playerCoords = GetEntityCoords(playerPed, true)
    end

    -- Check each zone
    for zoneName, zoneData in pairs(self.zones) do
        local currentlyInZone = self:IsPositionInZone(playerCoords, zoneName)
        local wasInZone = self.playerInZone[playerId] and self.playerInZone[playerId][zoneName] or false

        if currentlyInZone and not wasInZone then
            -- Player entered zone
            self.playerInZone[playerId] = self.playerInZone[playerId] or {}
            self.playerInZone[playerId][zoneName] = true

            self.eventSystem:emit(EnemyX.Events.PLAYER_ENTERED_ZONE, {
                playerId = playerId,
                zoneName = zoneName,
                coords = playerCoords
            })

        elseif not currentlyInZone and wasInZone then
            -- Player exited zone
            self.playerInZone[playerId] = self.playerInZone[playerId] or {}
            self.playerInZone[playerId][zoneName] = false

            self.eventSystem:emit(EnemyX.Events.PLAYER_EXITED_ZONE, {
                playerId = playerId,
                zoneName = zoneName,
                coords = playerCoords
            })
        end
    end
end

-- Handle configuration reload
function ZoneModule:_OnConfigReload(newConfig, oldConfig)
    print("[EnemyX Zone] Configuration reloaded")

    -- Reload zones from new config
    local newZones = newConfig.Zones or {}
    local oldZones = oldConfig.Zones or {}

    -- Find zones to add
    for zoneName, zoneData in pairs(newZones) do
        if not oldZones[zoneName] then
            self:AddZone(zoneName, zoneData)
        end
    end

    -- Find zones to remove
    for zoneName, _ in pairs(oldZones) do
        if not newZones[zoneName] then
            self:RemoveZone(zoneName)
        end
    end

    -- Update existing zones
    for zoneName, zoneData in pairs(newZones) do
        if oldZones[zoneName] then
            -- Merge changes (simple replace for now)
            self.zones[zoneName] = Utils.DeepCopy(zoneData)
            self.spawnTimers[zoneName] = 0  -- Reset spawn timer
        end
    end
end

-- Public API functions

-- Get all zones
function ZoneModule:GetZones()
    return Utils.DeepCopy(self.zones)
end

-- Get zone count
function ZoneModule:GetZoneCount()
    return Utils.TableCount(self.zones)
end

-- Check if any zones exist
function ZoneModule:HasZones()
    return Utils.TableCount(self.zones) > 0
end

-- Get players currently in zone
function ZoneModule:GetPlayersInZone(zoneName)
    local players = {}
    for playerId, zones in pairs(self.playerInZone) do
        if zones[zoneName] == true then
            table.insert(players, playerId)
        end
    end
    return players
end

-- Check if player is in zone
function ZoneModule:IsPlayerInZone(playerId, zoneName)
    return self.playerInZone[playerId] and self.playerInZone[playerId][zoneName] == true
end

-- Manual spawn in zone (for admin/commands)
function ZoneModule:SpawnInZone(zoneName, entityType, count, options)
    if not self.zones[zoneName] then
        print(("[EnemyX Zone] Error: Zone %s does not exist"):format(zoneName))
        return 0
    end

    count = count or 1
    options = options or {}
    local spawned = 0

    for i = 1, count do
        if entityType == EnemyX.EntityType.PED then
            self:_SpawnNPCInZone(zoneName, self.zones[zoneName])
            spawned = spawned + 1
        elseif entityType == EnemyX.EntityType.VEHICLE then
            self:_SpawnVehicleInZone(zoneName, self.zones[zoneName])
            spawned = spawned + 1
        end
    end

    return spawned
end

return ZoneModule