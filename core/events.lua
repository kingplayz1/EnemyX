-- EnemyX Core Event System
-- Publish/Subscribe pattern for loose coupling between modules

local EventSystem = {}
EventSystem.__index = EventSystem

-- Create a new event system instance
function EventSystem:new()
    local self = setmetatable({}, EventSystem)
    self.listeners = {}  -- eventName -> {callback1, callback2, ...}
    self.onceListeners = {}  -- eventName -> {callback1, callback2, ...} (auto-remove after first call)
    return self
end

-- Subscribe to an event
-- @param eventName string - Name of the event to listen for
-- @param callback function - Function to call when event is emitted
-- @param once boolean - If true, listener is removed after first invocation
function EventSystem:on(eventName, callback, once)
    if type(eventName) ~= "string" then
        error("Event name must be a string")
    end
    if type(callback) ~= "function" then
        error("Callback must be a function")
    end

    local listeners = once and self.onceListeners or self.listeners
    if not listeners[eventName] then
        listeners[eventName] = {}
    end
    table.insert(listeners[eventName], callback)

    -- Return unsubscribe function
    return function()
        self:off(eventName, callback)
    end
end

-- Subscribe to an event that should only trigger once
function EventSystem:once(eventName, callback)
    return self:on(eventName, callback, true)
end

-- Unsubscribe from an event
-- @param eventName string - Name of the event
-- @param callback function - The callback to remove
function EventSystem:off(eventName, callback)
    if not eventName then
        -- Remove all listeners if no event specified
        self.listeners = {}
        self.onceListeners = {}
        return
    end

    local function removeFrom(listeners)
        if listeners[eventName] then
            for i = #listeners[eventName], 1, -1 do
                if listeners[eventName][i] == callback then
                    table.remove(listeners[eventName], i)
                end
            end
            -- Clean up empty event arrays
            if #listeners[eventName] == 0 then
                listeners[eventName] = nil
            end
        end
    end

    removeFrom(self.listeners)
    removeFrom(self.onceListeners)
end

-- Emit an event to all listeners
-- @param eventName string - Name of the event to emit
-- @param ... - Arguments to pass to listeners
function EventSystem:emit(eventName, ...)
    if type(eventName) ~= "string" then
        error("Event name must be a string")
    end

    -- Call regular listeners
    if self.listeners[eventName] then
        -- Iterate backwards to allow safe removal during iteration
        for i = #self.listeners[eventName], 1, -1 do
            local listener = self.listeners[eventName][i]
            if listener then
                listener(...)
            end
        end
    end

    -- Call and remove once listeners
    if self.onceListeners[eventName] then
        for i = #self.onceListeners[eventName], 1, -1 do
            local listener = self.onceListeners[eventName][i]
            if listener then
                listener(...)
            end
        end
        self.onceListeners[eventName] = nil  -- Remove all once listeners for this event
    end
end

-- Check if event has listeners
-- @param eventName string - Name of the event to check
-- @return boolean - True if event has listeners
function EventSystem:hasListeners(eventName)
    return (self.listeners[eventName] and #self.listeners[eventName] > 0) or
           (self.onceListeners[eventName] and #self.onceListeners[eventName] > 0)
end

-- Get listener count for event
-- @param eventName string - Name of the event
-- @return number - Number of listeners
function EventSystem:getListenerCount(eventName)
    local count = 0
    if self.listeners[eventName] then
        count = count + #self.listeners[eventName]
    end
    if self.onceListeners[eventName] then
        count = count + #self.onceListeners[eventName]
    end
    return count
end

-- Clear all listeners
function EventSystem:clear()
    self.listeners = {}
    self.onceListeners = {}
end

return EventSystem