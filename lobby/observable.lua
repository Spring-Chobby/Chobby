Observable = LCS.class{}

function Observable:Init()
    self.listeners = {}
end

function Observable:Register(event, listener)
    local eventListeners = self.listeners[event]
    if eventListeners == nil then
        eventListeners = {}
        self.listeners[event] = eventListeners
    end
    table.insert(eventListeners, listener)
end

function Observable:Unregister(event, listener)
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

function Observable:CallListeners(event, ...)
    if self.listeners[event] == nil then
        return nil -- no event listeners
    end
    local eventListeners = self.listeners[event]
    for i = 1, #eventListeners do
        local listener = eventListeners[i]
        args = {...}
        success, message = pcall(function()
            listener(listener, unpack(args))
        end)
        if not success then
            Spring.Echo("Error invoking listener: ", message)
        end
    end
    return true
end
