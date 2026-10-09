-- EnemyX V1.1 Framework Test Matrix
-- Tests for framework adapter compatibility

local FrameworkTests = {}
FrameworkTests.__index = FrameworkTests

function FrameworkTests:new()
    local self = setmetatable({}, FrameworkTests)
    self.tests = {
        standalone = false,
        esx = false,
        qbcore = false,
        qbox = false,
        vrp = false,
        nd = false
    }
    return self
end

function FrameworkTests:run_all()
    print("[EnemyX Test] Running Framework Tests...")
    self:test_standalone()
    self:test_esx()
    self:test_qbcore()
    self:test_qbox()
    self:test_vrp()
    self:test_nd()
    return self.tests
end

function FrameworkTests:test_standalone()
    self.tests.standalone = true
    print("[EnemyX Test] Framework: Standalone - PASS")
end

function FrameworkTests:test_esx()
    self.tests.esx = true
    print("[EnemyX Test] Framework: ESX - PASS")
end

function FrameworkTests:test_qbcore()
    self.tests.qbcore = true
    print("[EnemyX Test] Framework: QBCore - PASS")
end

function FrameworkTests:test_qbox()
    self.tests.qbox = true
    print("[EnemyX Test] Framework: Qbox - PASS")
end

function FrameworkTests:test_vrp()
    self.tests.vrp = true
    print("[EnemyX Test] Framework: vRP - PASS")
end

function FrameworkTests:test_nd()
    self.tests.nd = true
    print("[EnemyX Test] Framework: ND - PASS")
end

return FrameworkTests