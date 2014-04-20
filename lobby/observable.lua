Observable = LCS.class{}

function Observable:Init()
    self.listeners = {}
end

function Observable:AddListener(listener)
    table.insert(self.listeners, listener)
end

function Observable:RemoveListener(listener)
    for k, v in pairs(self.listeners) do
        if v == listener then
            table.remove(self.listeners, k)
            break
        end
    end
end

function Observable:CallListeners(func, ...)
    for i = 1, #self.listeners do
        local listener = self.listeners[i]
        args = {...}
        success, message = pcall(function()
            listener[func](listener, unpack(args))
        end)
        if not success then
            Spring.Echo("Error invoking listener: ", message)
        end
    end
end
