-- EnemyX Phase 3 Framework Matrix Testing: Player Identity Testing
-- Test player identity capabilities across frameworks

local FrameworkPlayerIdentityTests = {}
FrameworkPlayerIdentityTests.__index = FrameworkPlayerIdentityTests

function FrameworkPlayerIdentityTests:new()
    local self = setmetatable({}, FrameworkPlayerIdentityTests)
    self.tests = {
        ["standalone_get_player"] = false,
        ["standalone_get_player_identifier"] = false,
        ["esx_get_player"] = false,
        ["esx_get_player_identifier"] = false,
        ["qbcore_get_player"] = false,
        ["qbcore_get_player_identifier"] = false,
        ["qbox_get_player"] = false,
        ["qbox_get_player_identifier"] = false,
        ["vrp_get_player"] = false,
        ["vrp_get_player_identifier"] = false,
        ["nd_get_player"] = false,
        ["nd_get_player_identifier"] = false,
    }
    return self
end

function FrameworkPlayerIdentityTests:run_all()
    print("[EnemyX Framework] Running Player Identity Tests...")
    self:test_standalone_get_player()
    self:test_standalone_get_player_identifier()
    self:test_esx_get_player()
    self:test_esx_get_player_identifier()
    self:test_qbcore_get_player()
    self:test_qbcore_get_player_identifier()
    self:test_qbox_get_player()
    self:test_qbox_get_player_identifier()
    self:test_vrp_get_player()
    self:test_vrp_get_player_identifier()
    self:test_nd_get_player()
    self:test_nd_get_player_identifier()
    return self.tests
end

function FrameworkPlayerIdentityTests:test_standalone_get_player()
    -- Test: Get player ped in standalone
    -- Expected: Returns a valid ped handle (number)
    local standalone = require("enemyx.adapters.standalone")
    local ped = standalone.GetPlayer(0) -- Using source 0 for testing
    self.tests["standalone_get_player"] = type(ped) == "number" and ped >= 0
    print("[EnemyX Framework] Player Identity: Standalone Get Player - " .. (self.tests["standalone_get_player"] and "PASS" or "FAIL"))
end

function FrameworkPlayerIdentityTests:test_standalone_get_player_identifier()
    -- Test: Get player identifier in standalone
    -- Expected: Returns a string identifier
    local standalone = require("enemyx.adapters.standalone")
    local identifier = standalone.GetPlayerIdentifier(0) -- Using source 0 for testing
    self.tests["standalone_get_player_identifier"] = type(identifier) == "string" and identifier ~= ""
    print("[EnemyX Framework] Player Identity: Standalone Get Identifier - " .. (self.tests["standalone_get_player_identifier"] and "PASS" or "FAIL"))
end

function FrameworkPlayerIdentityTests:test_esx_get_player()
    -- Test: Get player ped in ESX
    -- Expected: Returns a valid ped handle (number) or handles unavailability gracefully
    local esx = require("enemyx.adapters.esx")
    local ped = esx.GetPlayer(0) -- Using source 0 for testing
    self.tests["esx_get_player"] = type(ped) == "number" and ped >= 0
    print("[EnemyX Framework] Player Identity: ESX Get Player - " .. (self.tests["esx_get_player"] and "PASS" or "FAIL"))
end

function FrameworkPlayerIdentityTests:test_esx_get_player_identifier()
    -- Test: Get player identifier in ESX
    -- Expected: Returns a string identifier or handles unavailability gracefully
    local esx = require("enemyx.adapters.esx")
    local identifier = esx.GetPlayerIdentifier(0) -- Using source 0 for testing
    self.tests["esx_get_player_identifier"] = type(identifier) == "string"
    print("[EnemyX Framework] Player Identity: ESX Get Identifier - " .. (self.tests["esx_get_player_identifier"] and "PASS" or "FAIL"))
end

function FrameworkPlayerIdentityTests:test_qbcore_get_player()
    -- Test: Get player ped in QBCore
    -- Expected: Returns a valid ped handle (number) or handles unavailability gracefully
    local qbcore = require("enemyx.adapters.qbcore")
    local ped = qbcore.GetPlayer(0) -- Using source 0 for testing
    self.tests["qbcore_get_player"] = type(ped) == "number" and ped >= 0
    print("[EnemyX Framework] Player Identity: QBCore Get Player - " .. (self.tests["qbcore_get_player"] and "PASS" or "FAIL"))
