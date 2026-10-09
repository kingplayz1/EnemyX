-- EnemyX Standalone Framework Adapter
-- Adapter for native FiveM (Standalone) gameplay

-- Framework Interface Implementation
-- This adapter MUST implement the exact same interface as all other adapters
-- to ensure framework-agnostic behavior in EnemyX Core

local Framework = {}
Framework.__index = Framework

-- Framework name
function Framework.GetName()
    return "standalone"
end

-- Framework availability check
function Framework.IsAvailable()
    -- Standalone is always available since it's the native FiveM runtime
    return true
end

-- Get player information
function Framework.GetPlayer(source)
    -- Get player Ped
    local ped = GetPlayerPed(source)
    return ped
end

function Framework.GetPlayerIdentifier(source)
    -- Get the primary identifier (usually license)
    local identifiers = GetPlayerIdentifiers(source)
    for _, id in ipairs(identifiers) do
        if id:find("license:") then
            return id:sub(9)  -- Remove "license:" prefix
        end
    end
    -- Fallback to first identifier
    return identifiers[1] or "unknown"
end

function Framework.GetPlayerJob(source)
    -- Standalone FiveM doesn't have a job system by default
    -- Return nil to indicate no job
    return nil, 0
end

function Framework.GetPlayerGang(source)
    -- Standalone FiveM doesn't have a gang system by default
    -- Return nil to indicate no gang
    return nil, 0
end

function Framework.HasPermission(source, permission)
    -- In standalone, check for ACE permissions
    -- For basic implementation, allow if player has the permission
    local isAceAllowed = IsPlayerAceAllowed(source, "command.enemyxadmin")
    return isAceAllowed
end

function Framework.Notify(source, message, type)
    -- Send as chat message
    TriggerClientEvent('chat:addMessage', source, {
        color = {255, 255, 0},
        args = {"[EnemyX]", message}
    })
end

-- Create an entity (ped or vehicle)
function Framework.CreateEntity(entityType, model, coords, networked)
    if entityType == "ped" then
        -- Validate model
        if not model or model == "" then
            model = "a_m_m_business_01"
        end

        -- Return model info for entity manager to use
        return {
            model = model,
            networked = networked or false
        }

    elseif entityType == "vehicle" then
        -- Validate model
        if not model or model == "" then
            model = "schafter2"
        end

        -- Return model info
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
    -- In standalone, use DeleteEntity
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

-- Additional standalone-specific functions (exposed via the interface)

function Framework.IsPlayerTalking(source)
    return NetworkIsPlayerTalking(source)
end

function Framework.GetPlayerVehicle(source)
    local ped = GetPlayerPed(source)
    if IsPedInAnyVehicle(ped, false) then
        return GetVehiclePedIsIn(ped, false)
    end
    return nil
end

function Framework.GetPlayerAimTarget(source)
    local ped = GetPlayerPed(source)
    local _, target = GetEntityPlayerIsFreeAimingAt(source, ped)
    return target
end

function Framework.IsPlayerAiming(source)
    local ped = GetPlayerPed(source)
    return IsPedAimingFromCover(ped) or IsPedShooting(ped)
end

-- Cleanup the framework adapter
function Framework.Cleanup()
    -- Nothing to clean up for standalone
end

-- Return the framework object
return Framework