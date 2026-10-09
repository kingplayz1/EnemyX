return {
    Framework = "auto", -- Auto-detect framework (standalone, esx, qbcore, qbox, vrp, nd)
    Debug = false,

    Performance = {
        highDistance = 50.0,    -- High priority AI update distance
        mediumDistance = 150.0, -- Medium priority AI update distance
        lowDistance = 300.0,    -- Low priority AI update distance
        updateRates = {
            high = 250,     -- ms
            medium = 1000,  -- ms
            low = 3000      -- ms
        }
    },

    AutoDirector = {
        enabled = true,
        scanInterval = 5000, -- ms
        maxActiveEnemies = 30,
        encounterWeights = {
            patrol = 40,
            ambush = 20,
            convoy = 15,
            reinforcement = 10,
            sniper = 5
        }
    },

    -- Default values for missing configuration
    Defaults = {
        PED_MODEL = "a_m_m_business_01",
        HEALTH = 100,
        ARMOR = 0,
        ACCURACY = 50,
        WEAPON = "WEAPON_PISTOL",
        AMMO = 30,
        RELATIONSHIP = "neutral",
        BEHAVIOR = "passive"
    }
}