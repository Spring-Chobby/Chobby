Observable = LCS.class{}

function Observable:Init()
    self.listeners = {}
end

function Observable:AddListener(event, listener)
    local eventListeners = self.listeners[event]
    if eventListeners == nil then
        eventListeners = {}
        self.listeners[event] = eventListeners
    end
    table.insert(eventListeners, listener)
end

function Observable:RemoveListener(event, listener)
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

function Observable:_CallListeners(event, ...)
    if self.listeners[event] == nil then
        return nil -- no event listeners
    end
    local eventListeners = self.listeners[event]
    for i = 1, #eventListeners do
        local listener = eventListeners[i]
        args = {...}
        xpcall(function() listener(listener, unpack(args)) end, 
            function(err) self:_PrintError(err) end )
    end
    return true
end

function Observable:_PrintError(err)
    Spring.Echo(debug.traceback())
end
