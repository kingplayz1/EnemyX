-- EnemyX NPC Module
-- Handles NPC spawning, weapons, health, armor, and basic properties

local EnemyX = require 'shared/constants'
local Utils = require 'shared/utils'
local EventSystem = require 'core.events'

local NPCModule = {}
NPCModule.__index = NPCModule

-- Create a new NPC module instance
function NPCModule:new(dependencies)
    local self = setmetatable({}, NPCModule)
    self.eventSystem = dependencies.eventSystem
    self.configLoader = dependencies.configLoader
    self.entityManager = dependencies.entityManager
    self.constants = dependencies.constants
    self.utils = dependencies.utils
    self.initialized = false

    return self
end

-- Initialize the NPC module
function NPCModule:Initialize()
    if self.initialized then return end

    print("[EnemyX NPC] Initializing...")

    -- Set up event listeners
    self:_SetupEventListeners()

    self.initialized = true
    print("[EnemyX NPC] Initialized")
end

-- Start the module
function NPCModule:Start()
    -- Nothing to start for NPC module - it's event-driven
    print("[EnemyX NPC] Started")
end

-- Stop the module
function NPCModule:Stop()
    -- Clean up event listeners if needed
    print("[EnemyX NPC] Stopped")
end

-- Cleanup the module
function NPCModule:Cleanup()
    print("[EnemyX NPC] Cleaned up")
end

-- Set up event listeners
function NPCModule:_SetupEventListeners()
    -- Listen for enemy spawn requests
    self.eventSystem:on(EnemyX.Events.ENEMY_SPAWNED, function(data)
        self:_HandleEnemySpawn(data)
    end)

    -- Listen for enemy updates (AI processing)
    self.eventSystem:on(EnemyX.Events.ENEMY_UPDATED, function(data)
        self:_HandleEnemyUpdate(data)
    end)

    -- Listen for config reloads
    self.eventSystem:on(EnemyX.Events.CONFIG_RELOADED, function(newConfig, oldConfig)
        self:_OnConfigReload(newConfig, oldConfig)
    end)
end

-- Handle enemy spawn event
function NPCModule:_HandleEnemySpawn(data)
    -- data should contain: entityId, model, weapon, ammo, behavior, enemyType, etc.
    local entityId = data.entityId
    local entityData = self.entityManager:GetEntityData(entityId)

    if not entityData or not entityData.isActive then return end

    local entityHandle = entityData.properties.handle
    if not entityHandle or entityHandle == 0 then return end

    -- Apply weapon loadout
    self:_ApplyWeaponLoadout(entityHandle, data.weapon, data.ammo, data.secondaryWeapon, data.secondaryAmmo)

    -- Apply health and armor
    self:_ApplyHealthAndArmor(entityHandle, data.health, data.armor)

    -- Apply accuracy
    self:_ApplyAccuracy(entityHandle, data.accuracy)

    -- Apply relationship
    self:_ApplyRelationship(entityHandle, data.relationship)

    -- Apply combat flags
    self:_ApplyCombatFlags(entityHandle, data.combat)

    -- Apply weapon behavior
    self:_ApplyWeaponBehavior(entityHandle, data.weaponBehavior)

    -- Store NPC-specific data
    entityData.properties.npcData = {
        enemyType = data.enemyType or "unknown",
        behavior = data.behavior or EnemyX.BehaviorType.PASSIVE,
        primaryWeapon = data.weapon or EnemyX.Defaults.WEAPON,
        primaryAmmo = data.ammo or EnemyX.Defaults.AMMO,
        secondaryWeapon = data.secondaryWeapon,
        secondaryAmmo = data.secondaryAmmo,
        health = data.health or EnemyX.Defaults.HEALTH,
        maxHealth = GetEntityMaxHealth(entityHandle),
        armor = data.armor or EnemyX.Defaults.ARMOR,
        accuracy = data.accuracy or EnemyX.Defaults.ACCURACY,
        relationship = data.relationship or EnemyX.Relationship.NEUTRAL,
        combatFlags = data.combat or 0,
        weaponBehavior = data.weaponBehavior or 0,
        spawnedAt = GetGameTimer()
    }
end

