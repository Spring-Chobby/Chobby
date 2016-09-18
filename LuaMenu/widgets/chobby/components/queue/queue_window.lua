QueueWindow = LCS.class{}

function QueueWindow:init(queueName)
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
		name = "queue_" .. queueName,
		caption = queueName,
		x = 10,
		y = 520,
		width = 500,
		height = 100,
		parent = WG.Chobby.lobbyInterfaceHolder,
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
				OnClick = { function () lobby:LeaveMatchMaking(queueName) end },
			},
		},
		OnDispose = { function() self:RemoveListeners() end },
	}

	self.onReadyCheck = function(listener, responseTime)
		if name == queueName then
			self:HideWindow()
			ReadyCheckWindow(queueName, responseTime, self.queueWindow)
		end
	end
	lobby:AddListener("OnMatchMakerReadyCheck", self.onReadyCheck)

	self.onLeftQueue = function(listener,  _, joinedQueueList)
		for i = 1, #joinedQueueList do
			if queueName == name then
				return
			end
		end
		self.queueWindow:Dispose()
	end
	lobby:AddListener("OnMatchMakerStatus", self.onLeftQueue)
end

function QueueWindow:RemoveListeners()
	lobby:RemoveListener("OnMatchMakerStatus", self.onLeftQueue)
	lobby:RemoveListener("OnMatchMakerReadyCheck", self.onReadyCheck)
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