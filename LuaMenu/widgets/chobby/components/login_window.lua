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
					if ctrl2.classname == "editbox" then
-- 						ctrl2:Select(1, #ctrl2.text + 1)
						-- HACK
						ctrl2.selStart = 1
						ctrl2.selStartPhysical = 1
						ctrl2.selEnd = #ctrl2.text + 1
						ctrl2.selEndPhysical = #ctrl2.text + 1
					end
				end
			end
		)
	end
end

local function GetLobbyName()
	local version = Game.gameVersion or "$VERSION"
	-- try to extract version from .git
	if version == "$VERSION" then
		version = "git"

		local gitCommit = VFS.LoadFile(".git/refs/heads/master", VFS.MOD)
		-- FIXME: This will always be nil because Spring prevents us from accessing folders or files starting with a dot
		if gitCommit then
			version = version .. " - " .. tostring(gitCommit)
		end
	end
	return (Game.gameName or 'Chobby') .. " " .. version
end

function LoginWindow:init(failFunction, cancelText, windowClassname)

	if WG.Chobby.lobbyInterfaceHolder:GetChildByName("loginWindow") then
		Spring.Echo("Tried to spawn duplicate login window")
		return
	end

	self.CancelFunc = function ()
		self.window:Dispose()
		if failFunction then
			failFunction()
		end
	end

	self.AcceptFunc = function ()
		self:tryLogin()
	end

	self.lblInstructions = Label:New {
		x = 15,
		width = 170,
		y = 30,
		height = 35,
		caption = i18n("connect_to_spring_server"),
		font = Configuration:GetFont(3),
	}
	self.lblServerAddress = Label:New {
		x = 15,
		width = 170,
		y = 90,
		height = 35,
		caption = i18n("server") .. ":",
		font = Configuration:GetFont(3),
	}
	self.ebServerAddress = EditBox:New {
		x = 135,
		width = 125,
		y = 85,
		height = 35,
		text = Configuration.serverAddress,
		font = Configuration:GetFont(3),
	}
	self.ebServerPort = EditBox:New {
		x = 265,
		width = 70,
		y = 85,
		height = 35,
		text = tostring(Configuration.serverPort),
		font = Configuration:GetFont(3),
	}

	self.lblUsername = Label:New {
		x = 15,
		width = 170,
		y = 130,
		height = 35,
		caption = i18n("username") .. ":",
		font = Configuration:GetFont(3),
	}
	self.ebUsername = EditBox:New {
		x = 135,
		width = 200,
		y = 125,
		height = 35,
		text = Configuration.userName,
		font = Configuration:GetFont(3),
	}

	self.lblPassword = Label:New {
		x = 15,
		width = 170,
		y = 175,
		height = 35,
		caption = i18n("password") .. ":",
		font = Configuration:GetFont(3),
	}
	self.ebPassword = EditBox:New {
		x = 135,
		width = 200,
		y = 170,
		height = 35,
		text = Configuration.password,
		passwordInput = true,
		font = Configuration:GetFont(3),
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
		x = 15,
		right = 15,
		y = 265,
		height = 90,
		caption = "",
		font = Configuration:GetFont(4),
	}

	self.cbAutoLogin = Checkbox:New {
		x = 15,
		width = 190,
		y = 220,
		height = 35,
		boxalign = "right",
		boxsize = 15,
		caption = i18n("autoLogin"),
		checked = Configuration.autoLogin,
		font = Configuration:GetFont(2),
		OnClick = {function (obj)
			Configuration:SetConfigValue("autoLogin", obj.checked)
		end},
	}

	self.btnLogin = Button:New {
		x = 1,
		width = 130,
		bottom = 1,
		height = 70,
		caption = i18n("login_verb"),
		font = Configuration:GetFont(3),
		classname = "option_button",
		OnClick = {
			function()
				self.AcceptFunc()
			end
		},
	}

	self.btnRegister = Button:New {
		x = 137,
		width = 130,
		bottom = 1,
		height = 70,
		caption = i18n("register_verb"),
		font = Configuration:GetFont(3),
		classname = "option_button",
		OnClick = {
			function()
				self:tryRegister()
			end
		},
	}

	self.btnCancel = Button:New {
		right = 1,
		width = 130,
		bottom = 1,
		height = 70,
		caption = i18n(cancelText or "cancel"),
		font = Configuration:GetFont(3),
		classname = "negative_button",
		OnClick = {
			function()
				self.CancelFunc()
			end
		},
	}

	local ww, wh = Spring.GetWindowGeometry()
	local w, h = 430, 420
	self.window = Window:New {
		name = "loginWindow",
		x = (ww - w) / 2,
		y = (wh - h) / 2,
		width = w,
		height = h,
		caption = i18n("login_noun"),
		resizable = false,
		draggable = false,
		classname = windowClassname,
		children = {
			self.lblInstructions,
			self.lblServerAddress,
			self.lblUsername,
			self.lblPassword,
			self.ebServerAddress,
			self.ebServerPort,
			self.ebUsername,
			self.ebPassword,
			self.lblError,
			self.cbAutoLogin,
			self.btnLogin,
			self.btnRegister,
			self.btnCancel
		},
		parent = WG.Chobby.lobbyInterfaceHolder,
		OnDispose = {
			function()
				self:RemoveListeners()
			end
		},
		OnFocusUpdate = {
			function(obj)
				obj:BringToFront()
			end
		}
	}

	self.window:BringToFront()

	createTabGroup({self.ebServerAddress, self.ebServerPort, self.ebUsername, self.ebPassword})
	screen0:FocusControl(self.ebUsername)
	-- FIXME: this should probably be moved to the lobby wrapper
	self.loginAttempts = 0
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
	if self.onConnect then
		lobby:RemoveListener("OnConnect", self.onConnect)
		self.onConnect = nil
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
	Configuration.serverAddress = self.ebServerAddress.text
	Configuration.serverPort = self.ebServerPort.text
	Configuration.userName  = username
	Configuration.password  = password

	if not lobby.connected or self.loginAttempts >= 3 then
		self.loginAttempts = 0
		self:RemoveListeners()

		self.onConnect = function(listener)
			lobby:RemoveListener("OnConnect", self.onConnect)
			self:OnConnected(listener)
		end
		lobby:AddListener("OnConnect", self.onConnect)

		self.onDisconnected = function(listener)
			lobby:RemoveListener("OnDisconnected", self.onDisconnected)
			self.lblError:SetCaption(Configuration:GetErrorColor() .. "Cannot reach server:\n" .. tostring(Configuration:GetServerAddress()) .. ":" .. tostring(Configuration:GetServerPort()))
		end
		lobby:AddListener("OnDisconnected", self.onDisconnected)

		lobby:Connect(Configuration:GetServerAddress(), Configuration:GetServerPort())
	else
		lobby:Login(username, password, 3, nil, GetLobbyName())
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
	Configuration.serverAddress = self.ebServerAddress.text
	Configuration.serverPort = self.ebServerPort.text

	if not lobby.connected or self.loginAttempts >= 3 then
		self.loginAttempts = 0
		self:RemoveListeners()

		self.onConnectRegister = function(listener)
			lobby:RemoveListener("OnConnect", self.onConnectRegister)
			self:OnRegister(listener)
		end
		lobby:AddListener("OnConnect", self.onConnectRegister)

		lobby:Connect(Configuration:GetServerAddress(), Configuration:GetServerPort())
	else
		lobby:Register(username, password, "name@email.com")
	end

	self.loginAttempts = self.loginAttempts + 1
