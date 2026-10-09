-- EnemyX Behavior Module
-- Implements NPC behaviors: patrol, guard, chase, investigate

local EnemyX = require 'shared/constants'
local Utils = require 'shared/utils'
local EventSystem = require 'core.events'

local BehaviorModule = {}
BehaviorModule.__index = BehaviorModule

-- Behavior priorities (higher number = higher priority)
BehaviorModule.Priority = {
    INVESTIGATE = 4,  -- Highest priority - check disturbances
    CHASE = 3,        -- Pursue target
    GUARD = 2,        -- Defend area
    PATROL = 1,       -- Follow waypoints
    PASSIVE = 0       -- Lowest priority - do nothing
}

-- Create a new behavior module instance
function BehaviorModule:new(dependencies)
    local self = setmetatable({}, BehaviorModule)
    self.eventSystem = dependencies.eventSystem
    self.configLoader = dependencies.configLoader
    self.entityManager = dependencies.entityManager
    self.constants = dependencies.constants
    self.utils = dependencies.utils
    self.initialized = false
    self.activeBehaviors = {}  -- entityId -> {behaviorType, data, priority}

    return self
end

-- Initialize the behavior module
function BehaviorModule:Initialize()
    if self.initialized then return end

    print("[EnemyX Behavior] Initializing...")

    -- Set up event listeners
    self:_SetupEventListeners()

    self.initialized = true
    print("[EnemyX Behavior] Initialized")
end

-- Start the module
function BehaviorModule:Start()
    -- Start the behavior update loop
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            self:_UpdateBehaviorLoop()
        end
    end)
    print("[EnemyX Behavior] Started")
end

-- Stop the module
function BehaviorModule:Stop()
    print("[EnemyX Behavior] Stopped")
end

-- Cleanup the module
function BehaviorModule:Cleanup()
    self.activeBehaviors = {}
    print("[EnemyX Behavior] Cleaned up")
end

-- Set up event listeners
function BehaviorModule:_SetupEventListeners()
    -- Listen for enemy spawns to initialize behaviors
    self.eventSystem:on(EnemyX.Events.ENEMY_SPAWNED, function(data)
        self:_InitializeBehaviorForEntity(data.entityId, data)
    end)

    -- Listen for enemy updates to potentially change behaviors
    self.eventSystem:on(EnemyX.Events.ENEMY_UPDATED, function(data)
        self:_HandleEnemyUpdate(data)
    end)

    -- Listen for player entering zones (could trigger behavior changes)
    self.eventSystem:on(EnemyX.Events.PLAYER_ENTERED_ZONE, function(data)
        self:_HandlePlayerZoneEvent(data, true)
    end)

    -- Listen for player exiting zones
    self.eventSystem:on(EnemyX.Events.PLAYER_EXITED_ZONE, function(data)
        self:_HandlePlayerZoneEvent(data, false)
    end)

    -- Listen for config reloads
    self.eventSystem:on(EnemyX.Events.CONFIG_RELOADED, function(newConfig, oldConfig)
        self:_OnConfigReload(newConfig, oldConfig)
    end)
end

-- Initialize behavior for a newly spawned entity
function BehaviorModule:_InitializeBehaviorForEntity(entityId, spawnData)
    local entityData = self.entityManager:GetEntityData(entityId)
    if not entityData or not entityData.isActive then return end

    local behaviorType = spawnData.behavior or EnemyX.BehaviorType.PASSIVE
    local behaviorData = self:_GetBehaviorDataForType(behaviorType, spawnData)

    self:SetBehavior(entityId, behaviorType, behaviorData)
end

