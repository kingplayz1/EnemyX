-- EnemyX Admin Module
-- Security-first implementation with server-authoritative permissions
-- NUI serves as consumer of EnemyX API, not second implementation

local EnemyX = require 'shared/constants'
local Utils = require 'shared/utils'
local EventSystem = require 'core.events'

local AdminModule = {}
AdminModule.__index = AdminModule

-- Admin module states
AdminModule.State = {
    HIDDEN = "hidden",
    SHOWING = "showing",
    VISIBLE = "visible",
    HIDING = "hiding"
}

-- Create a new admin module instance
function AdminModule:new(dependencies)
    local self = setmetatable({}, AdminModule)
    self.eventSystem = dependencies.eventSystem
    self.configLoader = dependencies.configLoader
    self.entityManager = dependencies.entityManager
    self.npcModule = dependencies.npcModule
    self.behaviorModule = dependencies.behaviorModule
    self.zoneModule = dependencies.zoneModule
    self.frameworkAdapter = dependencies.frameworkAdapter
    self.constants = dependencies.constants
    self.utils = dependencies.utils
    self.initialized = false
    self.state = AdminModule.State.HIDDEN
    self.lastNUIUpdate = 0
    self.nuiUpdateInterval = 1000  -- Update NUI every second max
    self.selectedZone = nil
    self.selectedEnemyType = nil
    self.debugInfo = {}
    self.requestRateLimit = {}  -- For rate limiting admin actions
    self.rateLimitWindow = 5000  -- 5 seconds
    self.maxRequestsPerWindow = 10

    return self
end

-- Initialize the admin module
function AdminModule:Initialize()
    if self.initialized then return end

    print("[EnemyX Admin] Initializing...")

    -- Set up event listeners
    self:_SetupEventListeners()

    -- Set up NUI communication
    self:_SetupNUICommunication()

    self.initialized = true
    print("[EnemyX Admin] Initialized")
end

-- Start the module
function AdminModule:Start()
    print("[EnemyX Admin] Started")
end

-- Stop the module
function AdminModule:Stop()
    self:HideNUI()
    print("[EnemyX Admin] Stopped")
end

-- Cleanup the module
function AdminModule:Cleanup()
    print("[EnemyX Admin] Cleaned up")
end

-- Set up event listeners
function AdminModule:_SetupEventListeners()
    -- Listen for admin commands
    self.eventSystem:on(EnemyX.Events.CONFIG_RELOADED, function(newConfig, oldConfig)
        self:_OnConfigReload(newConfig, oldConfig)
    end)

    -- Listen for zone events to keep admin panel updated
    self.eventSystem:on(EnemyX.Events.ZONE_ENTERED, function(data)
        self:_RequestNUIUpdate()
    end)

    self.eventSystem:on(EnemyX.Events.ZONE_EXITED, function(data)
        self:_RequestNUIUpdate()
    end)

    -- Listen for enemy spawns/deaths
    self.eventSystem:on(EnemyX.Events.ENEMY_SPAWNED, function(data)
        self:_RequestNUIUpdate()
    end)

    self.eventSystem:on(EnemyX.Events.ENEMY_DIED, function(data)
        self:_RequestNUIUpdate()
    end)

    -- Register admin commands
    RegisterCommand('enemyxadmin', function(source, args, raw)
        -- Server-side permission check
        if self:_CheckAdminPermission(source) then
            TriggerClientEvent('enemyx:client:toggleAdmin', source)
        else
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                args = {"[EnemyX]", "Insufficient permissions"}
            })
        end
    end, false)

    RegisterCommand('enemyxdebug', function(source, args, raw)
        if self:_CheckAdminPermission(source) then
            TriggerClientEvent('enemyx:client:toggleDebug', source)
        else
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                args = {"[EnemyX]", "Insufficient permissions"}
            })
        end
    end, false)

    -- NUI callbacks (from UI to server) - ALL VALIDATED SERVER-SIDE
    RegisterNUICallback('adminCommand', function(data, cb)
        self:_HandleAdminCommand(data, cb)
    end)

    RegisterNUICallback('getAdminData', function(data, cb)
        if self:_CheckAdminPermission(source) then
            cb(self:_GetAdminData())
        else
            cb({error = "Unauthorized"})
        end
    end)

    RegisterNUICallback('spawnNPC', function(data, cb)
        self:_HandleSpawnNPC(data, cb)
    end)

    RegisterNUICallback('spawnGroup', function(data, cb)
        self:_HandleSpawnGroup(data, cb)
    end)

    RegisterNUICallback('createZone', function(data, cb)
        self:_HandleCreateZone(data, cb)
    end)

    RegisterNUICallback('removeZone', function(data, cb)
        self:_HandleRemoveZone(data, cb)
    end)

    RegisterNUICallback('clearEnemies', function(data, cb)
        self:_HandleClearEnemies(data, cb)
    end)

    RegisterNUICallback('updateConfig', function(data, cb)
        self:_HandleUpdateConfig(data, cb)
    end)

    RegisterNUICallback('getZones', function(data, cb)
        if self:_CheckAdminPermission(source) then
            cb({zones = self:_GetZonesForAdmin()})
        else
            cb({error = "Unauthorized"})
        end
    end)

    RegisterNUICallback('getEnemies', function(data, cb)
        if self:_CheckAdminPermission(source) then
            cb({enemies = self:_GetEnemiesForAdmin()})
        else
            cb({error = "Unauthorized"})
        end
    end)

    RegisterNUICallback('setDebugOverlay', function(data, cb)
        self:_HandleSetDebugOverlay(data, cb)
    end)
