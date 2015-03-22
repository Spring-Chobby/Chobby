Chotify = LCS.class{}

function Chotify:init()
    self.enabled = true
    Spring.Log("Chotify", LOG.NOTICE, "Enabled: " .. tostring(self.enabled))

    self.notifications = {}
    self._idCounter = 0
end

function Chotify:Update()
    
end

function Chotify:CloseNotification(id)
    Spring.Echo("Close notification called: ", id)
    local notification = self.notifications[id]
    if notification == nil then
        return
    end
    Spring.Echo("Notification found")
    local window = notification.window
    ChiliFX:AddFadeEffect({
        obj = window, 
        time = 0.2,
        endValue = 0,
        startValue = 1,
        after = function()
            window:Dispose()
        end,
    })
    self.notifications[id] = nil
end

function Chotify:Post(obj)
    local title = obj.title or ""
    local body = obj.body or ""
    local icon = obj.icon or ""
    local time = obj.time or 5

    if not self.enabled then
        return
    end

    local id = self._idCounter
    self._idCounter = self._idCounter + 1

    local window = Chili.Window:New {
        right = 0,
        width = 300,
        y = 60,
        height = 100,
        caption = title,
        parent = Chili.Screen0,
        children = {
            Chili.Label:New {
                x = 0,
                right = 0,
                y = 0,
                bottom = 0,
                valign = 'center',
                align = 'center',
                caption = body,
            }
        },
        draggable = false,
        resizable = false,
    }
    local startTime = os.clock()
    local notification = {
        window = window,
        startTime = startTime,
        endTime = startTime + time,
        id = id,
    }
    self.notifications[id] = notification
    WG.Delay(function() self:CloseNotification(id) end, time)
    return id
end

function Chotify:Update(id, obj)
    local title = obj.title
    local body = obj.body
    local notification = self.notifications[id]
    if notification == nil then
        return
    end
    local window = notification.window
    if title ~= nil then
        window:SetCaption(title)
    end
    if body ~= nil then
        window.children[1]:SetCaption(body)
    end
end

function Chotify:Hide(id)
end

function Chotify:Show(id)
end

function Chotify:IsEnabled()
    return self.enabled
end

function Chotify:Enable()
    self.enabled = true
end

function Chotify:Disable()
    self.enabled = false
end

Chotify = Chotify()