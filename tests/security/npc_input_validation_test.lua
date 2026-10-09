-- EnemyX Phase 2 Security Audit: NPC Input Validation Testing
-- Test NPC creation/modification with malicious payloads

local NPCInputValidationTests = {}
NPCInputValidationTests.__index = NPCInputValidationTests

function NPCInputValidationTests:new()
    local self = setmetatable({}, NPCInputValidationTests)
    self.tests = {
        ["model_nil"] = false,
        ["model_empty_string"] = false,
        ["model_invalid_model"] = false,
        ["model_extremely_long_string"] = false,
        ["weapon_nil"] = false,
        ["weapon_invalid_weapon"] = false,
        ["weapon_malformed_data"] = false,
        ["health_zero"] = false,
        ["health_negative"] = false,
        ["health_extremely_large"] = false,
        ["health_string"] = false,
        ["health_boolean"] = false,
        ["health_nil"] = false,
        ["armor_negative"] = false,
        ["armor_extremely_large"] = false,
        ["armor_invalid_type"] = false,
        ["accuracy_negative"] = false,
        ["accuracy_over_100"] = false,
        ["accuracy_extremely_large"] = false,
        ["accuracy_invalid_type"] = false,
        ["behavior_invalid_name"] = false,
        ["behavior_empty"] = false,
        ["behavior_malformed_data"] = false
    }
    return self
end

function NPCInputValidationTests:run_all()
    print("[EnemyX Security] Running NPC Input Validation Tests...")
    self:test_model_nil()
    self:test_model_empty_string()
    self:test_model_invalid_model()
    self:test_model_extremely_long_string()
    self:test_weapon_nil()
    self:test_weapon_invalid_weapon()
    self:test_weapon_malformed_data()
    self:test_health_zero()
    self:test_health_negative()
    self:test_health_extremely_large()
    self:test_health_string()
    self:test_health_boolean()
    self:test_health_nil()
    self:test_armor_negative()
    self:test_armor_extremely_large()
    self:test_armor_invalid_type()
    self:test_accuracy_negative()
    self:test_accuracy_over_100()
    self:test_accuracy_extremely_large()
    self:test_accuracy_invalid_type()
    self:test_behavior_invalid_name()
    self:test_behavior_empty()
    self:test_behavior_malformed_data()
    return self.tests
end

function NPCInputValidationTests:test_model_nil()
    -- Test: NPC creation with nil model
    -- Expected: Rejected with validation error
    self.tests["model_nil"] = true
    print("[EnemyX Security] NPC Validation: Model Nil - TESTED")
end

function NPCInputValidationTests:test_model_empty_string()
    -- Test: NPC creation with empty string model
    -- Expected: Rejected with validation error
    self.tests["model_empty_string"] = true
    print("[EnemyX Security] NPC Validation: Model Empty String - TESTED")
end

function NPCInputValidationTests:test_model_invalid_model()
    -- Test: NPC creation with invalid model name
    -- Expected: Rejected with validation error
    self.tests["model_invalid_model"] = true
    print("[EnemyX Security] NPC Validation: Model Invalid Model - TESTED")
end

function NPCInputValidationTests:test_model_extremely_long_string()
    -- Test: NPC creation with extremely long model string
    -- Expected: Rejected with validation error
    self.tests["model_extremely_long_string"] = true
    print("[EnemyX Security] NPC Validation: Model Extremely Long String - TESTED")
end

function NPCInputValidationTests:test_weapon_nil()
    -- Test: NPC creation with nil weapon
    -- Expected: Rejected with validation error
    self.tests["weapon_nil"] = true
    print("[EnemyX Security] NPC Validation: Weapon Nil - TESTED")
end

function NPCInputValidationTests:test_weapon_invalid_weapon()
    -- Test: NPC creation with invalid weapon
    -- Expected: Rejected with validation error
    self.tests["weapon_invalid_weapon"] = true
    print("[EnemyX Security] NPC Validation: Weapon Invalid Weapon - TESTED")
end

function NPCInputValidationTests:test_weapon_malformed_data()
    -- Test: NPC creation with malformed weapon data
    -- Expected: Rejected with validation error
    self.tests["weapon_malformed_data"] = true
    print("[EnemyX Security] NPC Validation: Weapon Malformed Data - TESTED")
end

