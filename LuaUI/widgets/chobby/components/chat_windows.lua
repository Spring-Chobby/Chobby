ChatWindows = LCS.class{}

function ChatWindows:init()
    -- setup debug console to listen to commands

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
            self.debugConsole:AddMessage("<" .. command)
        end
    )
    lobby:AddListener("OnCommandSent",
        function(listner, command)
            self.debugConsole:AddMessage(">" .. command)
        end
    )

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

    self.channelConsoles = {}
    self.userListPanels = {}
    self.tabbars = {}
    lobby:AddListener("OnJoin",
        function(listener, chanName)
            local channelConsole = self:GetChannelConsole(chanName)
        end
    )

    -- channel chat
    lobby:AddListener("OnSaid", 
        function(listener, chanName, userName, message)
            local channelConsole = self.channelConsoles[chanName]
            if channelConsole ~= nil then
                channelConsole:AddMessage(message, userName)
            end
        end
    )
    lobby:AddListener("OnSaidEx", 
        function(listener, chanName, userName, message)
            local channelConsole = self.channelConsoles[chanName]
            if channelConsole ~= nil then
                channelConsole:AddMessage(message, userName, nil, "\255\0\139\139")
            end
        end
    )

    -- private chat
    self.privateChatConsoles = {}
    lobby:AddListener("OnSayPrivate",
        function(listener, userName, message)
            local privateChatConsole = self:GetPrivateChatConsole(userName)
            privateChatConsole:AddMessage(message, lobby:GetMyUserName())
        end
    )
    lobby:AddListener("OnSaidPrivate",
        function(listener, userName, message)
            if userName == 'Nightwatch' then
                local chanName, userName, msgDate, message = message:match('.-|(.+)|(.+)|(.+)|(.*)')
                local channelConsole = self:GetChannelConsole(chanName)
                if channelConsole ~= nil then
                    channelConsole:AddMessage(message, userName, msgDate)
                end
            else
                local privateChatConsole = self:GetPrivateChatConsole(userName)
                privateChatConsole:AddMessage(message, userName)
            end
        end
    )
    
			
	
    self.serverPanel = ScrollPanel:New {
        x = 0,
        right = 5,
        y = 0,
        height = "100%",
    }

    self.tabPanel = Chili.TabPanel:New {
        x = 0, 
        right = 0,
        y = 20, 
        bottom = 0,
        padding = {0, 0, 0, 0},
        tabs = {
            { name = i18n("server"), children = {self.serverPanel} },
            { name = i18n("debug"), children = {self.debugConsole.panel} },
        },
    }

    self.window = Window:New {
        right = 0,
        width = "39%",
        bottom = 0,
        height = 500,
        parent = screen0,
        caption = i18n("chat"),
        resizable = false,
        draggable = false,
        padding = {5, 0, 5, 0},
        children = {
            self.tabPanel,
            Button:New {
                caption = "-",
                width = 50,
                y = 10,
                right = 2,
                height = 40,
                OnClick = { function() self:Minimize() end },
            },
            Button:New {
				width = 60,
				y = 10,
				right = 112,
				height = 40,
				caption = i18n("join"),
				OnClick = { function()
					if self.joinWindow == nil then
						self:CreateJoinChannelWindow()
					end
				end },
			},
            Button:New {
				width = 60,
				y = 10,
				right = 52,
				height = 40,
				caption = i18n("close"),
				OnClick = { function() self:CloseChannel() end },
			},
        }
    }

    CHOBBY.chatWindows = self
    self:Minimize()
end

function ChatWindows:Minimize()
    ChiliFX:AddFadeEffect({
        obj = self.window, 
        time = 0.1,
        endValue = 0,
        startValue = 1,
        after = function()
            self.window:Hide()

            if not self.minimizeWindow then
            self.minimizedWindow = Window:New {
                right = 0,
                width = 120,
                bottom = 0,
                height = 60,
                parent = screen0,
                caption = "",
                resizable = false,
                draggable = false,
                borderThickness = 0,
                children = { 
                    Button:New {
                        caption = i18n("chat"),
                        x = 2,
                        right = 2,
                        height = 40,
                        OnClick = { function() self:Maximize() end },
                    },
                },
            }
            else
                self.minimizedWindow:Show()
            end

            self.window:Invalidate()
            self.window:AlignControl()
        end
    })
