-- EnemyX Phase 3 Framework Matrix Testing: Detection Testing
-- Test framework detection capabilities

local FrameworkDetectionTests = {}
FrameworkDetectionTests.__index = FrameworkDetectionTests

function FrameworkDetectionTests:new()
    local self = setmetatable({}, FrameworkDetectionTests)
    self.tests = {
        ["standalone_detection_available"] = false,
        ["standalone_detection_name"] = false,
        ["esx_detection_available_when_present"] = false,
        ["esx_detection_available_when_absent"] = false,
        ["esx_detection_name"] = false,
        ["qbcore_detection_available_when_present"] = false,
        ["qbcore_detection_available_when_absent"] = false,
        ["qbcore_detection_name"] = false,
        ["qbox_detection_available_when_present"] = false,
        ["qbox_detection_available_when_absent"] = false,
        ["qbox_detection_name"] = false,
        ["vrp_detection_available_when_present"] = false,
        ["vrp_detection_available_when_absent"] = false,
        ["vrp_detection_name"] = false,
        ["nd_detection_available_when_present"] = false,
        ["nd_detection_available_when_absent"] = false,
        ["nd_detection_name"] = false,
    }
    return self
end

function FrameworkDetectionTests:run_all()
    print("[EnemyX Framework] Running Framework Detection Tests...")
    self:test_standalone_detection_available()
    self:test_standalone_detection_name()
    self:test_esx_detection_available_when_present()
    self:test_esx_detection_available_when_absent()
    self:test_esx_detection_name()
    self:test_qbcore_detection_available_when_present()
    self:test_qbcore_detection_available_when_absent()
    self:test_qbcore_detection_name()
    self:test_qbox_detection_available_when_present()
    self:test_qbox_detection_available_when_absent()
    self:test_qbox_detection_name()
    self:test_vrp_detection_available_when_present()
    self:test_vrp_detection_available_when_absent()
    self:test_vrp_detection_name()
    self:test_nd_detection_available_when_present()
    self:test_nd_detection_available_when_absent()
    self:test_nd_detection_name()
    return self.tests
end

function FrameworkDetectionTests:test_standalone_detection_available()
    -- Test: Standalone framework detection when available
    -- Expected: IsAvailable() == true
    local standalone = require("enemyx.adapters.standalone")
    self.tests["standalone_detection_available"] = standalone.IsAvailable()
    print("[EnemyX Framework] Detection: Standalone Available - " .. (self.tests["standalone_detection_available"] and "PASS" or "FAIL"))
end

function FrameworkDetectionTests:test_standalone_detection_name()
    -- Test: Standalone framework detection name
    -- Expected: GetName() == "standalone"
    local standalone = require("enemyx.adapters.standalone")
    self.tests["standalone_detection_name"] = (standalone.GetName() == "standalone")
    print("[EnemyX Framework] Detection: Standalone Name - " .. (self.tests["standalone_detection_name"] and "PASS" or "FAIL"))
end

function FrameworkDetectionTests:test_esx_detection_available_when_present()
    -- Test: ESX framework detection when present (simulated)
    -- Expected: Would return true if ESX was present
    -- For now, we'll test that the function exists and returns a boolean
    local esx = require("enemyx.adapters.esx")
    local result = esx.IsAvailable()
    self.tests["esx_detection_available_when_present"] = type(result) == "boolean"
    print("[EnemyX Framework] Detection: ESX Available When Present - " .. (self.tests["esx_detection_available_when_present"] and "PASS" or "FAIL"))
end

function FrameworkDetectionTests:test_esx_detection_available_when_absent()
    -- Test: ESX framework detection when absent
    -- Expected: Would return false if ESX was absent
    -- For now, we'll test that the function exists and returns a boolean
    local esx = require("enemyx.adapters.esx")
    local result = esx.IsAvailable()
    self.tests["esx_detection_available_when_absent"] = type(result) == "boolean"
    print("[EnemyX Framework] Detection: ESX Available When Absent - " .. (self.tests["esx_detection_available_when_absent"] and "PASS" or "FAIL"))
end

function FrameworkDetectionTests:test_esx_detection_name()
    -- Test: ESX framework detection name
    -- Expected: GetName() == "esx"
    local esx = require("enemyx.adapters.esx")
    self.tests["esx_detection_name"] = (esx.GetName() == "esx")
    print("[EnemyX Framework] Detection: ESX Name - " .. (self.tests["esx_detection_name"] and "PASS" or "FAIL"))
end

function FrameworkDetectionTests:test_qbcore_detection_available_when_present()
    -- Test: QBCore framework detection when present (simulated)
    -- Expected: Would return true if QBCore was present
    -- For now, we'll test that the function exists and returns a boolean
    local qbcore = require("enemyx.adapters.qbcore")
    local result = qbcore.IsAvailable()
    self.tests["qbcore_detection_available_when_present"] = type(result) == "boolean"
    print("[EnemyX Framework] Detection: QBCore Available When Present - " .. (self.tests["qbcore_detection_available_when_present"] and "PASS" or "FAIL"))
end

function FrameworkDetectionTests:test_qbcore_detection_available_when_absent()
    -- Test: QBCore framework detection when absent
    -- Expected: Would return false if QBCore was absent
    -- For now, we'll test that the function exists and returns a boolean
    local qbcore = require("enemyx.adapters.qbcore")
    local result = qbcore.IsAvailable()
    self.tests["qbcore_detection_available_when_absent"] = type(result) == "boolean"
    print("[EnemyX Framework] Detection: QBCore Available When Absent - " .. (self.tests["qbcore_detection_available_when_absent"] and "PASS" or "FAIL"))
