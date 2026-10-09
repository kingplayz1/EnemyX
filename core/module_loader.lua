-- EnemyX Module Loader
-- Dynamically loads and manages EnemyX modules

local EnemyX = require 'shared/constants'
local Utils = require 'shared/utils'
local EventSystem = require 'core/events'
local ConfigLoader = require 'core/config_loader'

local ModuleLoader = {}
ModuleLoader.__index = ModuleLoader

-- Module loader state
ModuleLoader.Modules = {
    npc = false,
    behavior = false,
    vehicle = false,
    zone = false,
    director = false,
    admin = false
}

ModuleLoader.ModuleInstances = {}
ModuleLoader.LoadOrder = {
    "npc",
    "behavior",
    "vehicle",
    "zone",
    "director",
    "admin"
}

ModuleLoader.Dependencies = {
    npc = {},  -- No dependencies
    behavior = {"npc"},  -- Needs NPC module for ped creation
    vehicle = {"npc"},  -- Needs NPC for peds in vehicles
    zone = {"npc", "behavior"},  -- Spawns NPCs with behaviors
    director = {"zone", "npc"},  -- Uses zones and NPCs for encounters
    admin = {"npc", "behavior", "zone", "director"}  -- Admin panel needs all
}

-- Create a new module loader
function ModuleLoader:new(eventSystem, configLoader, entityManager)
    local self = setmetatable({}, ModuleLoader)
    self.eventSystem = eventSystem or EventSystem:new()
    self.configLoader = configLoader or ConfigLoader:new()
    self.entityManager = entityManager
    self.modules = {}  -- moduleName -> module instance
    self.loadedModules = {}  -- Track which modules are loaded
    self.initOrder = {}  -- Order modules were initialized

    return self
end

-- Load a module by name
function ModuleLoader:LoadModule(moduleName)
    if self.modules[moduleName] then
        return self.modules[moduleName]  -- Already loaded
    end

    -- Check dependencies
    local deps = self.Dependencies[moduleName] or {}
    for _, dep in ipairs(deps) do
        if not self.modules[dep] then
            error(("[EnemyX] Module %s depends on %s, which is not loaded"):format(
                moduleName, dep))
        end
    end

    local modulePath = string.format("modules/%s/main", moduleName)
    local success, module = pcall(function()
        return require(modulePath)
    end)

    if not success then
        error(("[EnemyX] Failed to load module %s: %s"):format(moduleName, tostring(module)))
    end

    -- Initialize module if it has an init function
    if type(module.Init) == "function" then
        local moduleInstance = module.Init({
            eventSystem = self.eventSystem,
            configLoader = self.configLoader,
            entityManager = self.entityManager,
            constants = EnemyX,
            utils = Utils
        })

        self.modules[moduleName] = moduleInstance
        self.loadedModules[moduleName] = true
        table.insert(self.initOrder, moduleName)

        -- Emit module loaded event
        self.eventSystem:emit(EnemyX.Events.MODULE_LOADED, {
            module = moduleName,
            instance = moduleInstance
        })

        print(("[EnemyX] Loaded module: %s"):format(moduleName))
        return moduleInstance
    else
        -- Module is just a table of functions/data
        self.modules[moduleName] = module
        self.loadedModules[moduleName] = true
        table.insert(self.initOrder, moduleName)

        self.eventSystem:emit(EnemyX.Events.MODULE_LOADED, {
            module = moduleName,
            instance = module
        })

        print(("[EnemyX] Loaded module: %s"):format(moduleName))
        return module
    end
end

-- Unload a module
function ModuleLoader:UnloadModule(moduleName)
    if not self.modules[moduleName] then
        return  -- Not loaded
    end

    -- Check if any modules depend on this one
    for modName, deps in pairs(self.Dependencies) do
        if self.modules[modName] then
            for _, dep in ipairs(deps) do
                if dep == moduleName then
                    error(("[EnemyX] Cannot unload %s: module %s depends on it"):format(
                        moduleName, modName))
                end
            end
        end
    end

    -- Call cleanup if exists
    if type(self.modules[moduleName].Cleanup) == "function" then
        self.modules[moduleName].Cleanup()
    end

    self.modules[moduleName] = nil
    self.loadedModules[moduleName] = nil

    -- Remove from init order
    for i = #self.initOrder, 1, -1 do
        if self.initOrder[i] == moduleName then
            table.remove(self.initOrder, i)
            break
        end
    end

    self.eventSystem:emit(EnemyX.Events.MODULE_UNLOADED, {
        module = moduleName
    })

    print(("[EnemyX] Unloaded module: %s"):format(moduleName))
end

-- Check if module is loaded
function ModuleLoader:IsLoaded(moduleName)
    return self.loadedModules[moduleName] == true
end

-- Get module instance
function ModuleLoader:GetModule(moduleName)
    return self.modules[moduleName]
end

-- Load all modules based on configuration
function ModuleLoader:LoadAllModules()
    local modulesToLoad = self.configLoader:Get("Modules.Enabled", self.LoadOrder)

    if type(modulesToLoad) == "string" then
        -- Single module as string
        modulesToLoad = {modulesToLoad}
    elseif type(modulesToLoad) ~= "table" then
        -- Use default load order
        modulesToLoad = self.LoadOrder
    end

    -- Load in dependency order
    local loaded = {}
    local function loadWithDeps(moduleName)
        if loaded[moduleName] then return end
        if not self.modules[moduleName] then
            -- Load dependencies first
            local deps = self.Dependencies[moduleName] or {}
            for _, dep in ipairs(deps) do
                loadWithDeps(dep)
            end
            self:LoadModule(moduleName)
        end
        loaded[moduleName] = true
    end

    for _, moduleName in ipairs(modulesToLoad) do
        loadWithDeps(moduleName)
    end
end

-- Start all loaded modules
function ModuleLoader:StartAll()
    for moduleName, moduleInstance in pairs(self.modules) do
        if type(moduleInstance.Start) == "function" then
            moduleInstance.Start()
            print(("[EnemyX] Started module: %s"):format(moduleName))
        end
    end
end

-- Stop all loaded modules
function ModuleLoader:StopAll()
    -- Stop in reverse order to respect dependencies
    for i = #self.initOrder, 1, -1 do
        local moduleName = self.initOrder[i]
        local moduleInstance = self.modules[moduleName]
        if moduleInstance and type(moduleInstance.Stop) == "function" then
            moduleInstance.Stop()
            print(("[EnemyX] Stopped module: %s"):format(moduleName))
        end
    end
end

-- Cleanup all modules
function ModuleLoader:CleanupAll()
    for moduleName, moduleInstance in pairs(self.modules) do
        if type(moduleInstance.Cleanup) == "function" then
            moduleInstance.Cleanup()
        end
    end
    self:StopAll()
    self.modules = {}
    self.loadedModules = {}
    self.initOrder = {}
end

-- Get loader status
function ModuleLoader:GetStatus()
    local status = {
        loaded = {},
        total = #self.LoadOrder,
        count = 0
    }

    for moduleName, loaded in pairs(self.loadedModules) do
        if loaded then
            table.insert(status.loaded, moduleName)
            status.count = status.count + 1
        end
    end

    return status
end

return ModuleLoader