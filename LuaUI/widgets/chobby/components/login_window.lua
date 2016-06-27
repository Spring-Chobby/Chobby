LoginWindow = LCS.class{}

--TODO: make this a util function, maybe even add this support to chili as a whole?
function createTabGroup(ctrls)
	for i = 1, #ctrls do
		local ctrl1 = ctrls[i]
		local ctrl2 = ctrls[i + 1]
		if ctrl2 == nil then
			ctrl2 = ctrls[1]
		end

		if ctrl1.OnKeyPress == nil then
			ctrl1.OnKeyPress = {}
		end

		table.insert(ctrl1.OnKeyPress,
			function(obj, key, mods, ...)
				if key == Spring.GetKeyCode("tab") then
					screen0:FocusControl(ctrl2)
				end
			end
		)
	end
end

function LoginWindow:init()
	self.scale = 1.4 * Configuration:GetScale()
	self.fontSize = 14
	self.lblInstructions = Label:New {
		x = 1,
		width = 100 * self.scale,
		y = 20 * self.scale,
		height = 20 * self.scale,
		caption = i18n("connect_to_spring_server"),
		font = { size = self.scale * self.fontSize},
	}

	self.lblUsername = Label:New {
		x = 1,
		width = 100 * self.scale,
		y = 50 * self.scale,
		height = 20 * self.scale,
		caption = i18n("username") .. ":",
		font = { size = self.scale * self.fontSize},
	}
	self.ebUsername = EditBox:New {
		x = 80 * self.scale,
		width = 120 * self.scale,
		y = 50 * self.scale,
		height = 20 * self.scale,
		text = Configuration.userName,
		font = { size = self.scale * self.fontSize},
	}

	self.lblPassword = Label:New {
		x = 1,
		width = 100 * self.scale,
		y = 75 * self.scale,
		height = 20 * self.scale,
		caption = i18n("password") .. ":",
		font = { size = self.scale * self.fontSize},
	}
	self.ebPassword = EditBox:New {
		x = 80 * self.scale,
		width = 120 * self.scale,
		y = 75 * self.scale,
		height = 20 * self.scale,
		text = Configuration.password,
		passwordInput = true,
		font = { size = self.scale * self.fontSize},
		OnKeyPress = {
			function(obj, key, mods, ...)
				if key == Spring.GetKeyCode("enter") or 
					key == Spring.GetKeyCode("numpad_enter") then
					self:tryLogin()
				end
			end
		},
	}

	self.lblError = Label:New {
		x = 1,
		width = 100 * self.scale,
		y = 100 * self.scale,
		height = 55 * self.scale,
		caption = "",
		font = {
			color = { 1, 0, 0, 1 },
			size = self.fontSize * self.scale,
		},
	}

	self.cbAutoLogin = Checkbox:New {
		x = 1,
		width = 87 * self.scale,
		y = 125 * self.scale,
		height = 20 * self.scale,
		caption = i18n("autologin"),
		checked = Configuration.autoLogin,
		font = { size = self.scale * self.fontSize * 0.8},
	}

	self.btnLogin = Button:New {
		x = 1,
		width = 80 * self.scale,
		bottom = 1,
		height = 40 * self.scale,
		caption = i18n("login_verb"),
		font = { size = self.scale * self.fontSize},
		OnClick = {
			function()
				self:tryLogin()
			end
		},
	}

	self.btnRegister = Button:New {
		right = 1,
		width = 80 * self.scale,
		bottom = 1,
		height = 40 * self.scale,
		caption = i18n("register_verb"),
		font = { size = self.scale * self.fontSize},
		OnClick = {
			function()
				self:tryRegister()
			end
		},
	}

	local ww, wh = Spring.GetWindowGeometry()
	local w, h = math.floor(265 * self.scale), math.floor(220 * self.scale)
	self.window = Window:New {
		x = (ww - w) / 2,
		y = (wh - h) / 2,
		width = w,
		height = h,
		caption = i18n("login_noun"),
		resizable = false,
		draggable = false,
		children = {
			self.lblInstructions,
			self.lblUsername,
			self.lblPassword,
			self.ebUsername,
			self.ebPassword,
			self.lblError,
			self.cbAutoLogin,
			self.btnLogin,
			self.btnRegister
		},
		parent = screen0,
		OnDispose = {
			function()
				self:RemoveListeners()
			end
		},
	}

	createTabGroup({self.ebUsername, self.ebPassword})
	screen0:FocusControl(self.ebUsername)
	-- FIXME: this should probably be moved to the lobby wrapper
	self.loginAttempts = 0
	if self.cbAutoLogin.checked then
		self:tryLogin()
	end
end

function LoginWindow:RemoveListeners()
	if self.onAccepted then
		lobby:RemoveListener("OnAccepted", self.onAccepted)
		self.onAccepted = nil
	end
	if self.onDenied then
		lobby:RemoveListener("OnDenied", self.onDenied)
		self.onDenied = nil
	end
	if self.onAgreementEnd then
		lobby:RemoveListener("OnAgreementEnd", self.onAgreementEnd)
		self.onAgreementEnd = nil
	end
	if self.onAgreement then
		lobby:RemoveListener("OnAgreement", self.onAgreement)
		self.onAgreement = nil
	end
	if self.onTASServer then
		lobby:RemoveListener("OnTASServer", self.onTASServer)
		self.onTASServer = nil
	end
	if self.onDisconnected then
		lobby:RemoveListener("OnDisconnected", self.onDisconnected)
		self.onDisconnected = nil
	end
end

