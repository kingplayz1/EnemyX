-- EnemyX Configuration Loader
-- Hybrid Lua + JSON configuration system

local EnemyX = require 'shared/constants'
local Utils = require 'shared/utils'

local ConfigLoader = {}
ConfigLoader.__index = ConfigLoader

-- Create a new config loader
function ConfigLoader:new(configPath)
    local self = setmetatable({}, ConfigLoader)
    self.configPath = configPath or "config"
    self.config = {}  -- Merged configuration
    self.fileTimestamps = {}  -- For hot-reload detection
    self.listeners = {}  -- Config change listeners
    self.defaults = {}   -- Default values
    self.schemas = {}    -- Validation schemas

    return self
end

-- Load all configuration files
function ConfigLoader:LoadAll()
    -- Load Lua configs first
    self:LoadLuaConfigs()

    -- Load JSON configs (overrides Lua)
    self:LoadJSONConfigs()

    -- Apply defaults
    self:ApplyDefaults()

    -- Validate against schemas
    self:ValidateConfig()

    return self.config
end

-- Load Lua configuration files
function ConfigLoader:LoadLuaConfigs()
    local luaFiles = {
        "config.lua",
        "enemies.lua",
        "weapons.lua",
        "vehicles.lua",
        "groups.lua",
        "zones.lua",
        "encounters.lua"
    }

    for _, filename in ipairs(luaFiles) do
        local filePath = string.format("%s/%s", self.configPath, filename)
        local chunk, err = loadfile(filePath)

        if chunk then
            local success, result = pcall(chunk)
            if success and type(result) == "table" then
                Utils.MergeTables(self.config, result)
                self:_trackFile(filePath)
            else
                print(("[EnemyX] Warning: Failed to load Lua config %s: %s"):format(
                    filename, tostring(result)))
            end
        else
            -- File doesn't exist, that's OK
            if err and not err:find("No such file or directory") then
                print(("[EnemyX] Warning: Error loading Lua config %s: %s"):format(
                    filename, err))
            end
        end
    end
end

-- Load JSON configuration files
function ConfigLoader:LoadJSONConfigs()
    local jsonDir = string.format("%s/json", self.configPath)

    -- Check if JSON directory exists
    local fileList = LoadResourceFile(GetCurrentResourceName(), string.format("%s/.dir", jsonDir))
    if not fileList then
        return  -- No JSON configs, that's fine
    end

    -- Common JSON config files
    local jsonFiles = {
        "enemies.json",
        "weapons.json",
        "vehicles.json",
        "groups.json",
        "zones.json",
        "encounters.json"
    }

    for _, filename in ipairs(jsonFiles) do
        local filePath = string.format("%s/%s", jsonDir, filename)
        local content = LoadResourceFile(GetCurrentResourceName(), filePath)

        if content then
            local success, result = pcall(function()
                return json.decode(content)
            end)

            if success and type(result) == "table" then
                Utils.MergeTables(self.config, result)
                self:_trackFile(filePath)
            else
                print(("[EnemyX] Warning: Failed to parse JSON config %s: %s"):format(
                    filename, tostring(result)))
            end
        end
        -- Silently ignore missing JSON files
    end
end

-- Track file timestamp for hot-reload detection
function ConfigLoader:_trackFile(filePath)
    -- In FiveM, we can't easily get file timestamps
    -- For now, we'll rely on manual reload commands
    -- In a real implementation with file system access, we'd store timestamps
end