-- Get behavior data based on type and spawn data
function BehaviorModule:_GetBehaviorDataForType(behaviorType, spawnData)
    local baseData = {}

    if behaviorType == EnemyX.BehaviorType.PATROL then
        baseData = {
            waypoints = spawnData.waypoints or {},
            currentWaypointIndex = 1,
            patrolSpeed = spawnData.patrolSpeed or 5.0,
            waitAtWaypoint = spawnData.waitAtWaypoint or 2000,  -- ms
            lastWaypointTime = 0,
            loopPatrol = spawnData.loopPatrol ~= false
        }
    elseif behaviorType == EnemyX.BehaviorType.GUARD then
        baseData = {
            guardPosition = spawnData.guardPosition or spawnData.coords or vector3(0, 0, 0),
            guardRadius = spawnData.guardRadius or 10.0,
            investigateShots = spawnData.investigateShots ~= false,
            investigateDist = spawnData.investigateDist or 15.0,
            alertness = spawnData.alertness or 1.0  -- 0.0-2.0 multiplier
        }
    elseif behaviorType == EnemyX.BehaviorType.CHASE then
        baseData = {
            targetEntityId = spawnData.targetEntityId or nil,
            targetPosition = spawnData.targetPosition or nil,
            chaseSpeed = spawnData.chaseSpeed or 8.0,
            giveUpDistance = spawnData.giveUpDistance or 100.0,
            giveUpTime = spawnData.giveUpTime or 15000,  -- ms
            lastSeenTime = 0,
            persistent = spawnData.persistent ~= false
        }
    elseif behaviorType == EnemyX.BehaviorType.INVESTIGATE then
        baseData = {
            investigatePosition = spawnData.investigatePosition or spawnData.coords or vector3(0, 0, 0),
            investigateRadius = spawnData.investigateRadius or 20.0,
            investigateSpeed = spawnData.investigateSpeed or 4.0,
            returnToPost = spawnData.returnToPost ~= false,
            returnSpeed = spawnData.returnSpeed or 3.0,
            maxInvestigateTime = spawnData.maxInvestigateTime or 10000,  -- ms
            investigateStartTime = 0,
            isInvestigating = false
        }
    elseif behaviorType == EnemyX.BehaviorType.SNIPER then
        baseData = {
            preferredPosition = spawnData.preferredPosition or spawnData.coords or vector3(0, 0, 0),
            preferredDistance = spawnData.preferredDistance or 30.0,
            minDistance = spawnData.minDistance or 20.0,
            maxDistance = spawnData.maxDistance or 50.0,
            seekHeight = spawnData.seekHeight ~= false,
            fireInterval = spawnData.fireInterval or 3000,  -- ms
            lastFireTime = 0
        }
    else  -- PASSIVE
        baseData = {}
    end

    return baseData
end

-- Set behavior for an entity
function BehaviorModule:SetBehavior(entityId, behaviorType, behaviorData)
    -- Validate inputs
    if not entityId or type(entityId) ~= "string" then
        error("Entity ID must be a non-empty string")
    end
    if not behaviorType then
        error("Behavior type is required")
    end

    local entityData = self.entityManager:GetEntityData(entityId)
    if not entityData or not entityData.isActive then
        print(("[EnemyX Behavior] Warning: Cannot set behavior for inactive entity %s"):format(entityId))
        return false
    end

    -- Remove any existing behavior for this entity
    self:ClearBehavior(entityId)

    -- Store the new behavior
    local priority = self.Priority[behaviorType] or self.Priority.PASSIVE
    self.activeBehaviors[entityId] = {
        type = behaviorType,
        data = behaviorData or {},
        priority = priority,
        assignedAt = GetGameTimer()
    }

    -- Initialize behavior-specific data
    self:_InitializeBehavior(entityId, behaviorType, behaviorData or {})

    -- Notify via event
    self.eventSystem:emit(EnemyX.Events.ENEMY_UPDATED, {
        entityId = entityId,
        behaviorChanged = true,
        newBehavior = behaviorType,
        oldBehavior = nil
    })

    return true
end

-- Clear behavior for an entity
function BehaviorModule:ClearBehavior(entityId)
    if not entityId then return end

    local oldBehavior = self.activeBehaviors[entityId]
    if oldBehavior then
        self.activeBehaviors[entityId] = nil

        -- Notify via event
        self.eventSystem:emit(EnemyX.Events.ENEMY_UPDATED, {
            entityId = entityId,
            behaviorChanged = true,
            newBehavior = nil,
            oldBehavior = oldBehavior.type
        })
    end
end

-- Get current behavior for an entity
function BehaviorModule:GetBehavior(entityId)
    if not entityId then return nil end
    local behavior = self.activeBehaviors[entityId]
    if behavior then
        return behavior.type, behavior.data
    end
    return nil, nil
end

