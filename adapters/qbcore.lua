-- EnemyX QBCore Framework Adapter
-- Adapter for QBCore framework (also compatible with QBox)

-- Framework Interface Implementation
-- This adapter MUST implement the exact same interface as all other adapters
-- to ensure framework-agnostic behavior in EnemyX Core

local Framework = {}
Framework.__index = Framework

-- Framework name
function Framework.GetName()
    return "qbcore"
end

-- Framework availability check
function Framework.IsAvailable()
    -- Check if QBCore is running
    local success, core = pcall(function()
        return exports['qb-core']:GetCoreObject()
    end)
    return success and core ~= nil
end

-- Get player information
function Framework.GetPlayer(source)
    -- Get player Ped
    local ped = GetPlayerPed(source)
    return ped
end

function Framework.GetPlayerIdentifier(source)
    if not Framework.IsAvailable() then return "unknown" end
    local Player = exports['qb-core']:GetPlayer(source)
    if Player then
        -- QBCore uses citizenid as the primary identifier
        return Player.PlayerData.citizenid or "unknown"
    end
    return "unknown"
end

function Framework.GetPlayerJob(source)
    if not Framework.IsAvailable() then return nil, 0 end
    local Player = exports['qb-core']:GetPlayer(source)
    if Player and Player.PlayerData.job then
        return Player.PlayerData.job.name, Player.PlayerData.job.grade.level
    end
    return nil, 0
end

function Framework.GetPlayerGang(source)
    if not Framework.IsAvailable() then return nil, 0 end
    local Player = exports['qb-core']:GetPlayer(source)
    if Player and Player.PlayerData.gang then
        return Player.PlayerData.gang.name, Player.PlayerData.gang.grade.level
    end
    -- Fallback: return nil to indicate no gang
    return nil, 0
end

function Framework.HasPermission(source, permission)
    if not Framework.IsAvailable() then return false end
    local Player = exports['qb-core']:GetPlayer(source)
    if Player then
        -- Check for admin permissions
        local hasAdmin = Player.PlayerData.permission == "god" or Player.PlayerData.permission == "admin"
        -- Check for specific EnemyX permission
        local hasPerm = Player.PlayerData.permission == "enemyx.admin"
        return hasAdmin or hasPerm
    end
    return false
end

function Framework.Notify(source, message, type)
    if not Framework.IsAvailable() then return end
    local Player = exports['qb-core']:GetPlayer(source)
    if Player then
        -- Show as QBCore notification
        TriggerClientEvent('QBCore:Notify', source, message, type or "primary")
    end
    -- Also send as chat message
    TriggerClientEvent('chat:addMessage', source, {
        color = {255, 255, 0},
        args = {"[EnemyX]", message}
    })
end

-- Create an entity (ped or vehicle)
function Framework.CreateEntity(entityType, model, coords, networked)
    if not Framework.IsAvailable() then return nil end

    if entityType == "ped" then
        -- Validate model
        if not model or model == "" then
            model = "a_m_m_business_01"
        end

        -- Request model
        if not HasModelLoaded(GetHashKey(model)) then
            RequestModel(GetHashKey(model))
        end

        return {
            model = model,
            networked = networked or false
        }

    elseif entityType == "vehicle" then
        -- Validate model
        if not model or model == "" then
            model = "schafter2"
        end

        -- Request model
        if not HasModelLoaded(GetHashKey(model)) then
            RequestModel(GetHashKey(model))
        end

        return {
            model = model,
            networked = networked or false,
            color = math.random(0, 159)
        }
    end

    return nil
end

-- Delete an entity
function Framework.DeleteEntity(entity)
    if entity and entity.handle then
        DeleteEntity(entity.handle)
    end
end

-- Get entity coordinates
function Framework.GetEntityCoords(entity)
    if entity and entity.handle then
        return GetEntityCoords(entity.handle, true)
    end
    return nil
end

-- Set entity coordinates
function Framework.SetEntityCoords(entity, coords)
    if entity and entity.handle and coords then
        SetEntityCoords(entity.handle, coords.x, coords.y, coords.z, false, false, false, true)
    end
end

-- QBCore-specific helper functions

function Framework.GetPlayerMoney(source)
    if not Framework.IsAvailable() then return 0 end
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player then return 0 end
    return Player.PlayerData.money["cash"] or 0
end

function Framework.GetPlayerBank(source)
    if not Framework.IsAvailable() then return 0 end
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player then return 0 end
    return Player.PlayerData.money["bank"] or 0
end

function Framework.AddPlayerMoney(source, amount, account)
    if not Framework.IsAvailable() then return false end
    account = account or "cash"
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player then return false end
    Player.Functions.AddMoney(account, amount)
    return true
end

function Framework.RemovePlayerMoney(source, amount, account)
    if not Framework.IsAvailable() then return false end
    account = account or "cash"
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player then return false end
    Player.Functions.RemoveMoney(account, amount)
    return true
end

function Framework.IsPlayerInVehicle(source)
    if not Framework.IsAvailable() then return false end
    local ped = GetPlayerPed(source)
    return IsPedInAnyVehicle(ped, false)
end

function Framework.GetPlayerVehicle(source)
    if not Framework.IsAvailable() then return nil end
    local ped = GetPlayerPed(source)
    if IsPedInAnyVehicle(ped, false) then
        return GetVehiclePedIsIn(ped, false)
    end
    return nil
end

-- Framework.GetPlayer implementation
function Framework.GetPlayer(source)
    -- Get player Ped
    local ped = GetPlayerPed(source)
    return ped
end

-- Helper functions

function Framework.GetPlayerMoney2(source)
    if not Framework.IsAvailable() then return 0 end
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player then return 0 end
    return Player.PlayerData.money["cash"] or 0
end

-- Cleanup the framework adapter
function Framework.Cleanup()
    -- Nothing to clean up specifically
end

-- Return the framework object
return Framework