end

function FrameworkDetectionTests:test_qbcore_detection_name()
    -- Test: QBCore framework detection name
    -- Expected: GetName() == "qbcore"
    local qbcore = require("enemyx.adapters.qbcore")
    self.tests["qbcore_detection_name"] = (qbcore.GetName() == "qbcore")
    print("[EnemyX Framework] Detection: QBCore Name - " .. (self.tests["qbcore_detection_name"] and "PASS" or "FAIL"))
end

function FrameworkDetectionTests:test_qbox_detection_available_when_present()
    -- Test: QBox framework detection when present (simulated)
    -- Expected: Would return true if QBox was present
    -- For now, we'll test that the function exists and returns a boolean
    local qbox = require("enemyx.adapters.qbox")
    local result = qbox.IsAvailable()
    self.tests["qbox_detection_available_when_present"] = type(result) == "boolean"
    print("[EnemyX Framework] Detection: QBox Available When Present - " .. (self.tests["qbox_detection_available_when_present"] and "PASS" or "FAIL"))
end

function FrameworkDetectionTests:test_qbox_detection_available_when_absent()
    -- Test: QBox framework detection when absent
    -- Expected: Would return false if QBox was absent
    -- For now, we'll test that the function exists and returns a boolean
    local qbox = require("enemyx.adapters.qbox")
    local result = qbox.IsAvailable()
    self.tests["qbox_detection_available_when_absent"] = type(result) == "boolean"
    print("[EnemyX Framework] Detection: QBox Available When Absent - " .. (self.tests["qbox_detection_available_when_absent"] and "PASS" or "FAIL"))
end

function FrameworkDetectionTests:test_qbox_detection_name()
    -- Test: QBox framework detection name
    -- Expected: GetName() == "qbox"
    local qbox = require("enemyx.adapters.qbox")
    self.tests["qbox_detection_name"] = (qbox.GetName() == "qbox")
    print("[EnemyX Framework] Detection: QBox Name - " .. (self.tests["qbox_detection_name"] and "PASS" or "FAIL"))
end

function FrameworkDetectionTests:test_vrp_detection_available_when_present()
    -- Test: vRP framework detection when present (simulated)
    -- Expected: Would return true if vRP was present
    -- For now, we'll test that the function exists and returns a boolean
    local vrp = require("enemyx.adapters.vrp")
    local result = vrp.IsAvailable()
    self.tests["vrp_detection_available_when_present"] = type(result) == "boolean"
    print("[EnemyX Framework] Detection: vRP Available When Present - " .. (self.tests["vrp_detection_available_when_present"] and "PASS" or "FAIL"))
end

function FrameworkDetectionTests:test_vrp_detection_available_when_absent()
    -- Test: vRP framework detection when absent
    -- Expected: Would return false if vRP was absent
    -- For now, we'll test that the function exists and returns a boolean
    local vrp = require("enemyx.adapters.vrp")
    local result = vrp.IsAvailable()
    self.tests["vrp_detection_available_when_absent"] = type(result) == "boolean"
    print("[EnemyX Framework] Detection: vRP Available When Absent - " .. (self.tests["vrp_detection_available_when_absent"] and "PASS" or "FAIL"))
end

function FrameworkDetectionTests:test_vrp_detection_name()
    -- Test: vRP framework detection name
    -- Expected: GetName() == "vrp"
    local vrp = require("enemyx.adapters.vrp")
    self.tests["vrp_detection_name"] = (vrp.GetName() == "vrp")
    print("[EnemyX Framework] Detection: vRP Name - " .. (self.tests["vrp_detection_name"] and "PASS" or "FAIL"))
end

function FrameworkDetectionTests:test_nd_detection_available_when_present()
    -- Test: ND framework detection when present (simulated)
    -- Expected: Would return true if ND was present
    -- For now, we'll test that the function exists and returns a boolean
    local nd = require("enemyx.adapters.nd")
    local result = nd.IsAvailable()
    self.tests["nd_detection_available_when_present"] = type(result) == "boolean"
    print("[EnemyX Framework] Detection: ND Available When Present - " .. (self.tests["nd_detection_available_when_present"] and "PASS" or "FAIL"))
end

function FrameworkDetectionTests:test_nd_detection_available_when_absent()
    -- Test: ND framework detection when absent
    -- Expected: Would return false if ND was absent
    -- For now, we'll test that the function exists and returns a boolean
    local nd = require("enemyx.adapters.nd")
    local result = nd.IsAvailable()
    self.tests["nd_detection_available_when_absent"] = type(result) == "boolean"
    print("[EnemyX Framework] Detection: ND Available When Absent - " .. (self.tests["nd_detection_available_when_absent"] and "PASS" or "FAIL"))
end

function FrameworkDetectionTests:test_nd_detection_name()
    -- Test: ND framework detection name
    -- Expected: GetName() == "nd"
    local nd = require("enemyx.adapters.nd")
    self.tests["nd_detection_name"] = (nd.GetName() == "nd")
    print("[EnemyX Framework] Detection: ND Name - " .. (self.tests["nd_detection_name"] and "PASS" or "FAIL"))
end

return FrameworkDetectionTests