-- Apply weapon loadout to ped
function NPCModule:_ApplyWeaponLoadout(ped, primaryWeapon, primaryAmmo, secondaryWeapon, secondaryAmmo)
    if not ped or ped == 0 then return end

    -- Remove any existing weapons
    RemoveAllPedWeapons(ped, true)

    -- Give primary weapon
    if primaryWeapon and primaryWeapon ~= "" then
        local weaponHash = GetHashKey(primaryWeapon)
        GiveWeaponToPed(ped, weaponHash, primaryAmmo or 0, false, true)
        SetPedAmmo(ped, weaponHash, primaryAmmo or 0)
    end

    -- Give secondary weapon if specified
    if secondaryWeapon and secondaryWeapon ~= "" then
        local weaponHash = GetHashKey(secondaryWeapon)
        GiveWeaponToPed(ped, weaponHash, secondaryAmmo or 0, false, true)
        SetPedAmmo(ped, weaponHash, secondaryAmmo or 0)
    end

    -- Set weapon as current if we have weapons
    if primaryWeapon and primaryWeapon ~= "" then
        SetCurrentPedWeapon(ped, GetHashKey(primaryWeapon), true)
    end
end

-- Apply health and armor
function NPCModule:_ApplyHealthAndArmor(ped, health, armor)
    if not ped or ped == 0 then return end

    -- Set health
    if health then
        SetEntityHealth(ped, health)
        SetEntityMaxHealth(ped, health)  -- Increase max health to match
    end

    -- Set armor
    if armor then
        SetPedArmour(ped, armor)
    end
end

-- Apply accuracy (0-100 scale)
function NPCModule:_ApplyAccuracy(ped, accuracy)
    if not ped or ped == 0 then return end

    -- Convert 0-100 to 0.0-1.0 for SetPedAccuracy
    local accuracyNormalized = math.clamp(accuracy or 50, 0, 100) / 100.0
    SetPedAccuracy(ped, accuracyNormalized)
end

-- Apply relationship (affects how NPC interacts with player and other factions)
function NPCModule:_ApplyRelationship(ped, relationship)
    if not ped or ped == 0 then return end

    -- Set ped as enemy/neutral/friendly based on relationship
    local isEnemy = (relationship == EnemyX.Relationship.HOSTILE or
                     relationship == EnemyX.Relationship.FEAR)

    SetPedAsEnemy(ped, isEnemy)
    SetPedCanBeTargetted(ped, true)
    SetPedCanRagdollFromPlayerImpact(ped, isEnemy)
    SetPedIsDrunk(ped, false)  -- Not drunk by default

    -- Store relationship for behavior system to use
    local pedData = self.entityManager:GetEntityData(
        self.entityManager:GetEntityHandleFromPed(ped) or 0
    )
    if pedData then
        pedData.properties.relationship = relationship
    end
end

-- Apply combat flags (bitmask)
function NPCModule:_ApplyCombatFlags(ped, combatFlags)
    if not ped or ped == 0 then return end

    combatFlags = combatFlags or 0

    -- Aggressive combat behavior
    if bit.band(combatFlags, EnemyX.CombatFlags.AGGRESSIVE) ~= 0 then
        SetPedFleeAttributes(ped, 0, false)  -- Don't flee easily
        SetPedCombatAttributes(ped, 46, true)  -- Can fight armed peds
        SetPedCombatAttributes(ped, 5, true)   -- Allow combat in vehicles
    else
        SetPedFleeAttributes(ped, 0, true)     -- Flee when threatened
        SetPedCombatAttributes(ped, 46, false) -- Avoid armed combat
    end

    -- Use cover
    if bit.band(combatFlags, EnemyX.CombatFlags.COVER) ~= 0 then
        SetPedSeekCoverFromPed(ped, true)
        SetPedSeekCoverFromPoint(ped, true)
    else
        SetPedSeekCoverFromPed(ped, false)
        SetPedSeekCoverFromPoint(ped, false)
    end

    -- Flee when injured
    if bit.band(combatFlags, EnemyX.CombatFlags.FLEE) ~= 0 then
        SetPedFleeAttributes(ped, 0, true)  -- Flee when injured
        SetPedCombatMovement(ped, 2)        -- Tactical movement
    else
        SetPedFleeAttributes(ped, 0, false) -- Stand ground when injured
    end

    -- Chase targets
    if bit.band(combatFlags, EnemyX.CombatFlags.CHASE) ~= 0 then
        SetPedCombatAttributes(ped, 16, true)  -- Chase target
        SetPedCombatAttributes(ped, 17, true)  -- Chase in vehicles
    else
        SetPedCombatAttributes(ped, 16, false) -- Don't chase
        SetPedCombatAttributes(ped, 17, false)
    end
end

