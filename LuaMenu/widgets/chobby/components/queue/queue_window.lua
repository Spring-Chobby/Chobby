QueueWindow = LCS.class{}

function QueueWindow:init(queue)
	local joinedQueueTime = Spring.GetTimer()
	local lastUpdate = Spring.GetTimer()

	self.lblStatus = Label:New {
		x = 10,
		y = 25,
		width = 100,
		height = 100,
		caption = i18n("time_in_queue"),
		font = Configuration:GetFont(2),
		Update =
		function(...)
			Label.Update(self.lblStatus, ...)
			local currentTime = Spring.GetTimer()
			if Spring.DiffTimers(currentTime, lastUpdate) > 0.5 then
				local diff = math.floor(Spring.DiffTimers(currentTime, joinedQueueTime))
				lastUpdate = currentTime
				self.lblStatus:SetCaption(i18n("time_in_queue") .. ": " .. tostring(diff) .. "s")
			end
			self.lblStatus:RequestUpdate()
		end,
	}

	self.queueWindow = Window:New {
		caption = queue.title,
		x = 10,
		y = 520,
		width = 500,
		height = 100,
		parent = screen0,
		draggable = false,
		resizable = false,
		children = {
			self.lblStatus,
			Button:New {
				caption = Configuration:GetErrorColor() .. i18n("leave") .. "\b",
				bottom = 10,
				right = 5,
				width = 70,
				height = 45,
				OnClick = { function () lobby:LeaveQueue(queue.name) end },
			},
		},
		OnDispose = { function() self:RemoveListeners() end },
	}

	self.onReadyCheck = function(listener, name, responseTime)
		if name == queue.name then
			self:HideWindow()
			ReadyCheckWindow(queue, responseTime, self.queueWindow)
		end
	end
	lobby:AddListener("OnReadyCheck", self.onReadyCheck)

	self.onLeftQueue = function(listener, name, reason)
		if queue.name == name then
			self.queueWindow:Dispose()
		end
	end
	lobby:AddListener("OnLeftQueue", self.onLeftQueue)
end

function QueueWindow:RemoveListeners()
	lobby:RemoveListener("OnLeftQueue", self.onLeftQueue)
	lobby:RemoveListener("OnReadyCheck", self.onReadyCheck)
end

function QueueWindow:HideWindow()
	ChiliFX:AddFadeEffect({
		obj = self.queueWindow,
		time = 0.15,
		endValue = 0,
		startValue = 1,
		after = function()
			self.queueWindow:Hide()
		end
	})
end