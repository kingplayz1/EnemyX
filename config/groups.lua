return {
    -- Enemy group definitions for V2 (basic stub for V1)
    -- These will be used in V2 when group system is enhanced

    -- Basic gangster group
    gangster_patrol = {
        label = "Gangster Patrol",
        size = {min = 2, max = 4},
        enemyType = "gangster",
        behavior = "aggressive",
        weapons = {
            primary = {weapon = "WEAPON_PISTOL", ammo = 150},
            secondary = {weapon = "WEAPON_KNIFE", ammo = 1}
        }
    },

    -- Cartel group
    cartel_patrol = {
        label = "Cartel Patrol",
        size = {min = 3, max = 6},
        enemyType = "cartel",
        behavior = "aggressive",
        weapons = {
            primary = {weapon = "WEAPON_ASSAULTRIFLE", ammo = 250},
            secondary = {weapon = "WEAPON_PISTOL", ammo = 100}
        }
    },

    -- Military patrol
    military_patrol = {
        label = "Military Patrol",
        size = {min = 4, max = 8},
        enemyType = "military",
        behavior = "guard",
        weapons = {
            primary = {weapon = "WEAPON_CARBINERIFLE", ammo = 180},
            secondary = {weapon = "WEAPON_PUMPSHOTGUN", ammo = 32}
        }
    },

    -- Police enemy group (for hostile police scenarios)
    police_patrol = {
        label = "Police Patrol",
        size = {min = 2, max = 4},
        enemyType = "police_enemy",
        behavior = "aggressive",
        weapons = {
            primary = {weapon = "WEAPON_PUMPSHOTGUN", ammo = 64},
            secondary = {weapon = "WEAPON_CARBINERIFLE", ammo = 90}
        }
    },

    -- Biker gang group
    biker_gang = {
        label = "Biker Gang",
        size = {min = 3, max = 6},
        enemyType = "biker",
        behavior = "aggressive",
        weapons = {
            primary = {weapon = "WEAPON_MICROSMG", ammo = 200},
            secondary = {weapon = "WEAPON_GUSENBERG", ammo = 150}
        }
    }
}