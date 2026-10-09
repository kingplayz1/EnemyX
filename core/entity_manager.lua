-- EnemyX Entity Manager
-- Handles entity lifecycle, pooling, and cleanup

local EnemyX = require 'shared/constants'
local Utils = require 'shared/utils'
local EventSystem = require 'core/events'

local EntityManager = {}
EntityManager.__index = EntityManager

-- Entity types
EntityManager.EntityType = {
    PED = "ped",
    VEHICLE = "vehicle"
}

-- Pool configuration
EntityManager.PoolConfig = {
    [EntityManager.EntityType.PED] = {
        maxSize = EnemyX.Pooling.MAX_PED_POOL,
        prewarmModels = EnemyX.Pooling.PREWARM_COMMON_MODELS
    },
    [EntityManager.EntityType.VEHICLE] = {
        maxSize = EnemyX.Pooling.MAX_VEHICLE_POOL,
        prewarmModels = {}  -- Will be populated from vehicle configs
    }
}

-- Create a new entity manager
function EntityManager:new()
    local self = setmetatable({}, EntityManager)
    self.entities = {}           -- entityId -> entityData
    self.pools = {}              -- entityType -> {model -> {entities}}
    self.nextEntityId = 1
    self.cleanupCallbacks = {}   -- entityId -> cleanupFunction
    self.eventSystem = EventSystem:new()

    -- Initialize pools
    for entityType, config in pairs(EntityManager.PoolConfig) do
        self.pools[entityType] = {}
        -- Prewarm common models
        for _, model in ipairs(config.prewarmModels) do
            self.pools[entityType][model] = {}
        end
    end

    return self
end

-- Generate unique entity ID
function EntityManager:_generateEntityId()
    local id = tostring(self.nextEntityId)
    self.nextEntityId = self.nextEntityId + 1
    return id
end

-- Create or get entity from pool
-- @param entityType string - PED or VEHICLE
-- @param model string - Model hash or name
-- @param coords vector3 - Initial position
-- @param networked boolean - Whether entity should be networked
-- @param properties table - Additional entity properties
-- @return entityId string - Unique ID for the entity
function EntityManager:CreateEntity(entityType, model, coords, networked, properties)
    -- Validate inputs
    if not entityType or not self.EntityType[entityType] then
        error("Invalid entity type: " .. tostring(entityType))
    end
    if not model or type(model) ~= "string" then
        error("Model must be a non-empty string")
    end
    if not coords or type(coords) ~= "userdata" then
        error("Coords must be a vector3")
    end

    -- Try to get from pool first
    local pooledEntity = self:_getFromPool(entityType, model)
    local entityId

    if pooledEntity then
        entityId = pooledEntity.id
        -- Reset entity to clean state
        self:_resetEntity(entityId, entityType, model, coords, networked, properties)
    else
        -- Create new entity
        entityId = self:_generateEntityId()
        self:_createNewEntity(entityId, entityType, model, coords, networked, properties)
    end

    -- Store entity data
    self.entities[entityId] = {
        id = entityId,
        type = entityType,
        model = model,
        coords = coords,
        networked = networked or false,
        properties = properties or {},
        createdAt = GetGameTimer(),
        lastUpdated = GetGameTimer(),
        distanceToPlayer = 0,
        updateLevel = EnemyX.UpdateRates.LOW,  -- Start with lowest update rate
        isActive = true,
        inPool = false
    }

    -- Register cleanup callback for when entity is removed
    self.cleanupCallbacks[entityId] = function()
        self:RemoveEntity(entityId)
    end

    -- Emit event
    self.eventSystem:emit(EnemyX.Events.ENEMY_SPAWNED, {
        entityId = entityId,
        entityType = entityType,
        model = model,
        coords = coords
    })

    return entityId
end

-- Get entity from pool if available
function EntityManager:_getFromPool(entityType, model)
    local pool = self.pools[entityType]
    if not pool[model] then
        pool[model] = {}  -- Initialize pool for this model
    end

    if #pool[model] > 0 then
        return table.remove(pool[model])  -- LIFO for better cache locality
    end

    return nil
end

