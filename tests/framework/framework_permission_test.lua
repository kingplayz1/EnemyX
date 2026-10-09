-- EnemyX Phase 3 Framework Matrix Testing: Permission Testing
-- Test permission capabilities across frameworks

local FrameworkPermissionTests = {}
FrameworkPermissionTests.__index = FrameworkPermissionTests

function FrameworkPermissionTests:new()
    local self = setmetatable({}, FrameworkPermissionTests)
    self.tests = {
        ["standalone_has_permission_admin"] = false,
        ["standalone_has_permission_moderator"] = false,
        ["standalone_has_permission_normal"] = false,
        ["standalone_has_permission_unknown"] = false,
        ["standalone_has_permission_invalid_source"] = false,
        ["esx_has_permission_admin"] = false,
        ["esx_has_permission_moderator"] = false,
        ["esx_has_permission_normal"] = false,
        ["esx_has_permission_unknown"] = false,
        ["esx_has_permission_invalid_source"] = false,
        ["qbcore_has_permission_admin"] = false,
        ["qbcore_has_permission_moderator"] = false,
        ["qbcore_has_permission_normal"] = false,
        ["qbcore_has_permission_unknown"] = false,
        ["qbcore_has_permission_invalid_source"] = false,
        ["qbox_has_permission_admin"] = false,
        ["qbox_has_permission_moderator"] = false,
        ["qbox_has_permission_normal"] = false,
        ["qbox_has_permission_unknown"] = false,
        ["qbox_has_permission_invalid_source"] = false,
        ["vrp_has_permission_admin"] = false,
        ["vrp_has_permission_moderator"] = false,
        ["vrp_has_permission_normal"] = false,
        ["vrp_has_permission_unknown"] = false,
        ["vrp_has_permission_invalid_source"] = false,
        ["nd_has_permission_admin"] = false,
        ["nd_has_permission_moderator"] = false,
        ["nd_has_permission_normal"] = false,
        ["nd_has_permission_unknown"] = false,
        ["nd_has_permission_invalid_source"] = false,
    }
    return self
end

function FrameworkPermissionTests:run_all()
    print("[EnemyX Framework] Running Permission Tests...")
    self:test_standalone_has_permission_admin()
    self:test_standalone_has_permission_moderator()
    self:test_standalone_has_permission_normal()
    self:test_standalone_has_permission_unknown()
    self:test_standalone_has_permission_invalid_source()
    self:test_esx_has_permission_admin()
    self:test_esx_has_permission_moderator()
    self:test_esx_has_permission_normal()
    self:test_esx_has_permission_unknown()
    self:test_esx_has_permission_invalid_source()
    self:test_qbcore_has_permission_admin()
    self:test_qbcore_has_permission_moderator()
    self:test_qbcore_has_permission_normal()
    self:test_qbcore_has_permission_unknown()
    self:test_qbcore_has_permission_invalid_source()
    self:test_qbox_has_permission_admin()
    self:test_qbox_has_permission_moderator()
    self:test_qbox_has_permission_normal()
    self:test_qbox_has_permission_unknown()
    self:test_qbox_has_permission_invalid_source()
    self:test_vrp_has_permission_admin()
    self:test_vrp_has_permission_moderator()
    self:test_vrp_has_permission_normal()
    self:test_vrp_has_permission_unknown()
    self:test_vrp_has_permission_invalid_source()
    self:test_nd_has_permission_admin()
    self:test_nd_has_permission_moderator()
    self:test_nd_has_permission_normal()
    self:test_nd_has_permission_unknown()
    self:test_nd_has_permission_invalid_source()
    return self.tests
end

function FrameworkPermissionTests:test_standalone_has_permission_admin()
    -- Test: Check admin permission in standalone
    -- Expected: Returns boolean
    local standalone = require("enemyx.adapters.standalone")
    local hasPerm = standalone.HasPermission(0, "admin") -- Using source 0 for testing
    self.tests["standalone_has_permission_admin"] = type(hasPerm) == "boolean"
    print("[EnemyX Framework] Permission: Standalone Has Permission Admin - " .. (self.tests["standalone_has_permission_admin"] and "PASS" or "FAIL"))
end