-- Apply weapon behavior flags
function NPCModule:_ApplyWeaponBehavior(ped, weaponBehaviorFlags)
    if not ped or ped == 0 then return end

    weaponBehaviorFlags = weaponBehaviorFlags or 0

    -- Draw weapon on spawn/alert
    if bit.band(weaponBehaviorFlags, EnemyX.WeaponBehavior.DRAW_WEAPON) ~= 0 then
        -- This will be handled by behavior module when alerted
        SetPedDropsWeaponsWhenDead(ped, false)
    end

    -- Keep weapon in hand
    if bit.band(weaponBehaviorFlags, EnemyX.WeaponBehavior.KEEP_WEAPON_IN_HAND) ~= 0 then
        SetPedDropsWeaponsWhenDead(ped, false)
        -- Will be maintained by behavior logic
    end

    -- Switch between primary/secondary
    if bit.band(weaponBehaviorFlags, EnemyX.WeaponBehavior.SWITCH_WEAPON) ~= 0 then
        -- Behavior module will handle switching based on range
    end

    -- Auto-reload
    if bit.band(weaponBehaviorFlags, EnemyX.WeaponBehavior.RELOAD) ~= 0 then
        -- Native reload behavior is usually sufficient
    end
end

-- Handle enemy update (called periodically based on distance)
function NPCModule:_HandleEnemyUpdate(data)
    local entityId = data.entityId
    local entityData = self.entityManager:GetEntityData(entityId)

    if not entityData or not entityData.isActive then return end

    local ped = entityData.properties.handle
    if not ped or ped == 0 then return end

    -- Update NPC state based on current conditions
    self:_UpdateNPCState(ped, entityData)
end

-- Update NPC state based on current conditions
function NPCModule:_UpdateNPCState(ped, entityData)
    if not ped or ped == 0 then return end

    local npcData = entityData.properties.npcData
    if not npcData then return end

    -- Update health/armor display (for debugging)
    -- In a full implementation, this might update visual indicators

    -- Check if ped is dead
    if IsEntityDead(ped) then
        -- Let the entity manager handle cleanup
        return
    end

    -- Reset weapon if needed (based on weaponBehavior)
    if npcData.weaponBehavior then
        if bit.band(npcData.weaponBehavior, EnemyX.WeaponBehavior.RELOAD) ~= 0 then
            local _, weaponslot = GetCurrentPedWeapon(ped, true)
            local weaponHash = select(1, GetCurrentPedWeapon(ped, true))
            local ammoInClip = GetAmmoInPedWeapon(ped, weaponHash)
            local maxClip = GetMaxAmmoInClip(ped, weaponHash, true)

            -- Auto-reload if clip is less than 25% full
            if ammoInClip < maxClip * 0.25 then
                ReloadPedWeapon(ped)
            end
        end
    end
end

-- Handle configuration reload
function NPCModule:_OnConfigReload(newConfig, oldConfig)
    -- Reload any NPC-specific configuration
    print("[EnemyX NPC] Configuration reloaded")

    -- Update defaults if changed
    if newConfig.Defaults then
        EnemyX.Defaults = Utils.MergeTables(EnemyX.Defaults, newConfig.Defaults)
    end

    -- Update behavior configurations if changed
    if newConfig.Behaviors then
        -- Behavior module will handle this, but we could cache some values here
    end
end

-- Get NPC data by entity ID
function NPCModule:GetNPCData(entityId)
    local entityData = self.entityManager:GetEntityData(entityId)
    if entityData and entityData.isActive then
        return entityData.properties.npcData
    end
    return nil
end

-- Update NPC weapon loadout
function NPCModule:UpdateWeaponLoadout(entityId, primaryWeapon, primaryAmmo, secondaryWeapon, secondaryAmmo)
    local entityData = self.entityManager:GetEntityData(entityId)
    if not entityData or not entityData.isActive then return false end

    local ped = entityData.properties.handle
    if not ped or ped == 0 then return false end

    self:_ApplyWeaponLoadout(ped, primaryWeapon, primaryAmmo, secondaryWeapon, secondaryAmmo)

    -- Update stored data
    if entityData.properties.npcData then
        entityData.properties.npcData.primaryWeapon = primaryWeapon
        entityData.properties.npcData.primaryAmmo = primaryAmmo
        entityData.properties.npcData.secondaryWeapon = secondaryWeapon
        entityData.properties.npcData.secondaryAmmo = secondaryAmmo
    end

    return true
end

-- Update NPC health and armor
function NPCModule:UpdateHealthArmor(entityId, health, armor)
    local entityData = self.entityManager:GetEntityData(entityId)
    if not entityData or not entityData.isActive then return false end

    local ped = entityData.properties.handle
    if not ped or ped == 0 then return false end

    self:_ApplyHealthAndArmor(ped, health, armor)

    -- Update stored data
    if entityData.properties.npcData then
        entityData.properties.npcData.health = health or entityData.properties.npcData.health
        entityData.properties.npcData.armor = armor or entityData.properties.npcData.armor
    end

    return true
end

return NPCModule