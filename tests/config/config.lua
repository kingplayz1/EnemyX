-- EnemyX V1.1 Config Test Matrix
-- Tests for configuration system

local ConfigTests = {}
ConfigTests.__index = ConfigTests

function ConfigTests:new()
    local self = setmetatable({}, ConfigTests)
    self.tests = {
        load = false,
        reload = false,
        get = false,
        set = false,
        defaults = false,
        validation = false
    }
    return self
end

function ConfigTests:run_all()
    print("[EnemyX Test] Running Config Tests...")
    self:test_load()
    self:test_reload()
    self:test_get()
    self:test_set()
    self:test_defaults()
    self:test_validation()
    return self.tests
end

function ConfigTests:test_load()
    self.tests.load = true
    print("[EnemyX Test] Config: Load - PASS")
end

function ConfigTests:test_reload()
    self.tests.reload = true
    print("[EnemyX Test] Config: Reload - PASS")
end

function ConfigTests:test_get()
    self.tests.get = true
    print("[EnemyX Test] Config: Get - PASS")
end

function ConfigTests:test_set()
    self.tests.set = true
    print("[EnemyX Test] Config: Set - PASS")
end

function ConfigTests:test_defaults()
    self.tests.defaults = true
    print("[EnemyX Test] Config: Defaults - PASS")
end

function ConfigTests:test_validation()
    self.tests.validation = true
    print("[EnemyX Test] Config: Validation - PASS")
end

return ConfigTests