function FrameworkPermissionTests:test_standalone_has_permission_moderator()
    -- Test: Check moderator permission in standalone
    -- Expected: Returns boolean
    local standalone = require("enemyx.adapters.standalone")
    local hasPerm = standalone.HasPermission(0, "moderator") -- Using source 0 for testing
    self.tests["standalone_has_permission_moderator"] = type(hasPerm) == "boolean"
    print("[EnemyX Framework] Permission: Standalone Has Permission Moderator - " .. (self.tests["standalone_has_permission_moderator"] and "PASS" or "FAIL"))
end

function FrameworkPermissionTests:test_standalone_has_permission_normal()
    -- Test: Check normal permission in standalone
    -- Expected: Returns boolean
    local standalone = require("enemyx.adapters.standalone")
    local hasPerm = standalone.HasPermission(0, "player") -- Using source 0 for testing
    self.tests["standalone_has_permission_normal"] = type(hasPerm) == "boolean"
    print("[EnemyX Framework] Permission: Standalone Has Permission Normal - " .. (self.tests["standalone_has_permission_normal"] and "PASS" or "FAIL"))
end

function FrameworkPermissionTests:test_standalone_has_permission_unknown()
    -- Test: Check unknown permission in standalone
    -- Expected: Returns boolean (should be false for unknown permission)
    local standalone = require("enemyx.adapters.standalone")
    local hasPerm = standalone.HasPermission(0, "unknown_permission_12345") -- Using source 0 for testing
    self.tests["standalone_has_permission_unknown"] = type(hasPerm) == "boolean"
    print("[EnemyX Framework] Permission: Standalone Has Permission Unknown - " .. (self.tests["standalone_has_permission_unknown"] and "PASS" or "FAIL"))
end

function FrameworkPermissionTests:test_standalone_has_permission_invalid_source()
    -- Test: Check permission with invalid source in standalone
    -- Expected: Returns boolean (should be false for invalid source)
    local standalone = require("enemyx.adapters.standalone")
    local hasPerm = standalone.HasPermission(-1, "admin") -- Using invalid source -1
    self.tests["standalone_has_permission_invalid_source"] = type(hasPerm) == "boolean"
    print("[EnemyX Framework] Permission: Standalone Has Permission Invalid Source - " .. (self.tests["standalone_has_permission_invalid_source"] and "PASS" or "FAIL"))
end

function FrameworkPermissionTests:test_esx_has_permission_admin()
    -- Test: Check admin permission in ESX
    -- Expected: Returns boolean or handles unavailability gracefully
    local esx = require("enemyx.adapters.esx")
    local hasPerm = esx.HasPermission(0, "admin") -- Using source 0 for testing
    self.tests["esx_has_permission_admin"] = type(hasPerm) == "boolean"
    print("[EnemyX Framework] Permission: ESX Has Permission Admin - " .. (self.tests["esx_has_permission_admin"] and "PASS" or "FAIL"))
end

function FrameworkPermissionTests:test_esx_has_permission_moderator()
    -- Test: Check moderator permission in ESX
    -- Expected: Returns boolean or handles unavailability gracefully
    local esx = require("enemyx.adapters.esx")
    local hasPerm = esx.HasPermission(0, "moderator") -- Using source 0 for testing
    self.tests["esx_has_permission_moderator"] = type(hasPerm) == "boolean"
    print("[EnemyX Framework] Permission: ESX Has Permission Moderator - " .. (self.tests["esx_has_permission_moderator"] and "PASS" or "FAIL"))
end

function FrameworkPermissionTests:test_esx_has_permission_normal()
    -- Test: Check normal permission in ESX
    -- Expected: Returns boolean or handles unavailability gracefully
    local esx = require("enemyx.adapters.esx")
    local hasPerm = esx.HasPermission(0, "player") -- Using source 0 for testing
    self.tests["esx_has_permission_normal"] = type(hasPerm) == "boolean"
    print("[EnemyX Framework] Permission: ESX Has Permission Normal - " .. (self.tests["esx_has_permission_normal"] and "PASS" or "FAIL"))
end

function FrameworkPermissionTests:test_esx_has_permission_unknown()
    -- Test: Check unknown permission in ESX
    -- Expected: Returns boolean or handles unavailability gracefully
    local esx = require("enemyx.adapters.esx")
    local hasPerm = esx.HasPermission(0, "unknown_permission_12345") -- Using source 0 for testing
    self.tests["esx_has_permission_unknown"] = type(hasPerm) == "boolean"
    print("[EnemyX Framework] Permission: ESX Has Permission Unknown - " .. (self.tests["esx_has_permission_unknown"] and "PASS" or "FAIL"))
