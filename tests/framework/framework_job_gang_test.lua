-- EnemyX Phase 3 Framework Matrix Testing: Job and Gang Testing
-- Test job and gang capabilities across frameworks

local FrameworkJobGangTests = {}
FrameworkJobGangTests.__index = FrameworkJobGangTests

function FrameworkJobGangTests:new()
    local self = setmetatable({}, FrameworkJobGangTests)
    self.tests = {
        ["standalone_get_player_job"] = false,
        ["standalone_get_player_gang"] = false,
        ["esx_get_player_job"] = false,
        ["esx_get_player_gang"] = false,
        ["qbcore_get_player_job"] = false,
        ["qbcore_get_player_gang"] = false,
        ["qbox_get_player_job"] = false,
        ["qbox_get_player_gang"] = false,
        ["vrp_get_player_job"] = false,
        ["vrp_get_player_gang"] = false,
        ["nd_get_player_job"] = false,
        ["nd_get_player_gang"] = false,
    }
    return self
end

function FrameworkJobGangTests:run_all()
    print("[EnemyX Framework] Running Job and Gang Tests...")
    self:test_standalone_get_player_job()
    self:test_standalone_get_player_gang()
    self:test_esx_get_player_job()
    self:test_esx_get_player_gang()
    self:test_qbcore_get_player_job()
    self:test_qbcore_get_player_gang()
    self:test_qbox_get_player_job()
    self:test_qbox_get_player_gang()
    self:test_vrp_get_player_job()
    self:test_vrp_get_player_gang()
    self:test_nd_get_player_job()
    self:test_nd_get_player_gang()
    return self.tests
end

function FrameworkJobGangTests:test_standalone_get_player_job()
    -- Test: Get player job in standalone
    -- Expected: Returns (nil, 0) as standalone doesn't have job system
    local standalone = require("enemyx.adapters.standalone")
    local job, grade = standalone.GetPlayerJob(0) -- Using source 0 for testing
    self.tests["standalone_get_player_job"] = (job == nil and grade == 0)
    print("[EnemyX Framework] Job and Gang: Standalone Get Job - " .. (self.tests["standalone_get_player_job"] and "PASS" or "FAIL"))
end

function FrameworkJobGangTests:test_standalone_get_player_gang()
    -- Test: Get player gang in standalone
    -- Expected: Returns (nil, 0) as standalone doesn't have gang system
    local standalone = require("enemyx.adapters.standalone")
    local gang, grade = standalone.GetPlayerGang(0) -- Using source 0 for testing
    self.tests["standalone_get_player_gang"] = (gang == nil and grade == 0)
    print("[EnemyX Framework] Job and Gang: Standalone Get Gang - " .. (self.tests["standalone_get_player_gang"] and "PASS" or "FAIL"))
end

function FrameworkJobGangTests:test_esx_get_player_job()
    -- Test: Get player job in ESX
    -- Expected: Returns job name and grade or (nil, 0) if not available
    local esx = require("enemyx.adapters.esx")
    local job, grade = esx.GetPlayerJob(0) -- Using source 0 for testing
    self.tests["esx_get_player_job"] = (type(job) == "string" or job == nil) and (type(grade) == "number" or grade == 0)
    print("[EnemyX Framework] Job and Gang: ESX Get Job - " .. (self.tests["esx_get_player_job"] and "PASS" or "FAIL"))
end

function FrameworkJobGangTests:test_esx_get_player_gang()
    -- Test: Get player gang in ESX
    -- Expected: Returns gang name and grade or (nil, 0) if not available
    local esx = require("enemyx.adapters.esx")
    local gang, grade = esx.GetPlayerGang(0) -- Using source 0 for testing
    self.tests["esx_get_player_gang"] = (type(gang) == "string" or gang == nil) and (type(grade) == "number" or grade == 0)
    print("[EnemyX Framework] Job and Gang: ESX Get Gang - " .. (self.tests["esx_get_player_gang"] and "PASS" or "FAIL"))
end

function FrameworkJobGangTests:test_qbcore_get_player_job()
    -- Test: Get player job in QBCore
    -- Expected: Returns job name and grade or (nil, 0) if not available
    local qbcore = require("enemyx.adapters.qbcore")
    local job, grade = qbcore.GetPlayerJob(0) -- Using source 0 for testing
    self.tests["qbcore_get_player_job"] = (type(job) == "string" or job == nil) and (type(grade) == "number" or grade == 0)
    print("[EnemyX Framework] Job and Gang: QBCore Get Job - " .. (self.tests["qbcore_get_player_job"] and "PASS" or "FAIL"))
