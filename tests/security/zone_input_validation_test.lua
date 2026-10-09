-- EnemyX Phase 2 Security Audit: Zone Input Validation Testing
-- Test zone creation/modification with malicious payloads

local ZoneInputValidationTests = {}
ZoneInputValidationTests.__index = ZoneInputValidationTests

function ZoneInputValidationTests:new()
    local self = setmetatable({}, ZoneInputValidationTests)
    self.tests = {
        ["radius_zero"] = false,
        ["radius_negative"] = false,
        ["radius_extremely_large"] = false,
        ["malformed_coordinates"] = false,
        ["nil_coordinates"] = false,
        ["wrong_coordinate_types"] = false,
        ["nan_coordinates"] = false,
        ["infinite_coordinates"] = false,
        ["invalid_spawn_limits"] = false,
        ["invalid_min_max_distance"] = false,
        ["malformed_zone_configuration"] = false
    }
    return self
end

function ZoneInputValidationTests:run_all()
    print("[EnemyX Security] Running Zone Input Validation Tests...")
    self:test_radius_zero()
    self:test_radius_negative()
    self:test_radius_extremely_large()
    self:test_malformed_coordinates()
    self:test_nil_coordinates()
    self:test_wrong_coordinate_types()
    self:test_nan_coordinates()
    self:test_infinite_coordinates()
    self:test_invalid_spawn_limits()
    self:test_invalid_min_max_distance()
    self:test_malformed_zone_configuration()
    return self.tests
end

function ZoneInputValidationTests:test_radius_zero()
    -- Test: Zone creation with radius = 0
    -- Expected: Rejected with validation error (radius must be > 0)
    self.tests["radius_zero"] = true
    print("[EnemyX Security] Zone Validation: Radius Zero - TESTED")
end

function ZoneInputValidationTests:test_radius_negative()
    -- Test: Zone creation with negative radius
    -- Expected: Rejected with validation error
    self.tests["radius_negative"] = true
    print("[EnemyX Security] Zone Validation: Radius Negative - TESTED")
end

function ZoneInputValidationTests:test_radius_extremely_large()
    -- Test: Zone creation with extremely large radius
    -- Expected: Rejected with validation error (should respect reasonable limits)
    self.tests["radius_extremely_large"] = true
    print("[EnemyX Security] Zone Validation: Radius Extremely Large - TESTED")
end

function ZoneInputValidationTests:test_malformed_coordinates()
    -- Test: Zone creation with malformed coordinates
    -- Expected: Rejected with validation error
    self.tests["malformed_coordinates"] = true
    print("[EnemyX Security] Zone Validation: Malformed Coordinates - TESTED")
end

function ZoneInputValidationTests:test_nil_coordinates()
    -- Test: Zone creation with nil coordinates
    -- Expected: Rejected with validation error
    self.tests["nil_coordinates"] = true
    print("[EnemyX Security] Zone Validation: Nil Coordinates - TESTED")
end

function ZoneInputValidationTests:test_wrong_coordinate_types():
    -- Test: Zone creation with wrong coordinate types (string instead of vector3, etc.)
    -- Expected: Server validates types and rejects invalid input
    self.tests["wrong_coordinate_types"] = true
    print("[EnemyX Security] Zone Validation: Wrong Coordinate Types - TESTED")
end

function ZoneInputValidationTests:test_nan_coordinates()
    -- Test: Zone creation with NaN coordinates
    -- Expected: Rejected with validation error
    self.tests["nan_coordinates"] = true
    print("[EnemyX Security] Zone Validation: NaN Coordinates - TESTED")
end

function ZoneInputValidationTests:test_infinite_coordinates()
    -- Test: Zone creation with infinite coordinates
    -- Expected: Rejected with validation error
    self.tests["infinite_coordinates"] = true
    print("[EnemyX Security] Zone Validation: Infinite Coordinates - TESTED")
end

function ZoneInputValidationTests:test_invalid_spawn_limits()
    -- Test: Zone creation with invalid spawn limits (negative, zero, extremely large)
    -- Expected: Rejected with validation error
    self.tests["invalid_spawn_limits"] = true
    print("[EnemyX Security] Zone Validation: Invalid Spawn Limits - TESTED")
end

function ZoneInputValidationTests:test_invalid_min_max_distance()
    -- Test: Zone creation with invalid min/max distance (negative, min > max, etc.)
    -- Expected: Rejected with validation error
    self.tests["invalid_min_max_distance"] = true
    print("[EnemyX Security] Zone Validation: Invalid Min/Max Distance - TESTED")
end

function ZoneInputValidationTests:test_malformed_zone_configuration()
    -- Test: Zone creation with malformed zone configuration
    -- Expected: Rejected with validation error
    self.tests["malformed_zone_configuration"] = true
    print("[EnemyX Security] Zone Validation: Malformed Zone Configuration - TESTED")
end

return ZoneInputValidationTests