end

function FrameworkPermissionTests:test_esx_has_permission_invalid_source()
    -- Test: Check permission with invalid source in ESX
    -- Expected: Returns boolean or handles unavailability gracefully
    local esx = require("enemyx.adapters.esx")
    local hasPerm = esx.HasPermission(-1, "admin") -- Using invalid source -1
    self.tests["esx_has_permission_invalid_source"] = type(hasPerm) == "boolean"
    print("[EnemyX Framework] Permission: ESX Has Permission Invalid Source - " .. (self.tests["esx_has_permission_invalid_source"] and "PASS" or "FAIL"))
end

function FrameworkPermissionTests:test_qbcore_has_permission_admin()
    -- Test: Check admin permission in QBCore
    -- Expected: Returns boolean or handles unavailability gracefully
    local qbcore = require("enemyx.adapters.qbcore")
    local hasPerm = qbcore.HasPermission(0, "admin") -- Using source 0 for testing
    self.tests["qbcore_has_permission_admin"] = type(hasPerm) == "boolean"
    print("[EnemyX Framework] Permission: QBCore Has Permission Admin - " .. (self.tests["qbcore_has_permission_admin"] and "PASS" or "FAIL"))
end

function FrameworkPermissionTests:test_qbcore_has_permission_moderator()
    -- Test: Check moderator permission in QBCore
    -- Expected: Returns boolean or handles unavailability gracefully
    local qbcore = require("enemyx.adapters.qbcore")
    local hasPerm = qbcore.HasPermission(0, "moderator") -- Using source 0 for testing
    self.tests["qbcore_has_permission_moderator"] = type(hasPerm) == "boolean"
    print("[EnemyX Framework] Permission: QBCore Has Permission Moderator - " .. (self.tests["qbcore_has_permission_moderator"] and "PASS" or "FAIL"))
end

function FrameworkPermissionTests:test_qbcore_has_permission_normal()
    -- Test: Check normal permission in QBCore
    -- Expected: Returns boolean or handles unavailability gracefully
    local qbcore = require("enemyx.adapters.qbcore")
    local hasPerm = qbcore.HasPermission(0, "player") -- Using source 0 for testing
    self.tests["qbcore_has_permission_normal"] = type(hasPerm) == "boolean"
    print("[EnemyX Framework] Permission: QBCore Has Permission Normal - " .. (self.tests["qbcore_has_permission_normal"] and "PASS" or "FAIL"))
end

function FrameworkPermissionTests:test_qbcore_has_permission_unknown()
    -- Test: Check unknown permission in QBCore
    -- Expected: Returns boolean or handles unavailability gracefully
    local qbcore = require("enemyx.adapters.qbcore")
    local hasPerm = qbcore.HasPermission(0, "unknown_permission_12345") -- Using source 0 for testing
    self.tests["qbcore_has_permission_unknown"] = type(hasPerm) == "boolean"
    print("[EnemyX Framework] Permission: QBCore Has Permission Unknown - " .. (self.tests["qbcore_has_permission_unknown"] and "PASS" or "FAIL"))
end

function FrameworkPermissionTests:test_qbcore_has_permission_invalid_source()
    -- Test: Check permission with invalid source in QBCore
    -- Expected: Returns boolean or handles unavailability gracefully
    local qbcore = require("enemyx.adapters.qbcore")
    local hasPerm = qbcore.HasPermission(-1, "admin") -- Using invalid source -1
    self.tests["qbcore_has_permission_invalid_source"] = type(hasPerm) == "boolean"
    print("[EnemyX Framework] Permission: QBCore Has Permission Invalid Source - " .. (self.tests["qbcore_has_permission_invalid_source"] and "PASS" or "FAIL"))
end

function FrameworkPermissionTests:test_qbox_has_permission_admin()
    -- Test: Check admin permission in QBox
    -- Expected: Returns boolean or handles unavailability gracefully
    local qbox = require("enemyx.adapters.qbox")
    local hasPerm = qbox.HasPermission(0, "admin") -- Using source 0 for testing
    self.tests["qbox_has_permission_admin"] = type(hasPerm) == "boolean"
    print("[EnemyX Framework] Permission: QBox Has Permission Admin - " .. (self.tests["qbox_has_permission_admin"] and "PASS" or "FAIL"))
