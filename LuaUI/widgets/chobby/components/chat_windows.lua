ChatWindows = LCS.class{}

function ChatWindows:init()
	self.channelConsoles = {}
	self.userListPanels = {}
	self.tabbars = {}
	self.currentTab = false
	self.storedCurrentTab = false
	self.totalNewMessages = 0
	
	self.visible = false

	-- setup debug console to listen to commands
	self:CreateDebugConsole()
	
	-- get a list of channels when login is done
	lobby:AddListener("OnLoginInfoEnd",
		function(listener)
			lobby:RemoveListener("OnLoginInfoEnd", listener)

			self.channels = {} -- list of known channels retrieved from OnChannel
			local onChannel = function(listener, chanName, userCount, topic)
				self.channels[chanName] = { userCount = userCount, topic = topic }
			end

			lobby:AddListener("OnChannel", onChannel)

			lobby:AddListener("OnEndOfChannels",
				function(listener)
					lobby:RemoveListener("OnEndOfChannels", listener)
					lobby:RemoveListener("OnChannel", onChannel)

					local channelsArray = {}
					for chanName, v in pairs(self.channels) do
						table.insert(channelsArray, { 
							chanName = chanName, 
							userCount = v.userCount, 
							topic = v.topic,
						})
					end
					table.sort(channelsArray, 
						function(a, b)
							return a.userCount > b.userCount
						end
					)
					self:UpdateChannels(channelsArray)
				end
			)

			lobby:Channels()
		end
	)

	lobby:AddListener("OnJoin",
		function(listener, chanName)
			local channelConsole = self:GetChannelConsole(chanName)
		end
	)

	lobby:AddListener("OnChannelTopic",
		function(listener, chanName, author, changedTime, topic)
			local channelConsole = self:GetChannelConsole(chanName)
			if channelConsole ~= nil then
				channelConsole:AddMessage(topic, nil, nil, "\255\0\139\139")
			end
		end
	)
	
	self.onJoined = function(listener, chanName, userName)
		if self.currentTab and self.userListPanels[self.currentTab] then
			self.userListPanels[self.currentTab]:OnJoined(userName)
		end
	end
	lobby:AddListener("OnJoined", self.onJoined)

	self.onLeft = function(listener, chanName, userName)
		if self.currentTab and self.userListPanels[self.currentTab] then
			self.userListPanels[self.currentTab]:OnLeft(userName)
		end
	end
	lobby:AddListener("OnLeft", self.onLeft)
	
	
	self.onClients = function(listener, chanName, clients)
		if self.currentTab and self.userListPanels[self.currentTab] then
			self.userListPanels[self.currentTab]:Update()
		end
	end
	lobby:AddListener("OnClients", self.onClients)

	local CHAT_EX_MENTION = "\255\255\0\0"
	local CHAT_EX_COLOR ="\255\0\139\139"
	local CHAT_MENTION ="\255\255\0\0"
	
	-- channel chat
	lobby:AddListener("OnSaid", 
		function(listener, chanName, userName, message, msgDate)
			self:ProcessChat(chanName, userName, message, msgDate, CHAT_MENTION)
		end
	)
	lobby:AddListener("OnSaidEx", 
		function(listener, chanName, userName, message, msgDate)
			self:ProcessChat(chanName, userName, message, msgDate, CHAT_EX_MENTION, CHAT_EX_COLOR)
		end
	)

	-- private chat
	self.privateChatConsoles = {}
	lobby:AddListener("OnSayPrivate",
		function(listener, userName, message, msgDate)
			local privateChatConsole = self:GetPrivateChatConsole(userName)
			privateChatConsole:AddMessage(message, lobby:GetMyUserName(), msgDate)
		end
	)
	lobby:AddListener("OnSaidPrivate",
		function(listener, userName, message, msgDate)
			if userName == 'Nightwatch' then
				local chanName, userName, msgDate, message = message:match('.-|(.+)|(.+)|(.+)|(.*)')
				local channelConsole = self:GetChannelConsole(chanName)
				if channelConsole ~= nil then
					channelConsole:AddMessage(message, userName, msgDate)
				end
			else
				local privateChatConsole = self:GetPrivateChatConsole(userName)
				privateChatConsole:AddMessage(message, userName, msgDate)
				self:_NotifyTab(userName, userName, "Private", message, "sounds/beep4.wav", 15)
			end
		end
	)
	lobby:AddListener("OnSaidPrivateEx",
		function(listener, userName, message, msgDate)
			local privateChatConsole = self:GetPrivateChatConsole(userName)
			privateChatConsole:AddMessage(message, userName, msgDate, "\255\0\139\139")
			self:_NotifyTab(userName, userName, "Private", message, "sounds/beep4.wav", 15)
		end
	)
	lobby:AddListener("OnRemoveUser",
		function(listener, userName)
			local privateChatConsole = self.privateChatConsoles[userName]
			if privateChatConsole ~= nil then
				privateChatConsole:AddMessage(userName .. " is now offline", nil, nil, "\255\0\139\139")
			end
		end
	)
	lobby:AddListener("OnAddUser",
		function(listener, userName)
			local privateChatConsole = self.privateChatConsoles[userName]
			if privateChatConsole ~= nil then
				privateChatConsole:AddMessage(userName .. " just got online", nil, nil, "\255\0\139\139")
			end
		end
	)

	self.serverPanel = ScrollPanel:New {
		x = 0,
		right = 5,
		y = 0,
		height = "100%",
	}

	self.tabPanel = Chili.DetachableTabPanel:New {
		x = 10, 
		right = 10,
		y = 0, 
		bottom = 10,
		padding = {0, 0, 0, 0},
		tabs = {
			[1] = (Configuration.debugMode and { name = "debug", caption = i18n("debug"), children = {self.debugConsole.panel} }) or nil,
			--{ name = "server", caption = i18n("server"), children = {self.serverPanel} },
		},
		OnTabChange = {
			function(obj, name)
				self.currentTab = name
				if self.userListPanels[self.currentTab] then
					self.userListPanels[self.currentTab]:Update()
				end
				local console = self.tabbars[name]
				if console then
					self.totalNewMessages = self.totalNewMessages - console.unreadMessages
					interfaceRoot.GetRightPanelHandler().SetActivity("chat", self.totalNewMessages)
					console.unreadMessages = 0
					self:SetTabBadge(name, "")
					self:SetTabActivation(name, false)
					WG.Delay(function()
						screen0:FocusControl(console.ebInputText)
					end, 0.01)
				end
			end
		}
	}
	self.tabPanel.tabBar:DisableHighlight()
	
	self.tabBarHolder = Control:New {
		name = "tabBarHolder",
		x = 0,
		y = 0,
		width = "100%",
		height = 50,
		resizable = false,
		draggable = false,
		padding = {10, 10, 0, 0},
		children = {
			self.tabPanel.tabBar
		}
	}
	
	self.joinButton = Button:New {
		x = 2000,
		y = 5,
		width = 30,
		height = 30,
		parent = self.tabBarHolder,
		caption = "+",
		OnClick = { 
			function()
				if self.joinWindow == nil then
					self:CreateJoinChannelWindow()
				end
			end
		},
	},
	
	self.tabBarHolder:BringToFront()
	
	self.chatWindow = Control:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		caption = i18n("chat"),
		resizable = false,
		draggable = false,
		padding = {5, 0, 5, 0},
		children = {
			self.tabPanel,
			self.tabBarHolder,
		},
	}
	
	self.window = Control:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		OnOrphan = {
			function (obj)
				self.storedCurrentTab = self.currentTab
				self.currentTab = false
				self.tabPanel.tabBar:DisableHighlight()
				self.visible = false
			end
		},
		OnParent = {
			function (obj)
				if self.storedCurrentTab then
					self.tabPanel:CallListeners(self.tabPanel.OnTabChange, self.storedCurrentTab)
				end
				self.tabPanel.tabBar:EnableHighlight()
				self.visible = true
			end
		},
	}
	
	self.loginButton = Button:New {
		x = "25%",
		y = "45%", 
		width = "50%", 
		height = "10%",
		caption = i18n("login_to_chat"),
		font = Configuration:GetFont(4),
		parent = self.window,
		OnClick = {function ()
				Spring.Echo("Login")
				WG.LoginPopup()
			end
		}
	}
	
	local function onConfigurationChange(listener, key, value)
		if key == "debugMode" then
			if value and not self.tabPanel:GetTab("debug") then
				self.ignoreTabClick = true
				self.tabPanel:AddTab(
					{ 
						name = "debug", 
						caption = i18n("debug"), 
						children = {self.debugConsole.panel}
					}
				)
				self.ignoreTabClick = false
				self:UpdateJoinPosition()
			end
			if (not value) and self.tabPanel:GetTab("debug") then
				self.tabPanel:RemoveTab("debug", false)
				self:UpdateJoinPosition()
			end
		end
	end
	Configuration:AddListener("OnConfigurationChange", onConfigurationChange)
	
	lobby:AddListener("OnDisconnected", function ()
			self.window:ClearChildren()
			self.window:AddChild(self.loginButton)
		end
	)
	
	lobby:AddListener("OnConnect", function ()
			self.window:ClearChildren()
			self.window:AddChild(self.chatWindow)
		end
	)
	
	self:ReattachTabHolder()
	self:UpdateJoinPosition()
