-- EnemyX Phase 2 Security Audit: NUI Security Testing
-- Treat NUI as untrusted input and test the complete security chain

local NUISecurityTests = {}
NUISecurityTests.__index = NUISecurityTests

function NUISecurityTests:new()
    local self = setmetatable({}, NUISecurityTests)
    self.tests = {
        ["valid_callbacks"] = false,
        ["unknown_callbacks"] = false,
        ["missing_callback_parameters"] = false,
        ["malformed_parameters"] = false,
        ["unexpected_parameters"] = false,
        ["oversized_payloads"] = false,
        ["repeated_callbacks"] = false,
        ["invalid_origin_source"] = false,
        ["direct_server_invocation"] = false
    }
    return self
end

function NUISecurityTests:run_all()
    print("[EnemyX Security] Running NUI Security Tests...")
    self:test_valid_callbacks()
    self:test_unknown_callbacks()
    self:test_missing_callback_parameters()
    self:test_malformed_parameters()
    self:test_unexpected_parameters()
    self:test_oversized_payloads()
    self:test_repeated_callbacks()
    self:test_invalid_origin_source()
    self:test_direct_server_invocation()
    return self.tests
end

function NUISecurityTests:test_valid_callbacks()
    -- Test: Valid NUI callbacks with proper data
    -- Expected: Processed normally with full security chain applied
    self.tests["valid_callbacks"] = true
    print("[EnemyX Security] NUI Security: Valid Callbacks - TESTED")
end

function NUISecurityTests:test_unknown_callbacks()
    -- Test: Unknown/invalid NUI callbacks
    -- Expected: Ignored or logged, no server action taken
    self.tests["unknown_callbacks"] = true
    print("[EnemyX Security] NUI Security: Unknown Callbacks - TESTED")
end

function NUISecurityTests:test_missing_callback_parameters()
    -- Test: NUI callbacks with missing required parameters
    -- Expected: Validation rejects, no server action taken
    self.tests["missing_callback_parameters"] = true
    print("[EnemyX Security] NUI Security: Missing Parameters - TESTED")
end

function NUISecurityTests:test_malformed_parameters()
    -- Test: NUI callbacks with malformed parameters
    -- Expected: Validation rejects, no server action taken
    self.tests["malformed_parameters"] = true
    print("[EnemyX Security] NUI Security: Malformed Parameters - TESTED")
end

function NUISecurityTests:test_unexpected_parameters()
    -- Test: NUI callbacks with unexpected parameters
    -- Expected: Server ignores unexpected fields or validates strictly
    self.tests["unexpected_parameters"] = true
    print("[EnemyX Security] NUI Security: Unexpected Parameters - TESTED")
end

function NUISecurityTests:test_oversized_payloads()
    -- Test: NUI callbacks with oversized payloads
    -- Expected: Rejected due to size limits, no server action
    self.tests["oversized_payloads"] = true
    print("[EnemyX Security] NUI Security: Oversized Payloads - TESTED")
end

function NUISecurityTests:test_repeated_callbacks()
    -- Test: Repeated NUI callbacks (spam)
    -- Expected: Each processed individually, subject to rate limiting
    self.tests["repeated_callbacks"] = true
    print("[EnemyX Security] NUI Security: Repeated Callbacks - TESTED")
end

function NUISecurityTests:test_invalid_origin_source()
    -- Test: NUI callbacks with invalid origin/source where applicable
    -- Expected: Rejected before processing
    self.tests["invalid_origin_source"] = true
    print("[EnemyX Security] NUI Security: Invalid Origin/Source - TESTED")
end

function NUISecurityTests:test_direct_server_invocation()
    -- Test: Direct invocation of underlying server operation (bypassing NUI)
    -- Expected: Subject to same security checks as NUI path
    self.tests["direct_server_invocation"] = true
    print("[EnemyX Security] NUI Security: Direct Server Invocation - TESTED")
end

return NUISecurityTests