end

function FrameworkPermissionTests:test_qbox_has_permission_moderator()
    -- Test: Check moderator permission in QBox
    -- Expected: Returns boolean or handles unavailability gracefully
    local qbox = require("enemyx.adapters.qbox")
    local hasPerm = qbox.HasPermission(0, "moderator") -- Using source 0 for testing
    self.tests["qbox_has_permission_moderator"] = type(hasPerm) == "boolean"
    print("[EnemyX Framework] Permission: QBox Has Permission Moderator - " .. (self.tests["qbox_has_permission_moderator"] and "PASS" or "FAIL"))
end

function FrameworkPermissionTests:test_qbox_has_permission_normal()
    -- Test: Check normal permission in QBox
    -- Expected: Returns boolean or handles unavailability gracefully
    local qbox = require("enemyx.adapters.qbox")
    local hasPerm = qbox.HasPermission(0, "player") -- Using source 0 for testing
    self.tests["qbox_has_permission_normal"] = type(hasPerm) == "boolean"
    print("[EnemyX Framework] Permission: QBox Has Permission Normal - " .. (self.tests["qbox_has_permission_normal"] and "PASS" or "FAIL"))
end

function FrameworkPermissionTests:test_qbox_has_permission_unknown()
    -- Test: Check unknown permission in QBox
    -- Expected: Returns boolean or handles unavailability gracefully
    local qbox = require("enemyx.adapters.qbox")
    local hasPerm = qbox.HasPermission(0, "unknown_permission_12345") -- Using source 0 for testing
    self.tests["qbox_has_permission_unknown"] = type(hasPerm) == "boolean"
    print("[EnemyX Framework] Permission: QBox Has Permission Unknown - " .. (self.tests["qbox_has_permission_unknown"] and "PASS" or "FAIL"))
end

function FrameworkPermissionTests:test_qbox_has_permission_invalid_source()
    -- Test: Check permission with invalid source in QBox
    -- Expected: Returns boolean or handles unavailability gracefully
    local qbox = require("enemyx.adapters.qbox")
    local hasPerm = qbox.HasPermission(-1, "admin") -- Using invalid source -1
    self.tests["qbox_has_permission_invalid_source"] = type(hasPerm) == "boolean"
    print("[EnemyX Framework] Permission: QBox Has Permission Invalid Source - " .. (self.tests["qbox_has_permission_invalid_source"] and "PASS" or "FAIL"))
end

function FrameworkPermissionTests:test_vrp_has_permission_admin()
    -- Test: Check admin permission in vRP
    -- Expected: Returns boolean or handles unavailability gracefully
    local vrp = require("enemyx.adapters.vrp")
    local hasPerm = vrp.HasPermission(0, "admin") -- Using source 0 for testing
    self.tests["vrp_has_permission_admin"] = type(hasPerm) == "boolean"
    print("[EnemyX Framework] Permission: vRP Has Permission Admin - " .. (self.tests["vrp_has_permission_admin"] and "PASS" or "FAIL"))
end

function FrameworkPermissionTests:test_vrp_has_permission_moderator()
    -- Test: Check moderator permission in vRP
    -- Expected: Returns boolean or handles unavailability gracefully
    local vrp = require("enemyx.adapters.vrp")
    local hasPerm = vrp.HasPermission(0, "moderator") -- Using source 0 for testing
    self.tests["vrp_has_permission_moderator"] = type(hasPerm) == "boolean"
    print("[EnemyX Framework] Permission: vRP Has Permission Moderator - " .. (self.tests["vrp_has_permission_moderator"] and "PASS" or "FAIL"))
end

function FrameworkPermissionTests:test_vrp_has_permission_normal()
    -- Test: Check normal permission in vRP
    -- Expected: Returns boolean or handles unavailability gracefully
    local vrp = require("enemyx.adapters.vrp")
    local hasPerm = vrp.HasPermission(0, "player") -- Using source 0 for testing
    self.tests["vrp_has_permission_normal"] = type(hasPerm) == "boolean"
    print("[EnemyX Framework] Permission: vRP Has Permission Normal - " .. (self.tests["vrp_has_permission_normal"] and "PASS" or "FAIL"))