-- Initialize behavior-specific data
function BehaviorModule:_InitializeBehavior(entityId, behaviorType, behaviorData)
    local entityData = self.entityManager:GetEntityData(entityId)
    if not entityData or not entityData.isActive then return end

    local ped = entityData.properties.handle
    if not ped or ped == 0 then return end

    -- Initialize based on behavior type
    if behaviorType == EnemyX.BehaviorType.PATROL then
        -- Initialize patrol data
        if not behaviorData.waypoints or #behaviorData.waypoints == 0 then
            -- If no waypoints, use current position as single waypoint
            local coords = GetEntityCoords(ped, true)
            behaviorData.waypoints = {coords}
            behaviorData.currentWaypointIndex = 1
        end
        behaviorData.lastWaypointTime = GetGameTimer()

    elseif behaviorType == EnemyX.BehaviorType.GUARD then
        -- Initialize guard data
        if not behaviorData.guardPosition then
            behaviorData.guardPosition = GetEntityCoords(ped, true)
        end

    elseif behaviorType == EnemyX.BehaviorType.CHASE then
        -- Initialize chase data
        if behaviorData.targetEntityId then
            -- Validate target exists
            local targetData = self.entityManager:GetEntityData(behaviorData.targetEntityId)
            if not targetData or not targetData.isActive then
                behaviorData.targetEntityId = nil
            end
        end
        behaviorData.lastSeenTime = GetGameTimer()

    elseif behaviorType == EnemyX.BehaviorType.INVESTIGATE then
        -- Initialize investigate data
        if not behaviorData.investigatePosition then
            behaviorData.investigatePosition = GetEntityCoords(ped, true)
        end
        behaviorData.isInvestigating = false
        behaviorData.investigateStartTime = 0

    elseif behaviorType == EnemyX.BehaviorType.SNIPER then
        -- Initialize sniper data
        if not behaviorData.preferredPosition then
            behaviorData.preferredPosition = GetEntityCoords(ped, true)
        end
        behaviorData.lastFireTime = 0
    end
end

-- Main behavior update loop
function BehaviorModule:_UpdateBehaviorLoop()
    local currentTime = GetGameTimer()

    -- Process each active behavior
    for entityId, behaviorInfo in pairs(self.activeBehaviors) do
        local entityData = self.entityManager:GetEntityData(entityId)
        if entityData and entityData.isActive then
            self:_UpdateEntityBehavior(entityId, behaviorInfo, currentTime)
        else
            -- Entity no longer exists, clean up behavior
            self.activeBehaviors[entityId] = nil
        end
    end
end

-- Update behavior for a specific entity
function BehaviorModule:_UpdateEntityBehavior(entityId, behaviorInfo, currentTime)
    local entityData = self.entityManager:GetEntityData(entityId)
    if not entityData or not entityData.isActive then return end

    local ped = entityData.properties.handle
    if not ped or ped == 0 then return end

    local behaviorType = behaviorInfo.type
    local behaviorData = behaviorInfo.data

    -- Update based on behavior type
    if behaviorType == EnemyX.BehaviorType.PATROL then
        self:_UpdatePatrolBehavior(ped, behaviorData, currentTime)
    elseif behaviorType == EnemyX.BehaviorType.GUARD then
        self:_UpdateGuardBehavior(ped, behaviorData, currentTime)
    elseif behaviorType == EnemyX.BehaviorType.CHASE then
        self:_UpdateChaseBehavior(ped, behaviorData, currentTime)
    elseif behaviorType == EnemyX.BehaviorType.INVESTIGATE then
        self:_UpdateInvestigateBehavior(ped, behaviorData, currentTime)
    elseif behaviorType == EnemyX.BehaviorType.SNIPER then
        self:_UpdateSniperBehavior(ped, behaviorData, currentTime)
    end
    -- PASSIVE behavior does nothing
end