-- Create a new entity (not from pool)
function EntityManager:_createNewEntity(entityId, entityType, model, coords, networked, properties)
    local entityHandle

    if entityType == EntityManager.EntityType.PED then
        -- Request model if needed
        if not HasModelLoaded(GetHashKey(model)) then
            RequestModel(GetHashKey(model))
            -- Note: In real implementation, we'd wait for model to load
            -- For now, we assume it's available or handle async elsewhere
        end

        entityHandle = CreatePed(
            4,  -- pedType: civilian
            GetHashKey(model),
            coords.x, coords.y, coords.z,
            0.0,  -- heading
            networked or false,  -- networked
            false  -- thisScriptCheck
        )

        if entityHandle ~= 0 then
            -- Set default ped properties
            SetEntityAsMissionEntity(entityHandle, true, true)
            SetBlockingOfNonTemporaryEvents(entityHandle, true)
            SetPedRandomComponentVariation(entityHandle, false)
            SetPedRandomProps(entityHandle, false)
            SetEntityInvincible(entityHandle, false)
            SetEntityCanBeDamaged(entityHandle, true)
            SetEntityHealth(entityHandle, GetEntityMaxHealth(entityHandle))
        end

    elseif entityType == EntityManager.EntityType.VEHICLE then
        if not HasModelLoaded(GetHashKey(model)) then
            RequestModel(GetHashKey(model))
        end

        entityHandle = CreateVehicle(
            GetHashKey(model),
            coords.x, coords.y, coords.z,
            0.0,  -- heading
            networked or false,  -- networked
            false  -- thisScriptCheck
        )

        if entityHandle ~= 0 then
            SetEntityAsMissionEntity(entityHandle, true, true)
            SetVehicleHasBeenOwnedByPlayer(entityHandle, false)
            SetNeedsVehicleHealthMultiplyer(entityHandle, true)
        end
    end

    -- Store handle in properties for quick access
    if properties then
        properties.handle = entityHandle
    end
end

-- Reset entity to clean state (for pooling)
function EntityManager:_resetEntity(entityId, entityType, model, coords, networked, properties)
    local entityData = self.entities[entityId]
    if not entityData then return end

    local entityHandle = entityData.properties.handle

    if entityHandle and entityHandle ~= 0 then
        -- Clear ped/vehicle state
        if entityType == EntityManager.EntityType.PED then
            ClearPedTasks(entityHandle)
            ClearPedBloodDamage(entityHandle)
            ResetPedVisibleDamage(entityHandle)
            ClearPedLastWeaponDamage(entityHandle)
            SetEntityCoords(entityHandle, coords.x, coords.y, coords.z, false, false, false, true)
            SetEntityHeading(entityHandle, 0.0)

            -- Reset health to max
            local maxHealth = GetEntityMaxHealth(entityHandle)
            SetEntityHealth(entityHandle, maxHealth)

        elseif entityType == EntityManager.EntityType.VEHICLE then
            SetEntityCoords(entityHandle, coords.x, coords.y, coords.z, false, false, false, true)
            SetEntityHeading(entityHandle, 0.0)
            SetVehicleFixed(entityHandle)
            SetVehicleDeformationFixed(entityHandle)
            SetVehicleUndriveable(entityHandle, false)
            SetVehicleEngineOn(entityHandle, true, true, true)
            SetVehiclePetrolTankHealth(entityHandle, 1000.0)
        end
    end

    -- Update entity data
    entityData.model = model
    entityData.coords = coords
    entityData.networked = networked or false
    entityData.properties = properties or {}
    entityData.createdAt = GetGameTimer()
    entityData.lastUpdated = GetGameTimer()
    entityData.distanceToPlayer = 0
    entityData.updateLevel = EnemyX.UpdateRates.LOW
    entityData.isActive = true
    entityData.inPool = false
end

-- Remove entity and return to pool
function EntityManager:RemoveEntity(entityId)
    local entityData = self.entities[entityId]
    if not entityData then return false end  -- Already removed or doesn't exist

    local entityHandle = entityData.properties.handle

    -- Return to pool if under limit
    if entityHandle and entityHandle ~= 0 then
        local pool = self.pools[entityData.type]
        if pool[entityData.model] and #pool[entityData.model] < EntityManager.PoolConfig[entityData.type].maxSize then
            table.insert(pool[entityData.model], entityData)
            entityData.inPool = true
            entityData.isActive = false
        else
            -- Pool full or not tracked, delete entity
            if DoesEntityExist(entityHandle) then
                DeleteEntity(entityHandle)
            end
        end
    end

    -- Cleanup
    self.cleanupCallbacks[entityId] = nil
    self.entities[entityId] = nil

    -- Emit event
    self.eventSystem:emit(EnemyX.Events.ENEMY_DIED, {
        entityId = entityId,
        entityType = entityData.type,
        model = entityData.model
    })

    return true