end

function ChatWindows:Maximize()
    self.window:Show()
    ChiliFX:AddFadeEffect({
        obj = self.window, 
        time = 0.1,
        endValue = 1,
        startValue = 0,
    })

    if self.minimizedWindow then
        self.minimizedWindow:Hide()
    end
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

function ChatWindows:GetChannelConsole(chanName)
    local channelConsole = self.channelConsoles[chanName]

    if channelConsole == nil then
        channelConsole = Console()
        self.channelConsoles[chanName] = channelConsole

        channelConsole.listener = function(message)
            lobby:Say(chanName, message)
        end

        local userListPanel = UserListPanel(chanName)
        self.userListPanels[chanName] = userListPanel

        self.tabPanel:AddTab({
            name = "#" .. chanName, 
            children = {
                Control:New {
                    x = 0, y = 0, right = 145, bottom = 0,
                    padding={0,0,0,0}, itemPadding={0,0,0,0}, itemMargin={0,0,0,0},
                    children = { channelConsole.panel, },
                },
                Control:New {
                    width = 144, y = 0, right = 0, bottom = 0,
                    padding={0,0,0,0}, itemPadding={0,0,0,0}, itemMargin={0,0,0,0},
                    children = { userListPanel.panel, },
                },
            }
        })
        self.tabbars[chanName] = self.tabPanel.children[#self.tabPanel.children]

        lobby:AddListener("OnClients", 
            function(listener, clientsChanName, clients)
                if chanName == clientsChanName then
                    Spring.Echo("Users in channel: " .. chanName, #lobby:GetChannel(chanName).users)
                end
            end
        )
    end

    return channelConsole
end

function ChatWindows:GetPrivateChatConsole(userName)
    local privateChatConsole = self.privateChatConsoles[userName]

    if privateChatConsole == nil then
        privateChatConsole = Console()
        self.privateChatConsoles[userName] = privateChatConsole
        self.tabbars[userName] = self.tabPanel.children[#self.tabPanel.children]

        privateChatConsole.listener = function(message)
            lobby:SayPrivate(userName, message)
        end

        self.tabPanel:AddTab({name = "@" .. userName, children = {privateChatConsole.panel}})
    end

    return privateChatConsole
end

function ChatWindows:CreateJoinChannelWindow()


	self.ebChannelName = EditBox:New {
		bottom = 50,
		height = 25,
		right = 50,
		text = "",
	}

    self.joinWindow = Window:New {
        right = 300,
        width = 150,
        bottom = 200,
        height = 100,
        parent = screen0,
        caption = i18n("channel"),
        resizable = false,
        draggable = false,
        padding = {5, 0, 5, 0},
        children = {
			self.ebChannelName,
            Button:New {
				width = 60,
                bottom = 4,
				right = 2,
				height = 40,
				caption = i18n("cancel"),
				OnClick = { function()
					self.joinWindow:Dispose()
					self.joinWindow = nil
				end },
			},
            Button:New {
                caption = i18n("join"),
                width = 60,
                bottom = 4,
                right = 65,
                height = 40,
                OnClick = { function()
					lobby:Join(self.ebChannelName.text)
					self.joinWindow:Dispose()
					self.joinWindow = nil
				end },
            },
        }
    }
    
    self.ebChannelName.OnKeyPress = {
        function(obj, key, mods, ...)
            if key == Spring.GetKeyCode("enter") or 
                key == Spring.GetKeyCode("numpad_enter") then
                
				lobby:Join(self.ebChannelName.text)
				self.joinWindow:Dispose()
				self.joinWindow = nil
            end

        end
    }

end

function ChatWindows:CloseChannel()
	Spring.Echo("CLOSE")
end