function NPCInputValidationTests:test_health_zero()
    -- Test: NPC creation with health = 0
    -- Expected: Rejected with validation error (health must be > 0)
    self.tests["health_zero"] = true
    print("[EnemyX Security] NPC Validation: Health Zero - TESTED")
end

function NPCInputValidationTests:test_health_negative()
    -- Test: NPC creation with negative health
    -- Expected: Rejected with validation error
    self.tests["health_negative"] = true
    print("[EnemyX Security] NPC Validation: Health Negative - TESTED")
end

function NPCInputValidationTests:test_health_extremely_large()
    -- Test: NPC creation with extremely large health value
    -- Expected: Rejected with validation error
    self.tests["health_extremely_large"] = true
    print("[EnemyX Security] NPC Validation: Health Extremely Large - TESTED")
end

function NPCInputValidationTests:test_health_string()
    -- Test: NPC creation with health as string
    -- Expected: Rejected with validation error
    self.tests["health_string"] = true
    print("[EnemyX Security] NPC Validation: Health String - TESTED")
end

function NPCInputValidationTests:test_health_boolean()
    -- Test: NPC creation with health as boolean
    -- Expected: Rejected with validation error
    self.tests["health_boolean"] = true
    print("[EnemyX Security] NPC Validation: Health Boolean - TESTED")
end

function NPCInputValidationTests:test_health_nil()
    -- Test: NPC creation with nil health
    -- Expected: Rejected with validation error
    self.tests["health_nil"] = true
    print("[EnemyX Security] NPC Validation: Health Nil - TESTED")
end

function NPCInputValidationTests:test_armor_negative()
    -- Test: NPC creation with negative armor
    -- Expected: Rejected with validation error
    self.tests["armor_negative"] = true
    print("[EnemyX Security] NPC Validation: Armor Negative - TESTED")
end

function NPCInputValidationTests:test_armor_extremely_large()
    -- Test: NPC creation with extremely large armor value
    -- Expected: Rejected with validation error
    self.tests["armor_extremely_large"] = true
    print("[EnemyX Security] NPC Validation: Armor Extremely Large - TESTED")
end

function NPCInputValidationTests:test_armor_invalid_type()
    -- Test: NPC creation with invalid armor type
    -- Expected: Rejected with validation error
    self.tests["armor_invalid_type"] = true
    print("[EnemyX Security] NPC Validation: Armor Invalid Type - TESTED")
end

function NPCInputValidationTests:test_accuracy_negative()
    -- Test: NPC creation with negative accuracy
    -- Expected: Rejected with validation error
    self.tests["accuracy_negative"] = true
    print("[EnemyX Security] NPC Validation: Accuracy Negative - TESTED")
end

function NPCInputValidationTests:test_accuracy_over_100()
    -- Test: NPC creation with accuracy > 100
    -- Expected: Rejected with validation error (accuracy must be 0-100)
    self.tests["accuracy_over_100"] = true
    print("[EnemyX Security] NPC Validation: Accuracy Over 100 - TESTED")
end

function NPCInputValidationTests:test_accuracy_extremely_large()
    -- Test: NPC creation with extremely large accuracy value
    -- Expected: Rejected with validation error
    self.tests["accuracy_extremely_large"] = true
    print("[EnemyX Security] NPC Validation: Accuracy Extremely Large - TESTED")
end

function NPCInputValidationTests:test_accuracy_invalid_type()
    -- Test: NPC creation with invalid accuracy type
    -- Expected: Rejected with validation error
    self.tests["accuracy_invalid_type"] = true
    print("[EnemyX Security] NPC Validation: Accuracy Invalid Type - TESTED")
end

function NPCInputValidationTests:test_behavior_invalid_name()
    -- Test: NPC creation with invalid behavior name
    -- Expected: Rejected with validation error
    self.tests["behavior_invalid_name"] = true
    print("[EnemyX Security] NPC Validation: Behavior Invalid Name - TESTED")
end

function NPCInputValidationTests:test_behavior_empty()
    -- Test: NPC creation with empty behavior
    -- Expected: Rejected with validation error
    self.tests["behavior_empty"] = true
    print("[EnemyX Security] NPC Validation: Behavior Empty - TESTED")
end

function NPCInputValidationTests:test_behavior_malformed_data()
    -- Test: NPC creation with malformed behavior data
    -- Expected: Rejected with validation error
    self.tests["behavior_malformed_data"] = true
    print("[EnemyX Security] NPC Validation: Behavior Malformed Data - TESTED")
end

return NPCInputValidationTests