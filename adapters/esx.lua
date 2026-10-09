-- EnemyX ESX Framework Adapter
-- Adapter for ESX framework

-- Framework Interface Implementation
-- This adapter MUST implement the exact same interface as all other adapters
-- to ensure framework-agnostic behavior in EnemyX Core

local Framework = {}
Framework.__index = Framework

-- Framework name
function Framework.GetName()
    return "esx"
end

-- Framework availability check
function Framework.IsAvailable()
    -- Check if ESX is running by trying to get the shared object
    -- Return false if not available
    local success, esx = pcall(function()
        return exports['es_extended']:getSharedObject()
    end)
    return success and esx ~= nil
end

-- Get player information
function Framework.GetPlayer(source)
    -- Get player Ped
    local ped = GetPlayerPed(source)
    return ped
end

function Framework.GetPlayerIdentifier(source)
    if not Framework.IsAvailable() then return "unknown" end
    local xPlayer = exports['es_extended']:getPlayerIdentifier(source)
    if xPlayer then
        -- Try to get license identifier
        for _, id in ipairs(xPlayer) do
            if id:find("license:") then
                return id:sub(9)  -- Remove "license:" prefix
            end
        end
    end
    return "unknown"
end

function Framework.GetPlayerJob(source)
    if not Framework.IsAvailable() then return nil, 0 end
    local xPlayer = exports['es_extended']:getPlayerData(source)
    if xPlayer and xPlayer.job then
        return xPlayer.job.name, xPlayer.job.grade
    end
    return nil, 0
end

function Framework.GetPlayerGang(source)
    if not Framework.IsAvailable() then return nil, 0 end
    -- ESX may have gang support via addons, but check first
    local xPlayer = exports['es_extended']:getPlayerData(source)
    if xPlayer and xPlayer.gang then
        return xPlayer.gang.name, xPlayer.gang.grade
    end
    -- Fallback: return nil to indicate no gang
    return nil, 0
end

function Framework.HasPermission(source, permission)
    if not Framework.IsAvailable() then return false end
    -- Check for ESX admin permissions
    local xPlayer = exports['es_extended']:getPlayerData(source)
    if xPlayer then
        -- Check if player is admin or has specific permission
        local isAdmin = (xPlayer.job.grade == 8 or xPlayer.job.grade == 9)  -- Example admin grades
        local hasPerm = xPlayer.permission and xPlayer.permission == "enemyx.admin"
        return isAdmin or hasPerm
    end
    return false
end

function Framework.Notify(source, message, type)
    if not Framework.IsAvailable() then return end
    local xPlayer = exports['es_extended']:getPlayerData(source)
    if xPlayer then
        -- Show as ESX notification
        xPlayer.showNotification(message)
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

-- ESX-specific helper functions

function Framework.GetPlayerMoney(source)
    if not Framework.IsAvailable() then return 0 end
    local xPlayer = exports['es_extended']:getPlayerData(source)
    if not xPlayer then return 0 end
    return xPlayer.money or 0
end

function Framework.GetPlayerBank(source)
    if not Framework.IsAvailable() then return 0 end
    local xPlayer = exports['es_extended']:getPlayerData(source)
    if not xPlayer then return 0 end
    return xPlayer.bank or 0
end

function Framework.AddPlayerMoney(source, amount)
    if not Framework.IsAvailable() then return false end
    local xPlayer = exports['es_extended']:getPlayerData(source)
    if not xPlayer then return false end
    xPlayer.addMoney(amount)
    return true
end

function Framework.RemovePlayerMoney(source, amount)
    if not Framework.IsAvailable() then return false end
    local xPlayer = exports['es_extended']:getPlayerData(source)
    if not xPlayer then return false end
    xPlayer.removeMoney(amount)
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
    local xPlayer = exports['es_extended']:getPlayerData(source)
    if not xPlayer then return 0 end
    return xPlayer.money or 0
end

-- Cleanup the framework adapter
function Framework.Cleanup()
    -- Nothing to clean up specifically
end

-- Return the framework object
return Framework