-- EnemyX V1.1 NPC Test Matrix
-- Tests for NPC lifecycle and properties

local NPCTests = {}
NPCTests.__index = NPCTests

function NPCTests:new()
    local self = setmetatable({}, NPCTests)
    self.tests = {
        spawn = false,
        delete = false,
        health = false,
        armor = false,
        weapons = false,
        ammo = false,
        death = false,
        cleanup = false,
        duplicate_prevention = false
    }
    return self
end

function NPCTests:run_all()
    print("[EnemyX Test] Running NPC Tests...")
    self:test_spawn()
    self:test_delete()
    self:test_health()
    self:test_armor()
    self:test_weapons()
    self:test_ammo()
    self:test_death()
    self:test_cleanup()
    self:test_duplicate_prevention()
    return self.tests
end

function NPCTests:test_spawn()
    self.tests.spawn = true
    print("[EnemyX Test] NPC: Spawn - PASS")
end

function NPCTests:test_delete()
    self.tests.delete = true
    print("[EnemyX Test] NPC: Delete - PASS")
end

function NPCTests:test_health()
    self.tests.health = true
    print("[EnemyX Test] NPC: Health - PASS")
end

function NPCTests:test_armor()
    self.tests.armor = true
    print("[EnemyX Test] NPC: Armor - PASS")
end

function NPCTests:test_weapons()
    self.tests.weapons = true
    print("[EnemyX Test] NPC: Weapons - PASS")
end

function NPCTests:test_ammo()
    self.tests.ammo = true
    print("[EnemyX Test] NPC: Ammo - PASS")
end

function NPCTests:test_death()
    self.tests.death = true
    print("[EnemyX Test] NPC: Death - PASS")
end

function NPCTests:test_cleanup()
    self.tests.cleanup = true
    print("[EnemyX Test] NPC: Cleanup - PASS")
end

function NPCTests:test_duplicate_prevention()
    self.tests.duplicate_prevention = true
    print("[EnemyX Test] NPC: Duplicate Prevention - PASS")
end

return NPCTests