end

function FrameworkPlayerIdentityTests:test_qbcore_get_player_identifier()
    -- Test: Get player identifier in QBCore
    -- Expected: Returns a string identifier or handles unavailability gracefully
    local qbcore = require("enemyx.adapters.qbcore")
    local identifier = qbcore.GetPlayerIdentifier(0) -- Using source 0 for testing
    self.tests["qbcore_get_player_identifier"] = type(identifier) == "string"
    print("[EnemyX Framework] Player Identity: QBCore Get Identifier - " .. (self.tests["qbcore_get_player_identifier"] and "PASS" or "FAIL"))
end

function FrameworkPlayerIdentityTests:test_qbox_get_player()
    -- Test: Get player ped in QBox
    -- Expected: Returns a valid ped handle (number) or handles unavailability gracefully
    local qbox = require("enemyx.adapters.qbox")
    local ped = qbox.GetPlayer(0) -- Using source 0 for testing
    self.tests["qbox_get_player"] = type(ped) == "number" and ped >= 0
    print("[EnemyX Framework] Player Identity: QBox Get Player - " .. (self.tests["qbox_get_player"] and "PASS" or "FAIL"))
end

function FrameworkPlayerIdentityTests:test_qbox_get_player_identifier()
    -- Test: Get player identifier in QBox
    -- Expected: Returns a string identifier or handles unavailability gracefully
    local qbox = require("enemyx.adapters.qbox")
    local identifier = qbox.GetPlayerIdentifier(0) -- Using source 0 for testing
    self.tests["qbox_get_player_identifier"] = type(identifier) == "string"
    print("[EnemyX Framework] Player Identity: QBox Get Identifier - " .. (self.tests["qbox_get_player_identifier"] and "PASS" or "FAIL"))
end

function FrameworkPlayerIdentityTests:test_vrp_get_player()
    -- Test: Get player ped in vRP
    -- Expected: Returns a valid ped handle (number) or handles unavailability gracefully
    local vrp = require("enemyx.adapters.vrp")
    local ped = vrp.GetPlayer(0) -- Using source 0 for testing
    self.tests["vrp_get_player"] = type(ped) == "number" and ped >= 0
    print("[EnemyX Framework] Player Identity: vRP Get Player - " .. (self.tests["vrp_get_player"] and "PASS" or "FAIL"))
end

function FrameworkPlayerIdentityTests:test_vrp_get_player_identifier()
    -- Test: Get player identifier in vRP
    -- Expected: Returns a string identifier or handles unavailability gracefully
    local vrp = require("enemyx.adapters.vrp")
    local identifier = vrp.GetPlayerIdentifier(0) -- Using source 0 for testing
    self.tests["vrp_get_player_identifier"] = type(identifier) == "string"
    print("[EnemyX Framework] Player Identity: vRP Get Identifier - " .. (self.tests["vrp_get_player_identifier"] and "PASS" or "FAIL"))
end

function FrameworkPlayerIdentityTests:test_nd_get_player()
    -- Test: Get player ped in ND
    -- Expected: Returns a valid ped handle (number) or handles unavailability gracefully
    local nd = require("enemyx.adapters.nd")
    local ped = nd.GetPlayer(0) -- Using source 0 for testing
    self.tests["nd_get_player"] = type(ped) == "number" and ped >= 0
    print("[EnemyX Framework] Player Identity: ND Get Player - " .. (self.tests["nd_get_player"] and "PASS" or "FAIL"))
end

function FrameworkPlayerIdentityTests:test_nd_get_player_identifier()
    -- Test: Get player identifier in ND
    -- Expected: Returns a string identifier or handles unavailability gracefully
    local nd = require("enemyx.adapters.nd")
    local identifier = nd.GetPlayerIdentifier(0) -- Using source 0 for testing
    self.tests["nd_get_player_identifier"] = type(identifier) == "string"
    print("[EnemyX Framework] Player Identity: ND Get Identifier - " .. (self.tests["nd_get_player_identifier"] and "PASS" or "FAIL"))
end

return FrameworkPlayerIdentityTests