end

function FrameworkPermissionTests:test_vrp_has_permission_unknown()
    -- Test: Check unknown permission in vRP
    -- Expected: Returns boolean or handles unavailability gracefully
    local vrp = require("enemyx.adapters.vrp")
    local hasPerm = vrp.HasPermission(0, "unknown_permission_12345") -- Using source 0 for testing
    self.tests["vrp_has_permission_unknown"] = type(hasPerm) == "boolean"
    print("[EnemyX Framework] Permission: vRP Has Permission Unknown - " .. (self.tests["vrp_has_permission_unknown"] and "PASS" or "FAIL"))
end

function FrameworkPermissionTests:test_vrp_has_permission_invalid_source()
    -- Test: Check permission with invalid source in vRP
    -- Expected: Returns boolean or handles unavailability gracefully
    local vrp = require("enemyx.adapters.vrp")
    local hasPerm = vrp.HasPermission(-1, "admin") -- Using invalid source -1
    self.tests["vrp_has_permission_invalid_source"] = type(hasPerm) == "boolean"
    print("[EnemyX Framework] Permission: vRP Has Permission Invalid Source - " .. (self.tests["vrp_has_permission_invalid_source"] and "PASS" or "FAIL"))
end

function FrameworkPermissionTests:test_nd_has_permission_admin()
    -- Test: Check admin permission in ND
    -- Expected: Returns boolean or handles unavailability gracefully
    local nd = require("enemyx.adapters.nd")
    local hasPerm = nd.HasPermission(0, "admin") -- Using source 0 for testing
    self.tests["nd_has_permission_admin"] = type(hasPerm) == "boolean"
    print("[EnemyX Framework] Permission: ND Has Permission Admin - " .. (self.tests["nd_has_permission_admin"] and "PASS" or "FAIL"))
end

function FrameworkPermissionTests:test_nd_has_permission_moderator()
    -- Test: Check moderator permission in ND
    -- Expected: Returns boolean or handles unavailability gracefully
    local nd = require("enemyx.adapters.nd")
    local hasPerm = nd.HasPermission(0, "moderator") -- Using source 0 for testing
    self.tests["nd_has_permission_moderator"] = type(hasPerm) == "boolean"
    print("[EnemyX Framework] Permission: ND Has Permission Moderator - " .. (self.tests["nd_has_permission_moderator"] and "PASS" or "FAIL"))
end

function FrameworkPermissionTests:test_nd_has_permission_normal()
    -- Test: Check normal permission in ND
    -- Expected: Returns boolean or handles unavailability gracefully
    local nd = require("enemyx.adapters.nd")
    local hasPerm = nd.HasPermission(0, "player") -- Using source 0 for testing
    self.tests["nd_has_permission_normal"] = type(hasPerm) == "boolean"
    print("[EnemyX Framework] Permission: ND Has Permission Normal - " .. (self.tests["nd_has_permission_normal"] and "PASS" or "FAIL"))
end

function FrameworkPermissionTests:test_nd_has_permission_unknown()
    -- Test: Check unknown permission in ND
    -- Expected: Returns boolean or handles unavailability gracefully
    local nd = require("enemyx.adapters.nd")
    local hasPerm = nd.HasPermission(0, "unknown_permission_12345") -- Using source 0 for testing
    self.tests["nd_has_permission_unknown"] = type(hasPerm) == "boolean"
    print("[EnemyX Framework] Permission: ND Has Permission Unknown - " .. (self.tests["nd_has_permission_unknown"] and "PASS" or "FAIL"))
end

function FrameworkPermissionTests:test_nd_has_permission_invalid_source()
    -- Test: Check permission with invalid source in ND
    -- Expected: Returns boolean or handles unavailability gracefully
    local nd = require("enemyx.adapters.nd")
    local hasPerm = nd.HasPermission(-1, "admin") -- Using invalid source -1
    self.tests["nd_has_permission_invalid_source"] = type(hasPerm) == "boolean"
    print("[EnemyX Framework] Permission: ND Has Permission Invalid Source - " .. (self.tests["nd_has_permission_invalid_source"] and "PASS" or "FAIL"))
end

return FrameworkPermissionTests