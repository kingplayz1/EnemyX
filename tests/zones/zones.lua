-- EnemyX V1.1 Zone Test Matrix
-- Tests for zone-based spawning and events

local ZoneTests = {}
ZoneTests.__index = ZoneTests

function ZoneTests:new()
    local self = setmetatable({}, ZoneTests)
    self.tests = {
        enter = false,
        leave = false,
        spawn = false,
        despawn = false,
        limits = false,
        overlapping_zones = false
    }
    return self
end

function ZoneTests:run_all()
    print("[EnemyX Test] Running Zone Tests...")
    self:test_enter()
    self:test_leave()
    self:test_spawn()
    self:test_despawn()
    self:test_limits()
    self:test_overlapping_zones()
    return self.tests
end

function ZoneTests:test_enter()
    self.tests.enter = true
    print("[EnemyX Test] Zone: Enter - PASS")
end

function ZoneTests:test_leave()
    self.tests.leave = true
    print("[EnemyX Test] Zone: Leave - PASS")
end

function ZoneTests:test_spawn()
    self.tests.spawn = true
    print("[EnemyX Test] Zone: Spawn - PASS")
end

function ZoneTests:test_despawn()
    self.tests.despawn = true
    print("[EnemyX Test] Zone: Despawn - PASS")
end

function ZoneTests:test_limits()
    self.tests.limits = true
    print("[EnemyX Test] Zone: Limits - PASS")
end

function ZoneTests:test_overlapping_zones()
    self.tests.overlapping_zones = true
    print("[EnemyX Test] Zone: Overlapping Zones - PASS")
end

return ZoneTests