end

function FrameworkJobGangTests:test_qbcore_get_player_gang()
    -- Test: Get player gang in QBCore
    -- Expected: Returns gang name and grade or (nil, 0) if not available
    local qbcore = require("enemyx.adapters.qbcore")
    local gang, grade = qbcore.GetPlayerGang(0) -- Using source 0 for testing
    self.tests["qbcore_get_player_gang"] = (type(gang) == "string" or gang == nil) and (type(grade) == "number" or grade == 0)
    print("[EnemyX Framework] Job and Gang: QBCore Get Gang - " .. (self.tests["qbcore_get_player_gang"] and "PASS" or "FAIL"))
end

function FrameworkJobGangTests:test_qbox_get_player_job()
    -- Test: Get player job in QBox
    -- Expected: Returns job name and grade or (nil, 0) if not available
    local qbox = require("enemyx.adapters.qbox")
    local job, grade = qbox.GetPlayerJob(0) -- Using source 0 for testing
    self.tests["qbox_get_player_job"] = (type(job) == "string" or job == nil) and (type(grade) == "number" or grade == 0)
    print("[EnemyX Framework] Job and Gang: QBox Get Job - " .. (self.tests["qbox_get_player_job"] and "PASS" or "FAIL"))
end

function FrameworkJobGangTests:test_qbox_get_player_gang()
    -- Test: Get player gang in QBox
    -- Expected: Returns gang name and grade or (nil, 0) if not available
    local qbox = require("enemyx.adapters.qbox")
    local gang, grade = qbox.GetPlayerGang(0) -- Using source 0 for testing
    self.tests["qbox_get_player_gang"] = (type(gang) == "string" or gang == nil) and (type(grade) == "number" or grade == 0)
    print("[EnemyX Framework] Job and Gang: QBox Get Gang - " .. (self.tests["qbox_get_player_gang"] and "PASS" or "FAIL"))
end

function FrameworkJobGangTests:test_vrp_get_player_job()
    -- Test: Get player job in vRP
    -- Expected: Returns job name and grade or (nil, 0) if not available
    local vrp = require("enemyx.adapters.vrp")
    local job, grade = vrp.GetPlayerJob(0) -- Using source 0 for testing
    self.tests["vrp_get_player_job"] = (type(job) == "string" or job == nil) and (type(grade) == "number" or grade == 0)
    print("[EnemyX Framework] Job and Gang: vRP Get Job - " .. (self.tests["vrp_get_player_job"] and "PASS" or "FAIL"))
end

function FrameworkJobGangTests:test_vrp_get_player_gang()
    -- Test: Get player gang in vRP
    -- Expected: Returns gang name and grade or (nil, 0) if not available
    local vrp = require("enemyx.adapters.vrp")
    local gang, grade = vrp.GetPlayerGang(0) -- Using source 0 for testing
    self.tests["vrp_get_player_gang"] = (type(gang) == "string" or gang == nil) and (type(grade) == "number" or grade == 0)
    print("[EnemyX Framework] Job and Gang: vRP Get Gang - " .. (self.tests["vrp_get_player_gang"] and "PASS" or "FAIL"))
end

function FrameworkJobGangTests:test_nd_get_player_job()
    -- Test: Get player job in ND
    -- Expected: Returns job name and grade or (nil, 0) if not available
    local nd = require("enemyx.adapters.nd")
    local job, grade = nd.GetPlayerJob(0) -- Using source 0 for testing
    self.tests["nd_get_player_job"] = (type(job) == "string" or job == nil) and (type(grade) == "number" or grade == 0)
    print("[EnemyX Framework] Job and Gang: ND Get Job - " .. (self.tests["nd_get_player_job"] and "PASS" or "FAIL"))
end

function FrameworkJobGangTests:test_nd_get_player_gang()
    -- Test: Get player gang in ND
    -- Expected: Returns gang name and grade or (nil, 0) if not available
    local nd = require("enemyx.adapters.nd")
    local gang, grade = nd.GetPlayerGang(0) -- Using source 0 for testing
    self.tests["nd_get_player_gang"] = (type(gang) == "string" or gang == nil) and (type(grade) == "number" or grade == 0)
    print("[EnemyX Framework] Job and Gang: ND Get Gang - " .. (self.tests["nd_get_player_gang"] and "PASS" or "FAIL"))
end

return FrameworkJobGangTests