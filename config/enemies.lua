return {
    -- Generic civilian (neutral by default)
    civilian = {
        label = "Civilian",
        peds = {"a_m_m_business_01", "a_m_y_business_02", "a_f_y_business_02", "a_m_y_genstreet_01", "a_f_y_genstreet_01"},
        weapons = {
            primary = {weapon = "WEAPON_UNARMED", ammo = 0}
        },
        armor = 0,
        health = 100,
        accuracy = 30,
        relationship = "neutral",
        combat = {aggressive = false, cover = true, flee = true, chase = false},
        behavior = "passive"
    },

    -- Basic hostile enemy
    gangster = {
        label = "Gangster",
        peds = {"g_m_y_armgoon_01", "g_m_y_armgoon_02", "g_m_y_armgoon_03", "g_m_y_salvagoon_01", "g_m_y_salvagoon_02", "g_m_y_salvagoon_03"},
        weapons = {
            primary = {weapon = "WEAPON_PISTOL", ammo = 150},
            secondary = {weapon = "WEAPON_KNIFE", ammo = 1}
        },
        armor = 25,
        health = 150,
        accuracy = 45,
        relationship = "hostile",
        combat = {aggressive = true, cover = true, flee = false, chase = true},
        behavior = "aggressive"
    },

    -- Cartel/Mafia enemy (more advanced)
    cartel = {
        label = "Cartel",
        peds = {"g_m_y_mexgoon_01", "g_m_y_mexgoon_02", "g_m_y_mexgoon_03", "g_m_y_mexagoon_01", "g_m_y_mexagoon_02", "g_m_y_mexagoon_03"},
        weapons = {
            primary = {weapon = "WEAPON_ASSAULTRIFLE", ammo = 250},
            secondary = {weapon = "WEAPON_PISTOL", ammo = 100}
        },
        armor = 100,
        health = 250,
        accuracy = 55,
        relationship = "hostile",
        combat = {aggressive = true, cover = true, flee = false, chase = true},
        weaponBehavior = {
            drawWeapon = true,
            keepWeaponInHand = true,
            switchWeapon = true,
            reload = true
        },
        behavior = "aggressive"
    },

    -- Military enemy (tough and accurate)
    military = {
        label = "Military",
        peds = {"s_m_y_marine_01", "s_m_y_marine_02", "s_m_y_armymech_01", "s_m_y_armymech_02", "s_m_y_blackops_01", "s_m_y_blackops_02", "s_m_y_blackops_03"},
        weapons = {
            primary = {weapon = "WEAPON_CARBINERIFLE", ammo = 180},
            secondary = {weapon = "WEAPON_PUMPSHOTGUN", ammo = 32}
        },
        armor = 200,
        health = 350,
        accuracy = 80,
        relationship = "neutral", -- Military neutral by default, can be made hostile
        combat = {aggressive = false, cover = true, flee = false, chase = true},
        weaponBehavior = {
            drawWeapon = true,
            keepWeaponInHand = true,
            switchWeapon = false,
            reload = true
        },
        behavior = "guard"
    },

    -- Police enemy (for scenarios where police are hostile)
    police_enemy = {
        label = "Police Enemy",
        peds = {"s_m_y_cop_01", "s_m_y_cop_02", "s_m_y_ranger_01", "s_m_y_ranger_02", "s_m_y_sheriff_01", "s_m_y_sheriff_02"},
        weapons = {
            primary = {weapon = "WEAPON_PUMPSHOTGUN", ammo = 64},
            secondary = {weapon = "WEAPON_CARBINERIFLE", ammo = 90}
        },
        armor = 150,
        health = 200,
        accuracy = 60,
        relationship = "hostile",
        combat = {aggressive = true, cover = true, flee = false, chase = true},
        weaponBehavior = {
            drawWeapon = true,
            keepWeaponInHand = true,
            switchWeapon = true,
            reload = true
        },
        behavior = "aggressive"
    },

    -- Biker gang enemy
    biker = {
        label = "Biker",
        peds = {"g_m_y_lost_01", "g_m_y_lost_02", "g_m_y_lost_03", "g_m_y_mexagoon_01", "g_m_y_mexagoon_02"},
        weapons = {
            primary = {weapon = "WEAPON_MICROSMG", ammo = 200},
            secondary = {weapon = "WEAPON_GUSENBERG", ammo = 150}
        },
        armor = 50,
        health = 180,
        accuracy = 50,
        relationship = "hostile",
        combat = {aggressive = true, cover = true, flee = false, chase = true},
        behavior = "aggressive"
    },

    -- Vagos gang enemy
    vagos = {
        label = "Vagos Gang",
        peds = {"g_m_y_vagos_01", "g_m_y_vagos_02", "g_m_y_armgoon_02"},
        weapons = {
            primary = {weapon = "WEAPON_ASSAULTSMG", ammo = 180},
            secondary = {weapon = "WEAPON_SNSPISTOL", ammo = 50}
        },
        armor = 75,
        health = 200,
        accuracy = 50,
        relationship = "hostile",
        combat = {aggressive = true, cover = true, flee = false, chase = true},
        behavior = "aggressive"
    },

    -- Lost MC gang enemy
    lost = {
        label = "Lost MC",
        peds = {"g_m_y_lost_01", "g_m_y_lost_02", "g_m_y_lost_03"},
        weapons = {
            primary = {weapon = "WEAPON_ASSAULTSMG", ammo = 200},
            secondary = {weapon = "WEAPON_GUSENBERG", ammo = 150}
        },
        armor = 60,
        health = 190,
        accuracy = 48,
        relationship = "hostile",
        combat = {aggressive = true, cover = true, flee = false, chase = true},
        behavior = "aggressive"
    },

    -- Zombie enemy (slow but tough)
    zombie = {
        label = "Zombie",
        peds = {"u_m_y_zombie_01", "u_m_y_zombie_02", "a_m_m_acult_01"},
        weapons = {
            primary = {weapon = "WEAPON_UNARMED", ammo = 0}
        },
        armor = 0,
        health = 300,
        accuracy = 20,
        relationship = "hostile",
        combat = {aggressive = true, cover = false, flee = false, chase = true},
        weaponBehavior = {
            drawWeapon = false,
            keepWeaponInHand = false,
            switchWeapon = false,
            reload = false
        },
        behavior = "aggressive" -- But slow movement speed handled elsewhere
    },

    -- Sniper enemy (long range, high accuracy)
    sniper = {
        label = "Sniper",
        peds = {"s_m_y_sniper_01", "s_m_y_blackops_01", "s_m_y_blackops_02", "s_m_y_blackops_03"},
        weapons = {
            primary = {weapon = "WEAPON_SNIPERRIFLE", ammo = 30},
            secondary = {weapon = "WEAPON_PISTOL", ammo = 20}
        },
        armor = 50,
        health = 120,
        accuracy = 90,
        relationship = "hostile",
        combat = {aggressive = true, cover = true, flee = false, chase = false},
        weaponBehavior = {
            drawWeapon = true,
            keepWeaponInHand = true,
            switchWeapon = true,
            reload = true
        },
        behavior = "sniper"
    }
}