end

-- Check admin permission with server-side authority
function AdminModule:_CheckAdminPermission(source)
    if not source or type(source) ~= "number" then return false end
    return self.frameworkAdapter.HasPermission(source, "enemyx.admin")
end

-- Rate limiting for admin actions
function AdminModule:_CheckRateLimit(source)
    if not source or type(source) ~= "number" then return false end

    local currentTime = GetGameTimer()
    if not self.requestRateLimit[source] then
        self.requestRateLimit[source] = {count = 0, resetTime = currentTime + self.rateLimitWindow}
    end

    -- Reset window if expired
    if currentTime > self.requestRateLimit[source].resetTime then
        self.requestRateLimit[source] = {count = 0, resetTime = currentTime + self.rateLimitWindow}
    end

    -- Check if over limit
    if self.requestRateLimit[source].count >= self.maxRequestsPerWindow then
        return false
    end

    -- Increment counter
    self.requestRateLimit[source].count = self.requestRateLimit[source].count + 1
    return true
end

-- Validate NPC data
function AdminModule:_ValidateNPCData(data)
    if not data then return false, "No data provided" end

    -- Validate model
    if not data.model or type(data.model) ~= "string" or data.model == "" then
        return false, "Invalid ped model"
    end

    -- Validate weapon
    if not data.weapon or type(data.weapon) ~= "string" or data.weapon == "" then
        return false, "Invalid weapon"
    end

    -- Validate ammo
    if data.ammo ~= nil and (type(data.ammo) ~= "number" or data.ammo < 0) then
        return false, "Invalid ammo"
    end

    -- Validate health
    if data.health ~= nil and (type(data.health) ~= "number" or data.health <= 0) then
        return false, "Invalid health"
    end

    -- Validate armor
    if data.armor ~= nil and (type(data.armor) ~= "number" or data.armor < 0) then
        return false, "Invalid armor"
    end

    -- Validate accuracy
    if data.accuracy ~= nil and (type(data.accuracy) ~= "number" or data.accuracy < 0 or data.accuracy > 100) then
        return false, "Invalid accuracy"
    end

    -- Validate behavior
    local validBehaviors = {
        [EnemyX.BehaviorType.PASSIVE] = true,
        [EnemyX.BehaviorType.DEFENSIVE] = true,
        [EnemyX.BehaviorType.AGGRESSIVE] = true,
        [EnemyX.BehaviorType.PATROL] = true,
        [EnemyX.BehaviorType.GUARD] = true,
        [EnemyX.BehaviorType.INVESTIGATE] = true,
        [EnemyX.BehaviorType.SNIPER] = true
    }
    if not data.behavior or not validBehaviors[data.behavior] then
        return false, "Invalid behavior"
    end

    -- Validate coords
    if not data.coords or type(data.coords) ~= "userdata" then
        return false, "Invalid coordinates"
    end

    return true, "Valid"