function LoginWindow:tryLogin()
	self.lblError:SetCaption("")
	
		
	username = self.ebUsername.text
	password = self.ebPassword.text
	if username == '' or password == '' then
		return
	end
	Configuration.userName  = username
	Configuration.password  = password
	Configuration.autoLogin = self.cbAutoLogin.checked
	--Configuration.autoLogin = true
	--Configuration:SaveConfig()

	if not lobby.connected or self.loginAttempts >= 3 then
		self.loginAttempts = 0
		self:RemoveListeners()

		self.onTASServer = function(listener)
			lobby:RemoveListener("OnTASServer", self.onTASServer)
			self:OnConnected(listener)
		end
		lobby:AddListener("OnTASServer", self.onTASServer)

		self.onDisconnected = function(listener)
			lobby:RemoveListener("OnDisconnected", self.onDisconnected)
			self.lblError:SetCaption("Cannot reach server:\n" .. tostring(Configuration:GetServerAddress()) .. ":" .. tostring(Configuration:GetServerPort()))
		end
		lobby:AddListener("OnDisconnected", self.onDisconnected)

		lobby:Connect(Configuration:GetServerAddress(), Configuration:GetServerPort())
	else
		lobby:Login(username, password, 3)
	end

	self.loginAttempts = self.loginAttempts + 1
end

function LoginWindow:tryRegister()
	self.lblError:SetCaption("")

	username = self.ebUsername.text
	password = self.ebPassword.text
	if username == '' or password == '' then
		return
	end

	if not lobby.connected or self.loginAttempts >= 3 then
		self.loginAttempts = 0
		self:RemoveListeners()

		self.onTASServerRegister = function(listener)
			lobby:RemoveListener("OnTASServer", self.onTASServerRegister)
			self:OnRegister(listener)
		end
		lobby:AddListener("OnTASServer", self.onTASServerRegister)

		lobby:Connect(Configuration:GetServerAddress(), Configuration:GetServerPort())
	else
		lobby:Register(username, password, "name@email.com")
	end

	self.loginAttempts = self.loginAttempts + 1
end

function LoginWindow:OnRegister()
	lobby:Register(username, password, "name@email.com")
	lobby:AddListener("OnRegistrationAccepted", function(listener)
		self.lblError:SetCaption("Registered!")
		--lobby:RemoveListener("OnRegistrationAccepted", listener)
	end)
	lobby:AddListener("OnRegistrationDenied", function(listener, err)
		self.lblError:SetCaption(err)
		--lobby:RemoveListener("OnRegistrationDenied", listener)
	end)

end

function LoginWindow:OnConnected()
	self.onDenied = function(listener, reason)
		self.lblError:SetCaption(reason)
	end

	self.onAccepted = function(listener)
		lobby:RemoveListener("OnAccepted", self.onAccepted)
		lobby:RemoveListener("OnDenied", self.onDenied)
		ChiliFX:AddFadeEffect({
			obj = self.window, 
			time = 0.2,
			endValue = 0,
			startValue = 1,
			after = function()
				self.window:Dispose()
				if not CHOBBY.chatWindows then
					ChatWindows()
				end
				if not CHOBBY.playWindow then
					PlayWindow()
				end
				if not CHOBBY.teamWindow then
					TeamWindow()
				end
			end,
		})
		channels = Configuration:GetChannels()
		for k, v in pairs(channels) do
			lobby:Join(v)
		end
	end

	lobby:AddListener("OnAccepted", self.onAccepted)
	lobby:AddListener("OnDenied", self.onDenied)

	self.onAgreement = function(listener, line)
		if self.agreementText == nil then
			self.agreementText = ""
		end
		self.agreementText = self.agreementText .. line .. "\n"
	end
	lobby:AddListener("OnAgreement", self.onAgreement)

	self.onAgreementEnd = function(listener)
		self:createAgreementWindow()
		lobby:RemoveListener("OnAgreementEnd", self.onAgreementEnd)
		lobby:RemoveListener("OnAgreement", self.onAgreement)
	end
	lobby:AddListener("OnAgreementEnd", self.onAgreementEnd)

	lobby:Login(username, password, 3)
end

function LoginWindow:createAgreementWindow()
	self.tbAgreement = TextBox:New {
		x = 1,
		right = 1,
		y = 1,
		height = "100%",
		text = self.agreementText,
		font = { size = self.scale * self.fontSize},
	}
	self.btnYes = Button:New {
		x = 1,
		width = 80 * self.scale,
		bottom = 1,
		height = 40 * self.scale,
		caption = "Accept",
		font = { size = self.scale * self.fontSize},
		OnClick = {
			function()
				self:acceptAgreement()
			end
		},
	}
	self.btnNo = Button:New {
		x = 150 * self.scale,
		width = 80 * self.scale,
		bottom = 1,
		height = 40 * self.scale,
		caption = "Decline",
		font = { size = self.scale * self.fontSize},
		OnClick = {
			function()
				self:declineAgreement()
			end
		},
	}
	self.agreementWindow = Window:New {
		x = 600,
		y = 200,
		width = 350 * self.scale,
		height = 450 * self.scale,
		caption = "Use agreement",
		resizable = false,
		draggable = false,
		children = {
			ScrollPanel:New {
				x = 1,
				right = 7,
				y = 1,
				bottom = 42 * self.scale,
				children = {
					self.tbAgreement
				},
			},
			self.btnYes,
			self.btnNo,

		},
		parent = screen0,
	}
end

function LoginWindow:acceptAgreement()
	lobby:ConfirmAgreement()
	self.agreementWindow:Dispose()
end

function LoginWindow:declineAgreement()
	lobby:Disconnect()
	self.agreementWindow:Dispose()
end
