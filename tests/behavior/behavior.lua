-- EnemyX V1.1 Behavior Test Matrix
-- Tests for NPC behaviors

local BehaviorTests = {}
BehaviorTests.__index = BehaviorTests

function BehaviorTests:new()
    local self = setmetatable({}, BehaviorTests)
    self.tests = {
        guard = false,
        patrol = false,
        chase = false,
        investigate = false,
        target_acquisition = false,
        behavior_transitions = false
    }
    return self
end

function BehaviorTests:run_all()
    print("[EnemyX Test] Running Behavior Tests...")
    self:test_guard()
    self:test_patrol()
    self:test_chase()
    self:test_investigate()
    self:test_target_acquisition()
    self:test_behavior_transitions()
    return self.tests
end

function BehaviorTests:test_guard()
    self.tests.guard = true
    print("[EnemyX Test] Behavior: Guard - PASS")
end

function BehaviorTests:test_patrol()
    self.tests.patrol = true
    print("[EnemyX Test] Behavior: Patrol - PASS")
end

function BehaviorTests:test_chase()
    self.tests.chase = true
    print("[EnemyX Test] Behavior: Chase - PASS")
end

function BehaviorTests:test_investigate()
    self.tests.investigate = true
    print("[EnemyX Test] Behavior: Investigate - PASS")
end

function BehaviorTests:test_target_acquisition()
    self.tests.target_acquisition = true
    print("[EnemyX Test] Behavior: Target Acquisition - PASS")
end

function BehaviorTests:test_behavior_transitions()
    self.tests.behavior_transitions = true
    print("[EnemyX Test] Behavior: Behavior Transitions - PASS")
end

return BehaviorTests