end

-- Validate group data
function AdminModule:_ValidateGroupData(data)
    if not data then return false, "No data provided" end

    -- Validate group name
    if not data.groupName or type(data.groupName) ~= "string" or data.groupName == "" then
        return false, "Invalid group name"
    end

    -- Validate count
    if not data.count or type(data.count) ~= "number" or data.count < 1 or data.count > 20 then
        return false, "Invalid group count (1-20)"
    end

    -- Validate coords
    if not data.coords or type(data.coords) ~= "userdata" then
        return false, "Invalid coordinates"
    end

    return true, "Valid"
end

-- Validate zone data
function AdminModule:_ValidateZoneData(data)
    if not data then return false, "No data provided" end

    -- Validate name
    if not data.name or type(data.name) ~= "string" or data.name == "" then
        return false, "Invalid zone name"
    end

    -- Validate type
    local validTypes = {
        [EnemyX.ZoneType.CIRCLE] = true,
        [EnemyX.ZoneType.BOX] = true,
        [EnemyX.ZoneType.POLYGON] = true
    }
    if not data.type or not validTypes[data.type] then
        return false, "Invalid zone type"
    end

    -- Validate center
    if not data.center or type(data.center) ~= "userdata" then
        return false, "Invalid center coordinates"
    end

    -- Type-specific validation
    if data.type == EnemyX.ZoneType.CIRCLE then
        if not data.radius or type(data.radius) ~= "number" or data.radius <= 0 then
            return false, "Invalid radius"
        end
    elseif data.type == EnemyX.ZoneType.BOX then
        if not data.sizeX or type(data.sizeX) ~= "number" or data.sizeX <= 0 then
            return false, "Invalid sizeX"
        end
        if not data.sizeY or type(data.sizeY) ~= "number" or data.sizeY <= 0 then
            return false, "Invalid sizeY"
        end
        -- heading is optional
    elseif data.type == EnemyX.ZoneType.POLYGON then
        if not data.points or type(data.points) ~= "table" or #data.points < 3 then
            return false, "Invalid polygon points (minimum 3)"
        end
    end

    -- Validate spawn settings if enabled
    if data.spawn and data.spawn.enabled ~= false then
        if not data.spawn.radius or type(data.spawn.radius) ~= "number" or data.spawn.radius <= 0 then
            return false, "Invalid spawn radius"
        end
        if data.spawn.minDistance ~= nil and (type(data.spawn.minDistance) ~= "number" or data.spawn.minDistance < 0) then
            return false, "Invalid minDistance"
        end
        if data.spawn.maxDistance ~= nil and (type(data.spawn.maxDistance) ~= "number" or data.spawn.maxDistance <= 0) then
            return false, "Invalid maxDistance"
        end
        if data.spawn.minDistance and data.spawn.maxDistance and data.spawn.minDistance >= data.spawn.maxDistance then
            return false, "minDistance must be less than maxDistance"
        end
        if not data.spawn.maxNPCs or type(data.spawn.maxNPCs) ~= "number" or data.spawn.maxNPCs < 0 then
            return false, "Invalid maxNPCs"
        end
        if not data.spawn.maxVehicles or type(data.spawn.maxVehicles) ~= "number" or data.spawn.maxVehicles < 0 then
            return false, "Invalid maxVehicles"
        end
        if data.spawn.density ~= nil and (type(data.spawn.density) ~= "number" or data.spawn.density < 0 or data.spawn.density > 1) then
            return false, "Invalid density (0-1)"
        end
        if not data.spawn.interval or type(data.spawn.interval) ~= "number" or data.spawn.interval <= 0 then
            return false, "Invalid interval"
        end
    end

    return true, "Valid"