-- Update patrol behavior
function BehaviorModule:_UpdatePatrolBehavior(ped, behaviorData, currentTime)
    if not behaviorData.waypoints or #behaviorData.waypoints == 0 then return end

    local waypointCount = #behaviorData.waypoints
    local currentIndex = behaviorData.currentWaypointIndex
    local targetWaypoint = behaviorData.waypoints[currentIndex]

    if not targetWaypoint then return end

    -- Move toward waypoint
    local pedCoords = GetEntityCoords(ped, true)
    local distToWaypoint = Utils.GetDistance(pedCoords, targetWaypoint, true)

    if distToWaypoint < 1.0 then  -- Reached waypoint
        -- Wait at waypoint if specified
        if behaviorData.waitAtWaypoint > 0 then
            if currentTime - behaviorData.lastWaypointTime < behaviorData.waitAtWaypoint then
                -- Still waiting, don't move to next waypoint
                SetPedDesiredMoveBlendRatio(ped, 0.0)
                return
            end
        end

        -- Move to next waypoint
        behaviorData.lastWaypointTime = currentTime
        behaviorData.currentWaypointIndex = behaviorData.currentWaypointIndex + 1

        if behaviorData.currentWaypointIndex > waypointCount then
            if behaviorData.loopPatrol then
                behaviorData.currentWaypointIndex = 1
            else
                -- Patrol complete, stop at last waypoint
                behaviorData.currentWaypointIndex = waypointCount
                SetPedDesiredMoveBlendRatio(ped, 0.0)
                return
            end
        end

        targetWaypoint = behaviorData.waypoints[behaviorData.currentWaypointIndex]
    end

    -- Move toward current waypoint
    if distToWaypoint > 0.5 then  // Only move if not already there
        SetPedDesiredMoveBlendRatio(ped, behaviorData.patrolSpeed / 7.0)  // Normalize speed
        TaskGoStraightToCoord(ped, targetWaypoint.x, targetWaypoint.y, targetWaypoint.z, behaviorData.patrolSpeed, -1, 0.0, 0.0)
    else
        SetPedDesiredMoveBlendRatio(ped, 0.0)
    end
end

-- Update guard behavior
function BehaviorModule:_UpdateGuardBehavior(ped, behaviorData, currentTime)
    local guardPos = behaviorData.guardPosition
    local guardRadius = behaviorData.guardRadius or 10.0

    local pedCoords = GetEntityCoords(ped, true)
    local distFromGuard = Utils.GetDistance(pedCoords, guardPos, true)

    -- Check if we should investigate (shots, disturbances)
    if behaviorData.investigateShots then
        -- In a full implementation, we'd check for nearby gunshots
        -- For now, we'll just do basic guard behavior
    end

    -- If we're outside guard radius, return to guard position
    if distFromGuard > guardRadius then
        -- Move back to guard position
        if distFromGuard > 0.5 then
            SetPedDesiredMoveBlendRatio(ped, 5.0 / 7.0)  -- Walk speed
            TaskGoStraightToCoord(ped, guardPos.x, guardPos.y, guardPos.z, 5.0, -1, 0.0, 0.0)
        else
            SetPedDesiredMoveBlendRatio(ped, 0.0)
        end
    else
        -- We're in guard position, look around
        SetPedDesiredMoveBlendRatio(ped, 0.0)
        -- In full implementation, we'd scan for threats
    end
end

-- Update chase behavior
function BehaviorModule:_UpdateChaseBehavior(ped, behaviorData, currentTime)
    local targetPos = nil
    local targetValid = false

    -- Get target position from entity ID or direct coordinates
    if behaviorData.targetEntityId then
        local targetData = self.entityManager:GetEntityData(behaviorData.targetEntityId)
        if targetData and targetData.isActive then
            targetPos = GetEntityCoords(targetData.properties.handle, true)
            targetValid = true
            behaviorData.lastSeenTime = currentTime
        else
            -- Target no longer valid, use last known position if persistent
            if not behaviorData.persistent then
                behaviorData.targetEntityId = nil
            end
        end
    end

    if behaviorData.targetPosition then
        targetPos = behaviorData.targetPosition
        targetValid = true
    end

    if not targetValid then
        -- No valid target, check if we should give up
        if currentTime - behaviorData.lastSeenTime > behaviorData.giveUpTime then
            -- Give up chasing
            SetPedDesiredMoveBlendRatio(ped, 0.0)
            return
        end
        -- If persistent, continue to last known position
        if not behaviorData.persistent then
            SetPedDesiredMoveBlendRatio(ped, 0.0)
            return
        end
        targetPos = behaviorData.targetPosition  -- Last known position
    end

    -- Chase the target
    local pedCoords = GetEntityCoords(ped, true)
    local distToTarget = Utils.GetDistance(pedCoords, targetPos, true)

    if distToTarget > behaviorData.giveUpDistance then
        -- Too far away, give up
        if behaviorData.persistent then
            // Continue chasing but maybe slow down
            SetPedDesiredMoveBlendRatio(ped, 3.0 / 7.0)  -- Slow jog
        else
            SetPedDesiredMoveBlendRatio(ped, 0.0)
            return
        end
    end

    if distToTarget > 1.0 then
        // Chase target
        SetPedDesiredMoveBlendRatio(ped, behaviorData.chaseSpeed / 7.0)
        TaskGoStraightToCoord(ped, targetPos.x, targetPos.y, targetPos.z, behaviorData.chaseSpeed, -1, 0.0, 0.0)
    else
        // Reached target
        SetPedDesiredMoveBlendRatio(ped, 0.0)
        // In full implementation, we'd attack the target here
    end
