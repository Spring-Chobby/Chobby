Observable = LCS.class{}

local LOG_SECTION = "liblobby"

local function ShallowCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function Observable:Init()
    self.listeners = {}
end

function Observable:AddListener(event, listener)
    if listener == nil then
        Spring.Log(LOG_SECTION, LOG.ERROR, "Event: " .. tostring(event) .. ", listener cannot be nil")
        return
    end
    local eventListeners = self.listeners[event]
    if eventListeners == nil then
        eventListeners = {}
        self.listeners[event] = eventListeners
    end
    table.insert(eventListeners, listener)
end

function Observable:RemoveListener(event, listener)
    if self.listeners[event] then
        for k, v in pairs(self.listeners[event]) do
            if v == listener then
                table.remove(self.listeners[event], k)
                if #self.listeners[event] == 0 then
                    self.listeners[event] = nil
                end
                break
            end
        end
    end
end

function Observable:_CallListeners(event, ...)
    if self.listeners[event] == nil then
        return nil -- no event listeners
    end
    local eventListeners = ShallowCopy(self.listeners[event])
    for i = 1, #eventListeners do
        local listener = eventListeners[i]
        args = {...}
        xpcall(function() listener(listener, unpack(args)) end, 
            function(err) self:_PrintError(err) end )
    end
    return true
end

function Observable:_PrintError(err)
    Spring.Log(LOG_SECTION, LOG.ERROR, debug.traceback(err))
end