end

-- Validate config data
function AdminModule:_ValidateConfigData(key, value)
    if not key or type(key) ~= "string" or key == "" then
        return false, "Invalid configuration key"
    end

    -- Basic validation - could be extended per key
    if value == nil then
        return false, "Configuration value cannot be nil"
    end

    return true, "Valid"
end

-- Set up NUI communication
function AdminModule:_SetupNUICommunication()
    -- NUI page is set in fxmanifest.lua
    -- NUI callbacks are registered in _SetupEventListeners above
end

-- Handle admin command from client
function AdminModule:_HandleAdminCommand(data, cb)
    -- Permission check
    if not self:_CheckAdminPermission(source) then
        cb({status = 'error', message = 'Unauthorized'})
        return
    end

    -- Rate limiting
    if not self:_CheckRateLimit(source) then
        cb({status = 'error', message = 'Rate limit exceeded'})
        return
    end

    local command = data.command
    local args = data.args or {}

    if command == "toggle" then
        self:ToggleNUI()
        cb({status = 'ok'})
    elseif command == "hide" then
        self:HideNUI()
        cb({status = 'ok'})
    elseif command == "show" then
        self:ShowNUI()
        cb({status = 'ok'})
    elseif command == "refresh" then
        self:_RequestNUIUpdate()
        cb({status = 'ok'})
    else
        cb({status = 'error', message = 'Unknown command'})
    end
end

-- Toggle NUI visibility
function AdminModule:ToggleNUI()
    if self.state == AdminModule.State.VISIBLE or self.state == AdminModule.State.SHOWING then
        self:HideNUI()
    else
        self:ShowNUI()
    end
end

-- Show NUI
function AdminModule:ShowNUI()
    if self.state == AdminModule.State.VISIBLE or self.state == AdminModule.State.SHOWING then return end

    self.state = AdminModule.State.SHOWING
    SendNUIMessage({
        action = "show"
    })

    -- Wait a bit for show animation, then set to visible
    Citizen.SetTimeout(300, function()
        if self.state == AdminModule.State.SHOWING then
            self.state = AdminModule.State.VISIBLE
            self:_RequestNUIUpdate()
        end
    end)
end

-- Hide NUI
function AdminModule:HideNUI()
    if self.state == AdminModule.State.HIDDEN or self.state == AdminModule.State.HIDING then return end

    self.state = AdminModule.State.HIDING
    SendNUIMessage({
        action = "hide"
    })

    -- Wait a bit for hide animation, then set to hidden
    Citizen.SetTimeout(300, function()
        if self.state == AdminModule.State.HIDING then
            self.state = AdminModule.State.HIDDEN
        end
    end)
end

-- Check if NUI is visible
function AdminModule:IsVisible()
    return self.state == AdminModule.State.VISIBLE
end

-- NUI update loop
function AdminModule:_NUIUpdateLoop()
    local currentTime = GetGameTimer()

    -- Throttle updates to prevent spamming
    if currentTime - self.lastNUIUpdate < self.nuiUpdateInterval then
        return
    end

    if self:IsVisible() then
        self:_SendNUIUpdate()
    end

    self.lastNUIUpdate = currentTime
end

-- Request an NUI update (will be sent on next loop iteration)
function AdminModule:_RequestNUIUpdate()
    self.lastNUIUpdate = 0  -- Force immediate update
end

-- Send NUI update with current data
function AdminModule:_SendNUIUpdate()
    if not self:IsVisible() then return end

    local adminData = self:_GetAdminData()
    SendNUIMessage({
        action = "update",
        data = adminData
    })
end

