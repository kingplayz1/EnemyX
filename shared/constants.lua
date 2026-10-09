-- EnemyX Core Constants
-- Shared across all modules

EnemyX = {}

-- Version info
EnemyX.VERSION = "1.0.0"
EnemyX.NAME = "EnemyX"

-- Distance thresholds for AI updates (in GTA units/meters)
EnemyX.Performance = {
    HIGH_DISTANCE = 50.0,    -- High priority AI (250ms updates)
    MEDIUM_DISTANCE = 150.0, -- Medium priority AI (1000ms updates)
    LOW_DISTANCE = 300.0,    -- Low priority AI (3000ms updates)
    DORMANT_DISTANCE = 500.0 -- Entity remains, AI unloads
}

-- Update rates in milliseconds
EnemyX.UpdateRates = {
    HIGH = 250,
    MEDIUM = 1000,
    LOW = 3000
}

-- Enemy relationship types
EnemyX.Relationship = {
    HOSTILE = "hostile",
    FRIENDLY = "friendly",
    NEUTRAL = "neutral",
    FEAR = "fear"
}

-- Behavior types
EnemyX.BehaviorType = {
    PASSIVE = "passive",
    DEFENSIVE = "defensive",
    AGGRESSIVE = "aggressive",
    PATROL = "patrol",
    GUARD = "guard",
    CHASE = "chase",
    INVESTIGATE = "investigate",
    SNIPER = "sniper"
}

-- Combat flags
EnemyX.CombatFlags = {
    AGGRESSIVE = 1 << 0,  -- Aggressively pursue threats
    COVER = 1 << 1,       -- Use cover when available
    FLEE = 1 << 2,        -- Flee when health low
    CHASE = 1 << 3        -- Chase targets persistently
}

-- Weapon behavior flags
EnemyX.WeaponBehavior = {
    DRAW_WEAPON = 1 << 0,      -- Draw weapon on spawn/alert
    KEEP_WEAPON_IN_HAND = 1 << 1, -- Keep weapon equipped
    SWITCH_WEAPON = 1 << 2,    -- Switch between primary/secondary
    RELOAD = 1 << 3            -- Auto-reload when empty
}

-- Zone types
EnemyX.ZoneType = {
    CIRCLE = "circle",
    BOX = "box",
    POLYGON = "polygon",
    ENTITY = "entity"
}

-- Encounter types for AI Director
EnemyX.EncounterType = {
    PATROL = "patrol",
    AMBUSH = "ambush",
    CONVOY = "convoy",
    REINFORCEMENT = "reinforcement",
    SNIPER = "sniper"
}

-- Entity pooling configuration
EnemyX.Pooling = {
    MAX_PED_POOL = 50,
    MAX_VEHICLE_POOL = 20,
    PREWARM_COMMON_MODELS = {
        "a_m_m_business_01",
        "a_m_y_beach_01",
        "g_m_y_mexgoon_01",
        "s_m_y_cop_01"
    }
}

-- Default enemy configuration (used when config missing)
EnemyX.Defaults = {
    PED_MODEL = "a_m_m_business_01",
    HEALTH = 100,
    ARMOR = 0,
    ACCURACY = 50,
    WEAPON = "WEAPON_PISTOL",
    AMMO = 30,
    RELATIONSHIP = EnemyX.Relationship.NEUTRAL,
    BEHAVIOR = EnemyX.BehaviorType.PASSIVE
}

-- Event names (used for internal communication)
EnemyX.Events = {
    ENEMY_SPAWNED = "enemyx:enemySpawned",
    ENEMY_DIED = "enemyx:enemyDied",
    ENEMY_UPDATED = "enemyx:enemyUpdated",
    ZONE_ENTERED = "enemyx:zoneEntered",
    ZONE_EXITED = "enemyx:zoneExited",
    ENCOUNTER_STARTED = "enemyx:encounterStarted",
    ENCOUNTER_ENDED = "enemyx:encounterEnded",
    PLAYER_ENTERED_ZONE = "enemyx:playerEnteredZone",
    PLAYER_EXITED_ZONE = "enemyx:playerExitedZone",
    CONFIG_RELOADED = "enemyx:configReloaded",
    MODULE_LOADED = "enemyx:moduleLoaded",
    MODULE_UNLOADED = "enemyx:moduleUnloaded"
}

-- Network event prefixes
EnemyX.Network = {
    CLIENT = "enemyx:client:",
    SERVER = "enemyx:server:"
}

return EnemyX