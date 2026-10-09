-- EnemyX ND Framework Adapter
-- Adapter for ND (NoPixel-inspired) framework

-- Framework Interface Implementation
-- This adapter MUST implement the exact same interface as all other adapters
-- to ensure framework-agnostic behavior in EnemyX Core

local Framework = {}
Framework.__index = Framework

-- Framework name
function Framework.GetName()
    return "nd"
end

-- Framework availability check
function Framework.IsAvailable()
    -- Check if ND is running
    local success, core = pcall(function()
        return exports['nd-core']:getSharedObject()
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
    local user_id = NDCore.getUserId(source)
    if not user_id then return "unknown" end
    -- Try to get identifiers from ND
    local identifiers = NDCore.getIdentifiers(user_id)
    if identifiers then
        for _, id in ipairs(identifiers) do
            if id:find("license:") then
                return id:sub(9)  -- Remove "license:" prefix
            end
        end
    end
    -- Fallback to user_id
    return tostring(user_id)
end

function Framework.GetPlayerJob(source)
    if not Framework.IsAvailable() then return nil, 0 end
    local user_id = NDCore.getUserId(source)
    if not user_id then return nil, 0 end
    local user = NDCore.getUser(user_id)
    if user and user.job then
        return user.job.name, user.job.grade or 0
    end
    return nil, 0
end

function Framework.GetPlayerGang(source)
    if not Framework.IsAvailable() then return nil, 0 end
    local user_id = NDCore.getUserId(source)
    if not user_id then return nil, 0 end
    local user = NDCore.getUser(user_id)
    if user and user.gang then
        return user.gang.name, user.gang.rank or 0
    end
    -- Fallback: return nil to indicate no gang
    return nil, 0
end

function Framework.HasPermission(source, permission)
    if not Framework.IsAvailable() then return false end
    local user_id = NDCore.getUserId(source)
    if not user_id then return false end
    local user = NDCore.getUser(user_id)
    if user then
        -- Check for admin permission level
        local hasAdmin = (user.permission_level or 0) >= 1
        -- Check specific permission
        local hasPerm = user.permissions and user.permissions["enemyx.admin"]
        return hasAdmin or hasPerm
    end
    return false
end

function Framework.Notify(source, message, type)
    if not Framework.IsAvailable() then return end
    local user_id = NDCore.getUserId(source)
    if not user_id then return end
    -- Show as ND notification
    TriggerClientEvent('mythic_notify:client:SendAlert', source, {
        type = type or 'inform',
        text = message
    })
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

-- ND-specific helper functions

function Framework.GetPlayerMoney(source)
    if not Framework.IsAvailable() then return 0 end
    local user_id = NDCore.getUserId(source)
    if not user_id then return 0 end
    local user = NDCore.getUser(user_id)
    if user and user.wallet then
        return user.wallet.amount or 0
    end
    return 0
end

function Framework.GetPlayerBank(source)
    if not Framework.IsAvailable() then return 0 end
    local user_id = NDCore.getUserId(source)
    if not user_id then return 0 end
    local user = NDCore.getUser(user_id)
    if user and user.bank then
        return user.bank.amount or 0
    end
    return 0
end

function Framework.AddPlayerMoney(source, amount)
    if not Framework.IsAvailable() then return false end
    -- ND may have specific money functions
    -- This is a placeholder - actual implementation depends on ND version
    return true
end

function Framework.RemovePlayerMoney(source, amount)
    if not Framework.IsAvailable() then return false end
    -- Placeholder implementation
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
    local user_id = NDCore.getUserId(source)
    if not user_id then return 0 end
    local user = NDCore.getUser(user_id)
    if user and user.wallet then
        return user.wallet.amount or 0
    end
    return 0
end

-- Cleanup the framework adapter
function Framework.Cleanup()
    -- Nothing to clean up specifically
end

-- Return the framework object
return Framework