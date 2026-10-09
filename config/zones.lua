return {
    -- Example zone definitions
    -- These define areas where enemies can spawn

    -- Drug lab area
    drug_lab = {
        type = "circle",
        center = {x = 1050.0, y = -3190.0, z = -39.0},  -- Example coordinates
        radius = 100.0,
        spawn = {
            enabled = true,
            radius = 100.0,
            minDistance = 30.0,
            maxDistance = 100.0,
            maxNPCs = 8,
            maxVehicles = 2,
            density = 0.7,
            interval = 8000
        },
        populations = {
            day = {enemyType = "gangster", count = 4},
            night = {enemyType = "cartel", count = 6},
            alert = {enemyType = "military", count = 10}
        }
    },

    -- Military base perimeter
    military_base = {
        type = "box",
        center = {x = 2100.0, y = 4800.0, z = 40.0},
        sizeX = 400.0,
        sizeY = 300.0,
        heading = 45.0,
        spawn = {
            enabled = true,
            radius = 150.0,
            minDistance = 50.0,
            maxDistance = 200.0,
            maxNPCs = 12,
            maxVehicles = 4,
            density = 0.5,
            interval = 10000
        },
        populations = {
            default = {enemyType = "military", count = 8}
        }
    },

    -- Gang territory
    gang_territory = {
        type = "polygon",
        points = {
            {x = 500.0, y = -1800.0, z = 20.0},
            {x = 800.0, y = -1700.0, z = 20.0},
            {x = 900.0, y = -2000.0, z = 20.0},
            {x = 600.0, y = -2100.0, z = 20.0}
        },
        spawn = {
            enabled = true,
            radius = 80.0,
            minDistance = 25.0,
            maxDistance = 80.0,
            maxNPCs = 6,
            maxVehicles = 1,
            density = 0.6,
            interval = 6000
        },
        populations = {
            default = {enemyType = "gangster", count = 4}
        }
    },

    -- Police station (for hostile police scenarios)
    police_station = {
        type = "circle",
        center = {x = 425.0, y = -979.0, z = 30.0},
        radius = 75.0,
        spawn = {
            enabled = true,
            radius = 75.0,
            minDistance = 20.0,
            maxDistance = 75.0,
            maxNPCs = 4,
            maxVehicles = 1,
            density = 0.4,
            interval = 12000
        },
        populations = {
            default = {enemyType = "police_enemy", count = 3}
        }
    }
}