-- Get admin data for NUI
function AdminModule:_GetAdminData()
    local data = {
        timestamp = GetGameTimer(),
        zones = self:_GetZonesForAdmin(),
        enemies = self:_GetEnemiesForAdmin(),
        config = self.configLoader:Dump(),
        status = self:_GetModuleStatus(),
        debug = self.debugInfo,
        framework = self.frameworkAdapter.GetName()
    }
    return data
end

-- Get zones formatted for admin NUI
function AdminModule:_GetZonesForAdmin()
    local zones = {}
    local zoneList = self.zoneModule and self.zoneModule.GetZones and self.zoneModule:GetZones() or {}

    for zoneName, zoneData in pairs(zoneList) do
        table.insert(zones, {
            name = zoneName,
            type = zoneData.type or "unknown",
            center = zoneData.center,
            radius = zoneData.radius,
            sizeX = zoneData.sizeX,
            sizeY = zoneData.sizeY,
            heading = zoneData.heading,
            points = zoneData.points,
            spawnEnabled = zoneData.spawn and zoneData.spawn.enabled ~= false,
            spawnRadius = zoneData.spawn and zoneData.spawn.radius or 0,
            maxNPCs = zoneData.spawn and zoneData.spawn.maxNPCs or 0,
            maxVehicles = zoneData.spawn and zoneData.spawn.maxVehicles or 0,
            currentNPCs = 0,  -- Will be updated by zone module
            currentVehicles = 0  -- Will be updated by zone module
        })
    end

    return zones
end

-- Get enemies formatted for admin NUI
function AdminModule:_GetEnemiesForAdmin()
    local enemies = {}
    local entities = self.entityManager:GetActiveEntities()

    for entityId, entityData in pairs(entities) do
        if entityData.isActive and entityData.type == self.constants.EntityType.PED then
            local ped = entityData.properties.handle
            local health = GetEntityHealth(ped)
            local maxHealth = GetEntityMaxHealth(ped)
            local armour = GetPedArmour(ped)

            table.insert(enemies, {
                id = entityId,
                model = entityData.model,
                coords = entityData.coords,
                health = health,
                maxHealth = maxHealth,
                armour = armour,
                behavior = entityData.properties.behavior or "unknown",
                enemyType = entityData.properties.enemyType or "unknown",
                relationship = entityData.properties.relationship or "unknown",
                distanceToPlayer = entityData.distanceToPlayer or 0,
                createdAt = entityData.createdAt
            })
        end
    end

    return enemies
end

-- Get module status for admin NUI
function AdminModule:_GetModuleStatus()
    return {
        npc = self.npcModule and true or false,
        behavior = self.behaviorModule and true or false,
        zone = self.zoneModule and true or false,
        director = false,  -- V2
        vehicle = false,   -- V2
        admin = true
    }
end

-- Handle spawning NPC from admin NUI
function AdminModule:_HandleSpawnNPC(data, cb)
    -- Permission check
    if not self:_CheckAdminPermission(source) then
        cb({status = 'error', message = 'Unauthorized'})
        return
    end

    -- Rate limiting
    if not self:_CheckRateLimit(source) then
        cb({status = 'error', message = 'Rate limit exceeded'})
        return
    end

    -- Validate input
    local isValid, errorMsg = self:_ValidateNPCData(data)
    if not isValid then
        cb({status = 'error', message = errorMsg})
        return
    end

    -- Spawn NPC through core API
    local entityId = self.entityManager:CreateEntity(
        self.constants.EntityType.PED,
        data.model,
        data.coords,
        true,  -- networked
        {
            weapon = data.weapon,
            ammo = data.ammo or 30,
            secondaryWeapon = data.secondaryWeapon,
            secondaryAmmo = data.secondaryAmmo,
            behavior = data.behavior,
            enemyType = data.enemyType or "admin_spawn",
            health = data.health or self.constants.Defaults.HEALTH,
            armor = data.armor or self.constants.Defaults.ARMOR,
            accuracy = data.accuracy or self.constants.Defaults.ACCURACY,
            relationship = data.relationship or self.constants.Relationship.HOSTILE
        }
    )

    if entityId then
        -- Notify modules
        self.eventSystem:emit(EnemyX.Events.ENEMY_SPAWNED, {
            entityId = entityId,
            model = data.model,
            weapon = data.weapon,
            behavior = data.behavior,
            enemyType = data.enemyType or "admin_spawn",
            coords = data.coords
        })

        cb({status = 'ok', entityId = entityId})
    else
        cb({status = 'error', message = 'Failed to spawn NPC'})
    end