end

-- Update entity position and state
function EntityManager:UpdateEntity(entityId, updates)
    local entityData = self.entities[entityId]
    if not entityData or not entityData.isActive then return false end

    local entityHandle = entityData.properties.handle
    if not entityHandle or entityHandle == 0 then
        self:RemoveEntity(entityId)  -- Clean up invalid entity
        return false
    end

    -- Apply updates
    if updates.coords then
        SetEntityCoords(entityHandle, updates.coords.x, updates.coords.y, updates.coords.z, false, false, false, true)
        entityData.coords = updates.coords
    end

    if updates.heading ~= nil then
        SetEntityHeading(entityHandle, updates.heading)
    end

    if updates.health ~= nil then
        SetEntityHealth(entityHandle, updates.health)
    end

    if updates.properties then
        for k, v in pairs(updates.properties) do
            entityData.properties[k] = v
        end
    end

    entityData.lastUpdated = GetGameTimer()

    return true
end

-- Get entity handle by ID
function EntityManager:GetEntityHandle(entityId)
    local entityData = self.entities[entityId]
    if entityData and entityData.isActive then
        return entityData.properties.handle
    end
    return nil
end

-- Get entity data by ID
function EntityManager:GetEntityData(entityId)
    return self.entities[entityId]
end

-- Get all active entities
function EntityManager:GetActiveEntities()
    local active = {}
    for entityId, entityData in pairs(self.entities) do
        if entityData.isActive then
            active[entityId] = entityData
        end
    end
    return active
end

-- Get entities by type
function EntityManager:GetEntitiesByType(entityType)
    local entities = {}
    for entityId, entityData in pairs(self.entities) do
        if entityData.isActive and entityData.type == entityType then
            entities[entityId] = entityData
        end
    end
    return entities
end

-- Update distance to player for all entities (called externally)
function EntityManager:UpdatePlayerDistances(playerCoords)
    for entityId, entityData in pairs(self.entities) do
        if entityData.isActive and entityData.properties.handle then
            local dist = Utils.GetDistance(
                entityData.coords,
                playerCoords,
                true
            )
            entityData.distanceToPlayer = dist

            -- Update update level based on distance
            if dist <= EnemyX.Performance.HIGH_DISTANCE then
                entityData.updateLevel = EnemyX.UpdateRates.HIGH
            elseif dist <= EnemyX.Performance.MEDIUM_DISTANCE then
                entityData.updateLevel = EnemyX.UpdateRates.MEDIUM
            elseif dist <= EnemyX.Performance.LOW_DISTANCE then
                entityData.updateLevel = EnemyX.UpdateRates.LOW
            else
                entityData.updateLevel = 0  -- Dormant, no updates
            end
        end
    end
end

-- Get entities that should be updated this frame
-- @param currentTime number - Current game time
-- @return array - Entity IDs that need updating
function EntityManager:GetEntitiesForUpdate(currentTime)
    local entitiesToUpdate = {}

    for entityId, entityData in pairs(self.entities) do
        if entityData.isActive and entityData.updateLevel > 0 then
            -- Check if enough time has passed since last update
            if currentTime - entityData.lastUpdated >= entityData.updateLevel then
                table.insert(entitiesToUpdate, entityId)
            end
        end
    end

    return entitiesToUpdate
end

-- Cleanup all entities (called on resource stop)
function EntityManager:CleanupAll()
    for entityId, entityData in pairs(self.entities) do
        if entityData.isActive then
            self:RemoveEntity(entityId)
        end
    end

    -- Clear pools
    for entityType, pool in pairs(self.pools) do
        for model, entities in pairs(pool) do
            for _, entityData in ipairs(entities) do
                if entityData.properties.handle and DoesEntityExist(entityData.properties.handle) then
                    DeleteEntity(entityData.properties.handle)
                end
            end
            self.pools[entityType][model] = {}
        end
    end
end

return EntityManager