-- EnemyX Utility Functions
-- Helper functions used across modules

local EnemyX = require 'shared/constants'

-- Vector3 math utilities
local Utils = {}

-- Create a vector3 from components
function Utils.Vector3(x, y, z)
    return vector3(x, y or 0, z or 0)
end

-- Calculate distance between two vector3s (2D or 3D)
function Utils.GetDistance(vec1, vec2, useZ)
    if useZ then
        return #(vec1 - vec2)
    else
        return math.sqrt(
            math.pow(vec1.x - vec2.x, 2) +
            math.pow(vec1.y - vec2.y, 2)
        )
    end
end

-- Check if point is inside circle
function Utils.IsInCircle(point, center, radius)
    return Utils.GetDistance(point, center, true) <= radius
end

-- Check if point is inside box (axis-aligned)
function Utils.IsInBox(point, center, sizeX, sizeY, heading)
    -- Convert to local space
    local dx = point.x - center.x
    local dy = point.y - center.y

    -- Rotate by negative heading to align box with axes
    local cosH = math.cos(math.rad(-heading))
    local sinH = math.sin(math.rad(-heading))

    local localX = dx * cosH - dy * sinH
    local localY = dx * sinH + dy * cosH

    -- Check bounds
    return math.abs(localX) <= sizeX/2 and
           math.abs(localY) <= sizeY/2
end

-- Get distance from point to box (returns negative if inside)
function Utils.GetDistanceToBox(point, center, sizeX, sizeY, heading)
    -- Convert to local space
    local dx = point.x - center.x
    local dy = point.y - center.y

    -- Rotate by negative heading to align box with axes
    local cosH = math.cos(math.rad(-heading))
    local sinH = math.sin(math.rad(-heading))

    local localX = dx * cosH - dy * sinH
    local localY = dx * sinH + dy * cosH

    -- Distance to box (negative if inside)
    local distX = math.max(0, math.abs(localX) - sizeX/2)
    local distY = math.max(0, math.abs(localY) - sizeY/2)
    return math.sqrt(distX*distX + distY*distY)
end

-- Check if point is inside polygon (using ray casting algorithm)
function Utils.IsInPolygon(point, polygon)
    local inside = false
    local j = #polygon

    for i = 1, #polygon do
        if ((polygon[i].y > point.y) ~= (polygon[j].y > point.y)) and
           (point.x < (polygon[j].x - polygon[i].x) * (point.y - polygon[i].y) /
            (polygon[j].y - polygon[i].y) + polygon[i].x) then
            inside = not inside
        end
        j = i
    end

    return inside
end

-- Get distance from point to polygon (returns negative if inside)
function Utils.GetDistanceToPolygon(point, polygon)
    -- If point is inside polygon, distance is negative
    if Utils.IsInPolygon(point, polygon) then
        -- Find minimum distance to any edge
        local minDist = math.huge
        local j = #polygon

        for i = 1, #polygon do
            local dist = Utils.GetDistanceToLineSegment(point, polygon[i], polygon[j])
            if dist < minDist then minDist = dist end
            j = i
        end
        return -minDist
    else
        -- Point is outside, find minimum distance to any edge
        local minDist = math.huge
        local j = #polygon

        for i = 1, #polygon do
            local dist = Utils.GetDistanceToLineSegment(point, polygon[i], polygon[j])
            if dist < minDist then minDist = dist end
            j = i
        end
        return minDist
    end
end

-- Get distance from point to line segment
function Utils.GetDistanceToLineSegment(point, lineStart, lineEnd)
    local dx = lineEnd.x - lineStart.x
    local dy = lineEnd.y - lineStart.y
    if dx == 0 and dy == 0 then
        -- Line segment is actually a point
        return Utils.GetDistance(point, lineStart, true)
    end

    local t = ((point.x - lineStart.x) * dx + (point.y - lineStart.y) * dy) /
              (dx * dx + dy * dy)
    t = math.max(0, math.min(1, t))

    local projection = vector3(
        lineStart.x + t * dx,
        lineStart.y + t * dy,
        lineStart.z  -- Assuming 2D for simplicity
    )

    return Utils.GetDistance(point, projection, true)
end

-- Deep copy table
function Utils.DeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[Utils.DeepCopy(orig_key)] = Utils.DeepCopy(orig_value)
        end
        setmetatable(copy, Utils.DeepCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- Merge two tables (non-recursive for performance)
function Utils.MergeTables(t1, t2)
    local result = {}
    for k, v in pairs(t1) do
        result[k] = v
    end
    for k, v in pairs(t2) do
        result[k] = v
    end
    return result
end

-- Format vector3 for logging/display
function Utils.FormatVector(vec)
    return string.format("%.2f, %.2f, %.2f", vec.x, vec.y, vec.z or 0)
end

-- Clamp value between min and max
function Utils.Clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

-- Lerp (linear interpolation)
function Utils.Lerp(a, b, t)
    return a + (b - a) * t
end

-- Round to decimal places
function Utils.Round(value, decimals)
    local mult = 10^(decimals or 0)
    return math.floor(value * mult + 0.5) / mult
end

-- Generate random ID
function Utils.GenerateID()
    return string.format("%08x", math.random(0xFFFFFFFF))
end

-- Validate table against schema (basic type checking)
function Utils.ValidateSchema(data, schema)
    for key, expectedType in pairs(schema) do
        if data[key] == nil then
            return false, string.format("Missing required field: %s", key)
        end

        local actualType = type(data[key])
        if actualType ~= expectedType then
            return false, string.format(
                "Field '%s' expected %s, got %s",
                key, expectedType, actualType
            )
        end
    end
    return true, "Valid"
end

-- Count keys in a table
function Utils.TableCount(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

return Utils