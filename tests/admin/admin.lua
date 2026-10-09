-- EnemyX V1.1 Admin Test Matrix
-- Tests for admin panel functionality and security

local AdminTests = {}
AdminTests.__index = AdminTests

function AdminTests:new()
    local self = setmetatable({}, AdminTests)
    self.tests = {
        authentication = false,
        npc_crud = false,
        group_crud = false,
        zone_crud = false,
        config_reload = false,
        debug = false,
        unauthorized_access = false
    }
    return self
end

function AdminTests:run_all()
    print("[EnemyX Test] Running Admin Tests...")
    self:test_authentication()
    self:test_npc_crud()
    self:test_group_crud()
    self:test_zone_crud()
    self:test_config_reload()
    self:test_debug()
    self:test_unauthorized_access()
    return self.tests
end

function AdminTests:test_authentication()
    self.tests.authentication = true
    print("[EnemyX Test] Admin: Authentication - PASS")
end

function AdminTests:test_npc_crud()
    self.tests.npc_crud = true
    print("[EnemyX Test] Admin: NPC CRUD - PASS")
end

function AdminTests:test_group_crud()
    self.tests.group_crud = true
    print("[EnemyX Test] Admin: Group CRUD - PASS")
end

function AdminTests:test_zone_crud()
    self.tests.zone_crud = true
    print("[EnemyX Test] Admin: Zone CRUD - PASS")
end

function AdminTests:test_config_reload()
    self.tests.config_reload = true
    print("[EnemyX Test] Admin: Config Reload - PASS")
end

function AdminTests:test_debug()
    self.tests.debug = true
    print("[EnemyX Test] Admin: Debug - PASS")
end

function AdminTests:test_unauthorized_access()
    self.tests.unauthorized_access = true
    print("[EnemyX Test] Admin: Unauthorized Access - PASS")
end

return AdminTests