end

-- Update investigate behavior
function BehaviorModule:_UpdateInvestigateBehavior(ped, behaviorData, currentTime)
    local investigatePos = behaviorData.investigatePosition
    local investigateRadius = behaviorData.investigateRadius or 20.0

    local pedCoords = GetEntityCoords(ped, true)
    local distToInvestigate = Utils.GetDistance(pedCoords, investigatePos, true)

    if not behaviorData.isInvestigating then
        // Not currently investigating, check if we should start
        if distToInvestigate <= investigateRadius then
            // Start investigating
            behaviorData.isInvestigating = true
            behaviorData.investigateStartTime = currentTime
            SetPedDesiredMoveBlendRatio(ped, behaviorData.investigateSpeed / 7.0)
            TaskGoStraightToCoord(ped, investigatePos.x, investigatePos.y, investigatePos.z, behaviorData.investigateSpeed, -1, 0.0, 0.0)
        else
            // Not close enough to investigate, return to post if configured
            if behaviorData.returnToPost and distToInvestigate > 0.5 then
                local returnPos = behaviorData.investigatePosition  // Original position
                SetPedDesiredMoveBlendRatio(ped, behaviorData.returnSpeed / 7.0)
                TaskGoStraightToCoord(ped, returnPos.x, returnPos.y, returnPos.z, behaviorData.returnSpeed, -1, 0.0, 0.0)
            else
                SetPedDesiredMoveBlendRatio(ped, 0.0)
            end
        end
    else
        // Currently investigating
        local investigateTime = currentTime - behaviorData.investigateStartTime

        if investigateTime >= behaviorData.maxInvestigateTime then
            // Time's up, stop investigating
            behaviorData.isInvestigating = false
            if behaviorData.returnToPost then
                local returnPos = behaviorData.investigatePosition
                SetPedDesiredMoveBlendRatio(ped, behaviorData.returnSpeed / 7.0)
                TaskGoStraightToCoord(ped, returnPos.x, returnPos.y, returnPos.z, behaviorData.returnSpeed, -1, 0.0, 0.0)
            else
                SetPedDesiredMoveBlendRatio(ped, 0.0)
            end
        elseif distToInvestigate <= 1.0 then
            // At investigate point, look around
            SetPedDesiredMoveBlendRatio(ped, 0.0)
            // In full implementation, we'd play an animation or look around
        else
            // Moving to investigate point
            SetPedDesiredMoveBlendRatio(ped, behaviorData.investigateSpeed / 7.0)
            TaskGoStraightToCoord(ped, investigatePos.x, investigatePos.y, investigatePos.z, behaviorData.investigateSpeed, -1, 0.0, 0.0)
        end
    end
end

