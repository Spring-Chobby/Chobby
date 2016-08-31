ReadyCheckWindow = LCS.class{}

function ReadyCheckWindow:init(queue, responseTime, queueWindow)	
	self.queue = queue
	self.responseTime = responseTime
	self.queueWindow = queueWindow

	self.startTime = os.clock()
	self.readyCheckTime = math.floor(self.startTime + self.responseTime)

	self.sentResponse = false
	self.rejoinQueueOnDispose = false

	self:AddBackground()

	self.lblReadyCheck = Label:New {
		x = 80,
		y = 60,
		width = 100,
		height = 100,
		caption = i18n("time_to_respond") .. ": ",
		font = Configuration:GetFont(2),
		Update = function(...)
			Label.Update(self.lblReadyCheck, ...)
			self.currentTime = os.clock()
			if not self.sentResponse then
				if self.readyCheckTime <= self.currentTime then
					self:SendResponse("timeout")
					self.lblReadyCheck.x = 60
					self.lblReadyCheck:SetCaption(i18n("timeout_leaving_queue") .. "...")
					WG.Delay(function() self:Dispose() end, 3)
					return
				else
					local diff = math.floor(self.readyCheckTime - self.currentTime)
					self.lblReadyCheck:SetCaption(i18n("are_you_ready") .. "(" .. tostring(diff) .. i18n("seconds_short") .. ")")
				end
			end
			self.lblReadyCheck:RequestUpdate()
		end,
	}

	self.btnYes = Button:New {
		caption = i18n("yes_caps"),
		x = 10,
		y = 125,
		width = 100,
		height = 50,
		OnClick = { function()
			if self.sentResponse then
				return
			end
			self:SendResponse("ready")
			self.lblReadyCheck.x = 60
			self.lblReadyCheck:SetCaption(i18n("waiting_for_other_players") .. "...")
		end },
	}

	self.btnNo = Button:New {
		caption = i18n("no_caps"),
		right = 10,
		y = 125,
		width = 100,
		height = 50,
		OnClick = { function()
			if self.sentResponse then
				return
			end
			self:SendResponse("notready")
			self.lblReadyCheck.x = 60
			self.lblReadyCheck:SetCaption(i18n("not_ready_leaving_queue") .. "...")
			WG.Delay(function() self:Dispose() end, 2)
		end },
	}

	local sw, sh = Spring.GetWindowGeometry()
	local w, h = 350, 200
	self.window = Window:New {
		caption = queue.title,
		x = math.floor((sw - w) / 2),
		y = math.floor(math.max(0, (sh) / 2 - h)),
		width = w,
		height = h,
		parent = WG.Chobby.mainInterfaceHolder,
		draggable = false,
		resizable = false,
		children = {
			self.lblReadyCheck,
			self.btnYes,
			self.btnNo,
		},
		OnDispose = { function()
			if self.rejoinQueueOnDispose then
				self.queueWindow:Show()
			else
				self.queueWindow:Dispose()
			end
			self.sentTime = os.clock()
		end },
	}

	self.onReadyCheckResult = function(listener, name, result)
		if result == "pass" then
			self.lblReadyCheck.x = 60
			self.lblReadyCheck:SetCaption(i18n("game_starting_soon") .. "...")

			self.onConnectUser = function(listener, ip, port, engine, password)
				WG.Delay(function()
					local springURL = "spring://" .. lobby:GetMyUserName() .. ":" .. password .. "@" .. ip .. ":" .. port
					Spring.Echo(springURL)
					Spring.Restart(springURL, "")
					lobby:RemoveListener(self.onConnect)
				end, 3)
			end
			lobby:AddListener("OnConnectUser", self.onConnectUser)
		else
			self.lblReadyCheck.x = 60
			self.lblReadyCheck:SetCaption(i18n("failed_reconnecting_queue") .. "...")
			self.rejoinQueueOnDispose = true
			WG.Delay(function() self:Dispose() end, 1)
		end
		self.window:Invalidate()
	end

	lobby:AddListener("OnReadyCheckResult", self.onReadyCheckResult)
end

function ReadyCheckWindow:Dispose()
	ChiliFX:AddFadeEffect({
		obj = self.window, 
		time = 0.01,
		endValue = 0,
		startValue = 1,
		after = function()
			self.window:Dispose()
		end
	})
end

function ReadyCheckWindow:SendResponse(response, noResponseTime)
	noResponseTime = not not noResponseTime
	local responseTime = nil
	if not noResponseTime then
		responseTime = math.floor(self.currentTime - self.startTime)
	end
	self.sentResponse = true	
	lobby:ReadyCheckResponse(self.queue.name, response, responseTime)

	-- hide buttons
	self.btnYes:Hide()
	self.btnNo:Hide()
end

function ReadyCheckWindow:RemoveListeners()
	lobby:RemoveListener("OnReadyCheckResult", self.onReadyCheckResult)
end

function ReadyCheckWindow:AddBackground()
	self.background = Control:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		padding = {0,0,0,0},
		margin = {0,0,0,0},
		parent = WG.Chobby.mainInterfaceHolder,
		Draw = function()
			if not self.sentTime then
				local diff = os.clock() - self.startTime
				diff = math.min(0.1, diff) / 0.1

				gl.PushMatrix()
				gl.Color(0.5, 0.5, 0.5, 0.7 * diff)

				gl.BeginEnd(GL.QUADS,
					function()
						local w, h = Spring.GetScreenGeometry()

						gl.TexCoord(0, 1)
						gl.Vertex(0, 0)

						gl.TexCoord(0, 0)
						gl.Vertex(0, h)

						gl.TexCoord(1, 0)
						gl.Vertex(w, h)

						gl.TexCoord(1, 1)
						gl.Vertex(w, 0)
					end
				)
				gl.PopMatrix()
			else
				local diff = os.clock() - self.sentTime
				diff = math.min(0.1, diff) / 0.1
				if diff == 1 then
					self.background:Dispose()
				end

				gl.PushMatrix()
				gl.Color(0.5, 0.5, 0.5, 0.7 * (1 - diff))

				gl.BeginEnd(GL.QUADS,
					function()
						local w, h = Spring.GetScreenGeometry()

						gl.TexCoord(0, 1)
						gl.Vertex(0, 0)

						gl.TexCoord(0, 0)
						gl.Vertex(0, h)

						gl.TexCoord(1, 0)
						gl.Vertex(w, h)

						gl.TexCoord(1, 1)
						gl.Vertex(w, 0)
					end
				)
				gl.PopMatrix()
			end
		end,
	}
	self.background:SetLayer(1)
end