end

-- Handle spawning group from admin NUI
function AdminModule:_HandleSpawnGroup(data, cb)
    -- Permission check
    if not self:_CheckAdminPermission(source) then
        cb({status = 'error', message = 'Unauthorized'})
        return
    end

    -- Rate limiting
    if not self:_CheckRateLimit(source) then
        cb({status = 'error', message = 'Rate limit exceeded'})
        return
    end

    -- Validate input
    local isValid, errorMsg = self:_ValidateGroupData(data)
    if not isValid then
        cb({status = 'error', message = errorMsg})
        return
    end

    -- Spawn group through core API
    local groupIds = self.entityManager:CreateEntity(
        self.constants.EntityType.PED,  -- We'll create multiple entities
        data.model or "a_m_m_business_01",
        data.coords,
        true,  -- networked
        {
            weapon = data.weapon or "WEAPON_PISTOL",
            ammo = data.ammo or 30,
            behavior = data.behavior or EnemyX.BehaviorType.AGGRESSIVE,
            enemyType = data.enemyType or "admin_group",
            health = data.health or self.constants.Defaults.HEALTH,
            armor = data.armor or self.constants.Defaults.ARMOR,
            accuracy = data.accuracy or self.constants.Defaults.ACCURACY,
            relationship = data.relationship or self.constants.Relationship.HOSTILE,
            groupId = data.groupName,
            count = data.count
        }
    )

    if groupIds then
        -- Notify modules
        self.eventSystem:emit(EnemyX.Events.ENEMY_SPAWNED, {
            entityIds = groupIds,
            groupName = data.groupName,
            groupSize = data.count,
            coords = data.coords
        })

        cb({status = 'ok', count = #groupIds})
    else
        cb({status = 'error', message = 'Failed to spawn group'})
    end
end

-- Handle creating zone from admin NUI
function AdminModule:_HandleCreateZone(data, cb)
    -- Permission check
    if not self:_CheckAdminPermission(source) then
        cb({status = 'error', message = 'Unauthorized'})
        return
    end

    -- Rate limiting
    if not self:_CheckRateLimit(source) then
        cb({status = 'error', message = 'Rate limit exceeded'})
        return
    end

    -- Validate input
    local isValid, errorMsg = self:_ValidateZoneData(data)
    if not isValid then
        cb({status = 'error', message = errorMsg})
        return
    end

    -- Add zone through config loader (which will propagate to zone module)
    self.configLoader:Set(string.format("Zones.%s", data.name), data)

    -- Trigger config reload to notify all modules
    self.eventSystem:emit(EnemyX.Events.CONFIG_RELOADED, self.configLoader:Dump(), {})

    cb({status = 'ok'})
end

-- Handle removing zone from admin NUI
function AdminModule:_HandleRemoveZone(data, cb)
    -- Permission check
    if not self:_CheckAdminPermission(source) then
        cb({status = 'error', message = 'Unauthorized'})
        return
    end

    -- Rate limiting
    if not self:_CheckRateLimit(source) then
        cb({status = 'error', message = 'Rate limit exceeded'})
        return
    end

    if not data.name or data.name == "" then
        cb({status = 'error', message = 'Invalid zone name'})
        return
    end

    -- Remove from config
    self.configLoader:Set(string.format("Zones.%s", data.name), nil)

    -- Trigger config reload
    self.eventSystem:emit(EnemyX.Events.CONFIG_RELOADED, self.configLoader:Dump(), {})

    cb({status = 'ok'})
end

-- Handle clearing enemies from admin NUI
function AdminModule:_HandleClearEnemies(data, cb)
    -- Permission check
    if not self:_CheckAdminPermission(source) then
        cb({status = 'error', message = 'Unauthorized'})
        return
    end

    -- Rate limiting
    if not self:_CheckRateLimit(source) then
        cb({status = 'error', message = 'Rate limit exceeded'})
        return
    end

    -- Validate input
    if not data.coords or type(data.coords) ~= "userdata" then
        cb({status = 'error', message = 'Invalid coordinates'})
        return
    end

    local radius = data.radius or 50.0
    if type(data.radius) ~= "number" or data.radius <= 0 then
        cb({status = 'error', message = 'Invalid radius'})
        return
    end

    -- Clear enemies in area through core API
    local removedCount = self.entityManager:ClearEnemiesInArea(data.coords, radius)

    cb({status = 'ok', count = removedCount})
end

-- Handle updating configuration from admin NUI
function AdminModule:_HandleUpdateConfig(data, cb)
    -- Permission check
    if not self:_CheckAdminPermission(source) then
        cb({status = 'error', message = 'Unauthorized'})
        return
    end

    -- Rate limiting
    if not self:_CheckRateLimit(source) then
        cb({status = 'error', message = 'Rate limit exceeded'})
        return
    end

    -- Validate input
    local isValid, errorMsg = self:_ValidateConfigData(data.key, data.value)
    if not isValid then
        cb({status = 'error', message = errorMsg})
        return
    end

    -- Set config value
    self.configLoader:Set(data.key, data.value)

    -- Trigger config reload to notify modules
    self.eventSystem:emit(EnemyX.Events.CONFIG_RELOADED, self.configLoader:Dump(), {})

    cb({status = 'ok'})
end

-- Handle setting debug overlay from admin NUI
function AdminModule:_HandleSetDebugOverlay(data, cb)
    -- Permission check
    if not self:_CheckAdminPermission(source) then
        cb({status = 'error', message = 'Unauthorized'})
        return
    end

    -- Rate limiting
    if not self:_CheckRateLimit(source) then
        cb({status = 'error', message = 'Rate limit exceeded'})
        return
    end

    local enabled = data.enabled ~= false
    -- This would trigger a client event to toggle debug overlay
    TriggerClientEvent('enemyx:client:setDebugOverlay', -1, enabled)
    self.debugInfo.overlayEnabled = enabled

    cb({status = 'ok'})
end

-- Handle configuration reload
function AdminModule:_OnConfigReload(newConfig, oldConfig)
    print("[EnemyX Admin] Configuration reloaded")
    self:_RequestNUIUpdate()  -- Update NUI with new config
end

-- Export functions for other resources
exports('ShowNUI', function()
    local adminModule = GetResourceState('enemyx') and exports['enemyx'] and exports['enemyx']:GetAdminModule()
    if adminModule and type(adminModule.ShowNUI) == "function" then
        adminModule:ShowNUI()
    end
end)

exports('HideNUI', function()
    local adminModule = GetResourceState('enemyx') and exports['enemyx'] and exports['enemyx']:GetAdminModule()
    if adminModule and type(adminModule.HideNUI) == "function" then
        adminModule:HideNUI()
    end
end)

exports('ToggleNUI', function()
    local adminModule = GetResourceState('enemyx') and exports['enemyx'] and exports['enemyx']:GetAdminModule()
    if adminModule and type(adminModule.ToggleNUI) == "function" then
        adminModule:ToggleNUI()
    end
end)

exports('IsAdminVisible', function()
    local adminModule = GetResourceState('enemyx') and exports['enemyx'] and exports['enemyx']:GetAdminModule()
    if adminModule and type(adminModule.IsVisible) == "function" then
        return adminModule:IsVisible()
    end
    return false
end)

return AdminModule