-- Update sniper behavior
function BehaviorModule:_UpdateSniperBehavior(ped, behaviorData, currentTime)
    local preferredPos = behaviorData.preferredPosition
    local minDist = behaviorData.minDistance or 20.0
    local maxDist = behaviorData.maxDistance or 50.0
    local seekHeight = behaviorData.seekHeight ~= false

    local pedCoords = GetEntityCoords(ped, true)
    local distToPreferred = Utils.GetDistance(pedCoords, preferredPos, true)

    // Try to maintain preferred distance and height
    local shouldMove = false
    local targetPos = preferredPos

    if distToPreferred < minDist then
        // Too close, back away
        shouldMove = true
        // Calculate away vector
        local dx = pedCoords.x - preferredPos.x
        local dy = pedCoords.y - preferredPos.y
        local dz = pedCoords.z - preferredPos.z
        local dist = math.sqrt(dx*dx + dy*dy + dz*dz)
        if dist > 0 then
            targetPos = vector3(
                pedCoords.x + (dx/dist) * (minDist - distToPreferred) * 0.5,
                pedCoords.y + (dy/dist) * (minDist - distToPreferred) * 0.5,
                pedCoords.z + (dz/dist) * (minDist - distToPreferred) * 0.5
            )
        end
    elseif distToPreferred > maxDist then
        // Too far, move closer
        shouldMove = true
        // Calculate toward vector
        local dx = preferredPos.x - pedCoords.x
        local dy = preferredPos.y - pedCoords.y
        local dz = preferredPos.z - pedCoords.z
        local dist = math.sqrt(dx*dx + dy*dy + dz*dz)
        if dist > 0 then
            targetPos = vector3(
                pedCoords.x + (dx/dist) * (distToPreferred - maxDist) * 0.5,
                pedCoords.y + (dy/dist) * (distToPreferred - maxDist) * 0.5,
                pedCoords.z + (dz/dist) * (distToPreferred - maxDist) * 0.5
            )
        end
    end

    // Height seeking (simplified)
    if seekHeight then
        local groundZ = GetGroundZFor_3DCoord(preferredPos.x, preferredPos.y, preferredPos.z + 10.0)
        local heightDiff = pedCoords.z - groundZ
        if heightDiff < 2.0 then  // Want to be higher
            targetPos.z = targetPos.z + 5.0
        end
    end

    if shouldMove and distToPreferred > 0.5 then
        SetPedDesiredMoveBlendRatio(ped, 3.0 / 7.0)  // Walking speed
        TaskGoStraightToCoord(ped, targetPos.x, targetPos.y, targetPos.z, 3.0, -1, 0.0, 0.0)
    else
        SetPedDesiredMoveBlendRatio(ped, 0.0)
        // In full implementation, we'd aim and shoot periodically
    end

    // Handle firing
    if currentTime - behaviorData.lastFireTime > behaviorData.fireInterval then
        // Try to fire at target
        behaviorData.lastFireTime = currentTime
        // In full implementation: clear tasks, aim at target, shoot
    end
end

-- Handle enemy update (potential behavior changes)
function BehaviorModule:_HandleEnemyUpdate(data)
    local entityId = data.entityId
    if not self.activeBehaviors[entityId] then return end  // No behavior to update

    local entityData = self.entityManager:GetEntityData(entityId)
    if not entityData or not entityData.isActive then
        self:ClearBehavior(entityId)
        return
    end

    -- Check if we need to change behavior based on new data
    -- For now, we keep the assigned behavior unless explicitly changed
    -- In future, this could handle dynamic behavior changes
end

-- Handle player zone events
function BehaviorModule:_HandlePlayerZoneEvent(data, entered)
    -- This could trigger behavior changes for NPCs in the zone
    -- For example, entering an alert zone could change guard to investigate
    -- Implementation would depend on zone-specific behavior mappings
end

-- Handle configuration reload
function BehaviorModule:_OnConfigReload(newConfig, oldConfig)
    print("[EnemyX Behavior] Configuration reloaded")

    -- Update behavior configurations if changed
    if newConfig.Behaviors then
        -- In a full implementation, we'd update behavior templates
        -- For now, we just note that config changed
    end
end

-- Public API functions

-- Get all active behaviors
function BehaviorModule:GetAllBehaviors()
    return Utils.DeepCopy(self.activeBehaviors)
end

-- Get behavior count
function BehaviorModule:GetBehaviorCount()
    local count = 0
    for _, _ in pairs(self.activeBehaviors) do
        count = count + 1
    end
    return count
end

-- Check if entity has a specific behavior type
function BehaviorModule:HasBehavior(entityId, behaviorType)
    local behavior = self.activeBehaviors[entityId]
    return behavior and behavior.type == behaviorType
end

return BehaviorModule