return {
    -- Encounter type definitions for V2 (stub for V1)
    -- These define different types of encounters the AI Director can spawn

    patrol = {
        label = "Patrol",
        description = "Enemies patrol a set path or area",
        weight = 40,
        minEnemies = 2,
        maxEnemies = 6,
        behavior = "patrol"
    },

    ambush = {
        label = "Ambush",
        description = "Enemies lie in wait to surprise players",
        weight = 20,
        minEnemies = 4,
        maxEnemies = 8,
        behavior = "aggressive",
        setupTime = 2000 -- ms to set up ambush
    },

    convoy = {
        label = "Convoy",
        description = "Group of vehicles with enemy passengers and escorts",
        weight = 15,
        minEnemies = 3,
        maxEnemies = 8,
        minVehicles = 2,
        maxVehicles = 4,
        behavior = "aggressive"
    },

    reinforcement = {
        label = "Reinforcement",
        description = "Additional enemies arrive when players engage existing enemies",
        weight = 10,
        minEnemies = 4,
        maxEnemies = 10,
        behavior = "aggressive",
        triggeredBy = "combat"
    },

    sniper = {
        label = "Sniper",
        description = "Long-range enemy with high accuracy",
        weight = 5,
        minEnemies = 1,
        maxEnemies = 2,
        behavior = "sniper",
        preferredDistance = {min = 30.0, max = 50.0}
    }
}