end

function ChatWindows:CycleTab(direction)
	local selected = self.tabPanel.tabBar.selected
	local children = self.tabPanel.tabBar.children
	if not (selected and children) then
		return
	end
	selected = (selected + direction - 1)%(#children) + 1
	local child = children[selected]
	if not child then
		return
	end
	self.tabPanel.tabBar:Select(child.name)
end

function ChatWindows:ProcessChat(chanName, userName, message, msgDate, notifyColor, chatColor)
	local channelConsole = self.channelConsoles[chanName]
	if channelConsole ~= nil then
		local iAmMentioned = (string.find(message, lobby:GetMyUserName()) and userName ~= lobby:GetMyUserName())
		local chatColour = (iAmMentioned and notifyColor) or chatColor
		channelConsole:AddMessage(message, userName, msgDate, chatColour)
		if iAmMentioned then
			self:_NotifyTab(chanName, userName, chanName, true, message, "sounds/beep4.wav", 15)
		elseif Configuration.notifyForAllChat then
			self:_NotifyTab(chanName, userName, chanName, false)
		end
	end
end

function ChatWindows:ReattachTabHolder()
	if not self.chatWindow:GetChildByName(self.tabBarHolder.name) then
		self.chatWindow:AddChild(self.tabBarHolder)
	end
	self.tabBarHolder:SetPos(0,0)
	self.tabBarHolder:BringToFront()
	self.tabBarHolder._relativeBounds.right = 0
	self.tabBarHolder:UpdateClientArea(false)
	
	self.tabPanel._relativeBounds.top = 50
	self.tabPanel:UpdateClientArea(false)
	self.tabPanel:Invalidate()
end

function ChatWindows:SetTabHolderParent(newParent, newX, newY, newRight)
	if not newParent:GetChildByName(self.tabBarHolder.name) then
		newParent:AddChild(self.tabBarHolder)
	end
	self.tabBarHolder:SetPos(newX, newY)
	self.tabBarHolder:BringToFront()
	self.tabBarHolder._relativeBounds.right = newRight
	self.tabBarHolder:UpdateClientArea(false)
	
	self.tabPanel._relativeBounds.top = 15
	self.tabPanel:UpdateClientArea(false)
	self.tabPanel:Invalidate()
		
	self.tabPanel.OnTabClick = {
		function()
			if self.ignoreTabClick then
				return
			end
			local rightPanelHandler = interfaceRoot.GetRightPanelHandler()
			local control, index = rightPanelHandler.GetManagedControlByName(self.window.name)
			rightPanelHandler.OpenTab(index)
		end
	}
end

function ChatWindows:_GetTabBarItem(tabName)
	local tabbar = self.tabPanel.tabBar
	for i=1,#tabbar.children do
		local c = tabbar.children[i]
		if c.name == tabName then
			return c
		end
	end
end

function ChatWindows:SetTabActivation(tabName, activationLevel, outlineColor)
	local ctrl = self:_GetTabBarItem(tabName)
	if not ctrl then
		return
	end
	
	if activationLevel then
		if (ctrl.activationLevel or 0) > activationLevel then
			return
		end
		ctrl.font.outline = true
		ctrl.font.outlineWidth  = 30
		ctrl.font.outlineWeight = 30
		ctrl.font.outlineColor  = outlineColor
	else
		ctrl.font.outline = false
		ctrl.font.outlineColor = {0,0,0,1}
	end
	ctrl.activationLevel = activationLevel
	
	ctrl.font:Invalidate()
end

function ChatWindows:SetTabBadge(tabName, text)
	local ctrl = self:_GetTabBarItem(tabName)
	if not ctrl then
		Spring.Echo("SetTabBadge missing control", tabName, text)
		return
	end
	local badge = ctrl._badge
	if badge == nil then
		badge = Label:New {
			right = 2,
			width = 12,
			y = 2,
			height = 10,
			caption = Configuration:GetFont(1),
			font = { 
				Configuration:GetFont(1).size,
				outline = true,
				autoOutlineColor = false,
				outlineColor = { 0, 0, 0, 0.6 },
			},
		}
		ctrl._badge = badge
		ctrl:AddChild(badge)
	end

	badge:SetCaption(text)
end

function ChatWindows:_NotifyTab(tabName, userName, chanName, nameMentioned, message, sound, popupDuration)
	if tabName ~= self.currentTab then
		-- TODO: Fix naming of self.tabbars (these are consoles)
		local console = self.tabbars[tabName]
		local oldMessages = console.unreadMessages
		console.unreadMessages = console.unreadMessages + 1
		self:SetTabBadge(tabName, tostring(console.unreadMessages))
		self:SetTabActivation(tabName, (nameMentioned and 2) or 1, {1, 1, (nameMentioned and 0) or 1, 1})
		self.totalNewMessages = self.totalNewMessages + (console.unreadMessages - oldMessages)
		interfaceRoot.GetRightPanelHandler().SetActivity("chat", self.totalNewMessages)

		if nameMentioned then
			Chotify:Post({
				title = userName .. " in " .. chanName .. ":",
				body = message,
				sound = sound,
				time = popupDuration,
			})
		end
	end
end

function ChatWindows:SetParent(newParent)
	self.window:SetParent(newParent)
end

function ChatWindows:CreateDebugConsole()
	self.debugConsole = Console()
	table.insert(self.debugConsole.ebInputText.OnKeyPress,
		function(obj, key, ...)
			-- allow tabs for the debug window
			if key == 9 then
				obj:TextInput("\t")
			end
		end
	)
	self.debugConsole.listener = function(message)
		lobby:SendCustomCommand(message)
	end
	lobby:AddListener("OnCommandReceived",
		function(listner, command)
			Spring.Echo("Server", "<" .. command)
			self.debugConsole:AddMessage("<" .. command)
		end
	)
	lobby:AddListener("OnCommandSent",
		function(listner, command)
			Spring.Echo("Server", ">" .. command)
			self.debugConsole:AddMessage(">" .. command)
		end
	)
	self.tabbars["Debug"] = self.debugConsole
end

function ChatWindows:UpdateChannels(channelsArray)
	self.serverPanel:ClearChildren()

	self.serverPanel:AddChild(
		Label:New {
			x = 0,
			width = 100,
			y = 0,
			height = 20,
			caption = "#",
		}
	)
	self.serverPanel:AddChild(
		Label:New {
			x = 50,
			width = 100,
			y = 0,
			height = 20,
			caption = i18n("channel"),
		}
	)
	self.serverPanel:AddChild(
		Label:New {
			x = 130,
			width = 100,
			y = 0,
			height = 20,
			caption = i18n("topic") ,
		}
	)
	for i, channel in pairs(channelsArray) do
		self.serverPanel:AddChild(Control:New {
			x = 0,
			width = "100%",
			y = i * 50,
			height = 40,
			children = {
				Label:New {
					x = 0,
					width = 100,
					y = 5,
					height = 20,
					caption = channel.userCount,
				},
				Label:New {
					x = 50,
					width = 100,
					y = 5,
					height = 20,
					caption = channel.chanName,
				},
				Button:New {
					x = 130,
					width = 60,
					y = 0,
					height = 30,
					caption = i18n("join"),
					OnClick = {
						function()
							lobby:Join(channel.chanName)
						end
					},
				},
			}
		})
	end
end

function ChatWindows:UpdateJoinPosition()
	self.joinButton:SetPos(#self.tabPanel.tabBar.children * 70 + 10)
end

function ChatWindows:GetChannelConsole(chanName)
	local channelConsole = self.channelConsoles[chanName]

	if channelConsole == nil then
		channelConsole = Console(chanName)
		self.channelConsoles[chanName] = channelConsole

		channelConsole.listener = function(message)
			lobby:Say(chanName, message)
		end

		local userListPanel = UserListPanel(function() return lobby:GetChannel(chanName) end, 22)
		self.userListPanels[chanName] = userListPanel
		
		self.ignoreTabClick = true
		self.tabPanel:AddTab(
			{
				name = chanName,
				caption = "#" .. chanName,
				children = {
					Control:New {
						x = 0, y = 0, right = Configuration.userListWidth, bottom = 0,
						padding={0,0,0,0}, itemPadding={0,0,0,0}, itemMargin={0,0,0,0},
						children = { channelConsole.panel, },
					},
					Control:New {
						width = Configuration.userListWidth, y = 0, right = 0, bottom = 0,
						padding={0,0,0,7}, itemPadding={0,0,0,0}, itemMargin={0,0,0,0},
						children = { userListPanel.panel, },
					},
					Button:New {
						width = 24, height = 24, y = 5, right = Configuration.userListWidth + 18,
						caption = "x",
						OnClick = {
							function()
								self.channelConsoles[chanName] = nil
								lobby:Leave(chanName)
								self.tabPanel:RemoveTab(chanName)
								self:UpdateJoinPosition()
							end
						},
					},
				}
			}
		)
		self.ignoreTabClick = false
		self.tabbars[chanName] = channelConsole
		self:UpdateJoinPosition()
	end

	return channelConsole
end

function ChatWindows:GetPrivateChatConsole(userName)
	local privateChatConsole = self.privateChatConsoles[userName]

	if privateChatConsole == nil then
		privateChatConsole = Console(userName .. " messages")
		self.privateChatConsoles[userName] = privateChatConsole

		privateChatConsole.listener = function(message)
			lobby:SayPrivate(userName, message)
		end
		
		self.ignoreTabClick = true
		self.tabPanel:AddTab(
			{
				name = userName,
				caption = "@" .. userName,
				children = {
					privateChatConsole.panel,

					Button:New {
						width = 24, height = 24, y = 0, right = 2,
						caption = "x",
						OnClick = {
							function()
								self.privateChatConsoles[userName] = nil
								self.tabPanel:RemoveTab(userName)
								self:UpdateJoinPosition()
							end
						},
					}
				}
			}
		)
		self.ignoreTabClick = false
		self.tabbars[userName] = privateChatConsole
		
		self:UpdateJoinPosition()
	end

	return privateChatConsole
end

function ChatWindows:CreateJoinChannelWindow()
	local ebChannelName = EditBox:New {
		hint = "Channel",
		text = "",
	}

	local _JoinChannel = function()
		if ebChannelName.text ~= "" then
			lobby:Join(ebChannelName.text)
			-- TODO: we should focus the newly opened tab
		end
		self.joinWindow:Dispose()
		self.joinWindow = nil
	end

	self.joinWindow = Window:New {
		caption = i18n("join_channel"),
		name = "chatWindow",
		parent = screen0,
		x = "45%",
		y = "45%",
		width = 200,
		height = 180,
		resizable = false,
		children = {
			StackPanel:New {
				x = 0, y = 0,
				right = 0, bottom = 0,
				children = {
					ebChannelName,
					Button:New {
						caption = i18n("ok"),
						OnClick = { function()
							_JoinChannel()
						end},
					},
					Button:New {
						caption = i18n("cancel"),
						OnClick = { function()
							self.joinWindow:Dispose()
							self.joinWindow = nil
						end},
					},
				},
			}
		},
	}

	ebChannelName.OnKeyPress = {
		function(obj, key, mods, ...)
			if key == Spring.GetKeyCode("enter") or
				key == Spring.GetKeyCode("numpad_enter") then
				_JoinChannel()
			end
		end
	}
	screen0:FocusControl(ebChannelName)
end
