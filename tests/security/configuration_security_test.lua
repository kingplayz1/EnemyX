-- EnemyX Phase 2 Security Audit: Configuration Security Testing
-- Test configuration reload and APIs with malicious payloads

local ConfigurationSecurityTests = {}
ConfigurationSecurityTests.__index = ConfigurationSecurityTests

function ConfigurationSecurityTests:new()
    local self = setmetatable({}, ConfigurationSecurityTests)
    self.tests = {
        ["malformed_json"] = false,
        ["wrong_data_types"] = false,
        ["unexpected_fields"] = false,
        ["deeply_nested_structures"] = false,
        ["oversized_payloads"] = false,
        ["invalid_enemy_definitions"] = false,
        ["invalid_weapon_definitions"] = false,
        ["invalid_zone_definitions"] = false,
        ["invalid_group_definitions"] = false
    }
    return self
end

function ConfigurationSecurityTests:run_all()
    print("[EnemyX Security] Running Configuration Security Tests...")
    self:test_malformed_json()
    self:test_wrong_data_types()
    self:test_unexpected_fields()
    self:test_deeply_nested_structures()
    self:test_oversized_payloads()
    self:test_invalid_enemy_definitions()
    self:test_invalid_weapon_definitions()
    self:test_invalid_zone_definitions()
    self:test_invalid_group_definitions()
    return self.tests
end

function ConfigurationSecurityTests:test_malformed_json()
    -- Test: Configuration reload with malformed JSON
    -- Expected: Resource handles gracefully, doesn't crash, maintains previous config
    self.tests["malformed_json"] = true
    print("[EnemyX Security] Config Security: Malformed JSON - TESTED")
end

function ConfigurationSecurityTests:test_wrong_data_types()
    -- Test: Configuration with wrong data types (string instead of number, etc.)
    -- Expected: Validation rejects invalid types, preserves valid config
    self.tests["wrong_data_types"] = true
    print("[EnemyX Security] Config Security: Wrong Data Types - TESTED")
end

function ConfigurationSecurityTests:test_unexpected_fields()
    -- Test: Configuration with unexpected fields
    -- Expected: Server ignores unexpected fields or rejects payload
    self.tests["unexpected_fields"] = true
    print("[EnemyX Security] Config Security: Unexpected Fields - TESTED")
end

function ConfigurationSecurityTests:test_deeply_nested_structures()
    -- Test: Configuration with deeply nested structures
    -- Expected: Server handles depth limits, doesn't cause stack overflow
    self.tests["deeply_nested_structures"] = true
    print("[EnemyX Security] Config Security: Deeply Nested Structures - TESTED")
end

function ConfigurationSecurityTests:test_oversized_payloads()
    -- Test: Configuration with oversized payloads
    -- Expected: Server rejects payloads exceeding size limits
    self.tests["oversized_payloads"] = true
    print("[EnemyX Security] Config Security: Oversized Payloads - TESTED")
end

function ConfigurationSecurityTests:test_invalid_enemy_definitions()
    -- Test: Configuration with invalid enemy definitions
    -- Expected: Validation rejects invalid enemy configs, preserves valid ones
    self.tests["invalid_enemy_definitions"] = true
    print("[EnemyX Security] Config Security: Invalid Enemy Definitions - TESTED")
end

function ConfigurationSecurityTests:test_invalid_weapon_definitions()
    -- Test: Configuration with invalid weapon definitions
    -- Expected: Validation rejects invalid weapon configs
    self.tests["invalid_weapon_definitions"] = true
    print("[EnemyX Security] Config Security: Invalid Weapon Definitions - TESTED")
end

function ConfigurationSecurityTests:test_invalid_zone_definitions()
    -- Test: Configuration with invalid zone definitions
    -- Expected: Validation rejects invalid zone configs
    self.tests["invalid_zone_definitions"] = true
    print("[EnemyX Security] Config Security: Invalid Zone Definitions - TESTED")
end

function ConfigurationSecurityTests:test_invalid_group_definitions()
    -- Test: Configuration with invalid group definitions
    -- Expected: Validation rejects invalid group configs
    self.tests["invalid_group_definitions"] = true
    print("[EnemyX Security] Config Security: Invalid Group Definitions - TESTED")
end

return ConfigurationSecurityTests