-- Set default values for missing configuration
function ConfigLoader:ApplyDefaults()
    -- Ensure essential config sections exist
    if not self.config.Framework then
        self.config.Framework = "auto"  -- Auto-detect framework
    end

    if not self.config.Performance then
        self.config.Performance = {
            highDistance = EnemyX.Performance.HIGH_DISTANCE,
            mediumDistance = EnemyX.Performance.MEDIUM_DISTANCE,
            lowDistance = EnemyX.Performance.LOW_DISTANCE,
            updateRates = {
                high = EnemyX.UpdateRates.HIGH,
                medium = EnemyX.UpdateRates.MEDIUM,
                low = EnemyX.UpdateRates.LOW
            }
        }
    end

    if not self.config.AutoDirector then
        self.config.AutoDirector = {
            enabled = true,
            scanInterval = 5000,
            maxActiveEnemies = 30,
            encounterWeights = {
                patrol = 40,
                ambush = 20,
                convoy = 15,
                reinforcement = 10,
                sniper = 5
            }
        }
    end

    -- Ensure enemies config exists
    if not self.config.Enemies then
        self.config.Enemies = {}
    end

    -- Ensure zones config exists
    if not self.config.Zones then
        self.config.Zones = {}
    end

    -- Ensure behaviors config exists
    if not self.config.Behaviors then
        self.config.Behaviors = {}
    end
end

-- Validate configuration against schemas
function ConfigLoader:ValidateConfig()
    -- Validate Enemies config
    if self.config.Enemies then
        for enemyName, enemyConfig in pairs(self.config.Enemies) do
            local isValid, errMsg = Utils.ValidateSchema(enemyConfig, {
                label = "string",
                peds = "table",
                weapons = "table",
                armor = "number",
                health = "number",
                accuracy = "number",
                relationship = "string",
                combat = "table",
                weaponBehavior = "table"
            })

            if not isValid then
                print(("[EnemyX] Warning: Invalid enemy config '%s': %s"):format(
                    enemyName, errMsg))
            end
        end
    end

    -- Validate Zones config
    if self.config.Zones then
        for zoneName, zoneConfig in pairs(self.config.Zones) do
            local isValid, errMsg = Utils.ValidateSchema(zoneConfig, {
                type = "string",
                center = "table",  -- vector3
                radius = "number",  -- for circle
                spawn = "table"
            })

            if not isValid then
                print(("[EnemyX] Warning: Invalid zone config '%s': %s"):format(
                    zoneName, errMsg))
            end
        end
    end
end

-- Get configuration value with fallback
-- @param keyPath string - Dot-separated path (e.g., "Performance.highDistance")
-- @param default any - Default value if key not found
-- @return any - Configuration value
function ConfigLoader:Get(keyPath, default)
    if not keyPath then return default end

    local keys = {}
    for key in keyPath:gmatch("[^%.]+") do
        table.insert(keys, key)
    end

    local value = self.config
    for _, key in ipairs(keys) do
        if value == nil then
            return default
        end
        value = value[key]
    end

    if value == nil then
        return default
    end

    return value
end

-- Set configuration value
-- @param keyPath string - Dot-separated path
-- @param value any - Value to set
function ConfigLoader:Set(keyPath, value)
    if not keyPath then return end

    local keys = {}
    for key in keyPath:gmatch("[^%.]+") do
        table.insert(keys, key)
    end

    local target = self.config
    for i = 1, #keys - 1 do
        local key = keys[i]
        if target[key] == nil then
            target[key] = {}
        end
        target = target[key]
    end

    target[keys[#keys]] = value
end

-- Reload configuration (for hot-reload during development)
function ConfigLoader:Reload()
    print("[EnemyX] Reloading configuration...")
    local oldConfig = Utils.DeepCopy(self.config)
    self.config = {}
    self:LoadAll()

    -- Notify listeners of changes
    for _, listener in ipairs(self.listeners) do
        listener(self.config, oldConfig)
    end
end

-- Add configuration change listener
function ConfigLoader:OnChange(callback)
    table.insert(self.listeners, callback)

    -- Return unsubscribe function
    return function()
        for i = #self.listeners, 1, -1 do
            if self.listeners[i] == callback then
                table.remove(self.listeners, i)
                break
            end
        end
    end
end

-- Export configuration (for debugging)
function ConfigLoader:Dump()
    return Utils.DeepCopy(self.config)
end

-- Check if configuration has changed since last load
-- @return boolean - True if any config file changed
function ConfigLoader:HasChanged()
    -- Simplified: always return false for now
    -- In real implementation with file timestamps, compare timestamps
    return false
end

return ConfigLoader