end

function LoginWindow:OnRegister()
	lobby:Register(username, password, "name@email.com")
	lobby:AddListener("OnRegistrationAccepted", function(listener)
		self.lblError:SetCaption(Configuration:GetSuccessColor() .. "Registered!")
		--lobby:RemoveListener("OnRegistrationAccepted", listener)
	end)
	lobby:AddListener("OnRegistrationDenied", function(listener, err)
		self.lblError:SetCaption(Configuration:GetErrorColor() .. (err or "Unknown Error"))
		--lobby:RemoveListener("OnRegistrationDenied", listener)
	end)

end

function LoginWindow:OnConnected()

	self.lblError:SetCaption(Configuration:GetPartialColor() .. i18n("connecting"))

	self.onDenied = function(listener, reason)
		self.lblError:SetCaption(Configuration:GetErrorColor() .. (reason or "Denied, unknown reason"))
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
			end,
		})
		for channelName, _ in pairs(Configuration:GetChannels()) do
			lobby:Join(channelName)
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

	lobby:Login(username, password, 3, nil, GetLobbyName())
end

function LoginWindow:createAgreementWindow()
	self.tbAgreement = TextBox:New {
		x = 1,
		right = 1,
		y = 1,
		height = "100%",
		text = self.agreementText,
		font = Configuration:GetFont(3),
	}
	self.btnYes = Button:New {
		x = 1,
		width = 135,
		bottom = 1,
		height = 70,
		caption = "Accept",
		font = Configuration:GetFont(3),
		OnClick = {
			function()
				self:acceptAgreement()
			end
		},
	}
	self.btnNo = Button:New {
		x = 240,
		width = 135,
		bottom = 1,
		height = 70,
		caption = "Decline",
		font = Configuration:GetFont(3),
		OnClick = {
			function()
				self:declineAgreement()
			end
		},
	}
	self.agreementWindow = Window:New {
		x = 600,
		y = 200,
		width = 350,
		height = 450,
		caption = "Use agreement",
		resizable = false,
		draggable = false,
		children = {
			ScrollPanel:New {
				x = 1,
				right = 7,
				y = 1,
				bottom = 42,
				children = {
					self.tbAgreement
				},
			},
			self.btnYes,
			self.btnNo,

		},
		parent = WG.Chobby.lobbyInterfaceHolder,
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
