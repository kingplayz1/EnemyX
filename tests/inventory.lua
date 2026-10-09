-- EnemyX V1.1 Inventory Script
-- Lists all public exports, events, NUI callbacks, framework functions, config entries, and entity lifecycle paths

local Inventory = {}
Inventory.__index = Inventory

function Inventory:new()
    local self = setmetatable({}, Inventory)
    return self
end

function Inventory:run()
    print("=" .. string.rep("=", 78))
    print("EnemyX V1.1 Inventory")
    print("=" .. string.rep("=", 78))
    print()

    self:inventory_exports()
    self:inventory_events()
    self:inventory_nui_callbacks()
    self:inventory_framework_functions()
    self:inventory_config_entries()
    self:inventory_entity_lifecycle()
end

function Inventory:inventory_exports()
    print("PUBLIC EXPORTS")
    print(string.rep("-", 20))
    -- Read fxmanifest.lua to get exports
    local fxmanifest = "E:/fivem_server/SERVERS/Standalone server/txData/FiveMBasicServerCFXDefault_C78E24.base/resources/enemyx/fxmanifest.lua"
    local content = self:_read_file(fxmanifest)
    if content then
        -- Extract exports block
        local exports_start = content:find("exports {")
        if exports_start then
            local exports_end = content:find("}", exports_start)
            local exports_block = content:sub(exports_start, exports_end)
            -- Extract each export line
            for export in exports_block:gmatch("'([^']+)'") do
                print("  - " .. export)
            end
        end
    end
    print()
end

function Inventory:inventory_events()
    print("EVENTS (from shared/constants.lua)")
    print(string.rep("-", 40))
    local constants_file = "E:/fivem_server/SERVERS/Standalone server/txData/FiveMBasicServerCFXDefault_C78E24.base/resources/enemyx/shared/constants.lua"
    local content = self:_read_file(constants_file)
    if content then
        -- Find the Events table
        local events_start = content:find("Events = {")
        if events_start then
            local events_end = content:find("}", events_start)
            local events_block = content:sub(events_start, events_end)
            -- Extract each event
            for event_line in events_block:gmatch("([%w_]+) = \"[%w_]+\"") do
                print("  - " .. event_line)
            end
        end
    end
    print()
end

function Inventory:inventory_nui_callbacks()
    print("NUI CALLBACKS (from admin module)")
    print(string.rep("-", 40))
    local admin_file = "E:/fivem_server/SERVERS/Standalone server/txData/FiveMBasicServerCFXDefault_C78E24.base/resources/enemyx/modules/admin/main.lua"
    local content = self:_read_file(admin_file)
    if content then
        -- Find all RegisterNUICallback lines
        for callback in content:gmatch("RegisterNUICallback%('([^']+)%'") do
            print("  - " .. callback)
        end
    end
    print()
end

function Inventory:inventory_framework_functions()
    print("FRAMEWORK ADAPTER FUNCTIONS (interface)")
    print(string.rep("-", 50))
    -- We know the interface from the adapters, but let's list one adapter as example
    local adapter_file = "E:/fivem_server/SERVERS/Standalone server/txData/FiveMBasicServerCFXDefault_C78E24.base/resources/enemyx/adapters/standalone.lua"
    local content = self:_read_file(adapter_file)
    if content then
        -- Extract function names (simplistic)
        for func in content:gmatch("function Framework%.([%w_]+)") do
            print("  - " .. func)
        end
    end
    print()
end

function Inventory:inventory_config_entries()
    print("CONFIGURATION ENTRIES (from config files)")
    print(string.rep("-", 50))
    local config_dir = "E:/fivem_server/SERVERS/Standalone server/txData/FiveMBasicServerCFXDefault_C78E24.base/resources/enemyx/config"
    local config_files = {"config.lua", "enemies.lua", "weapons.lua", "vehicles.lua", "groups.lua", "zones.lua", "encounters.lua"}
    for _, file in ipairs(config_files) do
        local path = config_dir .. "/" .. file
        local content = self:_read_file(path)
        if content then
            print("  " .. file .. ":")
            -- For simplicity, just show the top-level keys
            -- This is a very basic extraction
            for key in content:gmatch("([%w_]+) = {") do
                print("    - " .. key)
            end
        end
    end
    print()
end

function Inventory:inventory_entity_lifecycle()
    print("ENTITY LIFECYCLE PATHS")
    print(string.rep("-", 30))
    -- We'll look at entity_manager.lua and the handlers
    local files = {
        "core/entity_manager.lua",
        "server/npc_handler.lua",
        "client/npc_handler.lua",
        "server/zone_handler.lua",
        "client/zone_handler.lua"
    }
    for _, file in ipairs(files) do
        local path = "E:/fivem_server/SERVERS/Standalone server/txData/FiveMBasicServerCFXDefault_C78E24.base/resources/enemyx/" .. file
        local content = self:_read_file(path)
        if content then
            print("  " .. file .. ":")
            -- Look for functions that create/delete entities
            for func in content:gmatch("function [%w_]+:([%w_]+)") do
                if func:match("Create") or func:match("Delete") or func:match("Remove") or func:match("Spawn") then
                    print("    - " .. func)
                end
            end
        end
    end
    print()
end

function Inventory:_read_file(path)
    local file = io.open(path, "r")
    if not file then
        return nil
    end
    local content = file:read("*a")
    file:close()
    return content
end

return Inventory