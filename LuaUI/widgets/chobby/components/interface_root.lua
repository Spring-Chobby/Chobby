function GetInterfaceRoot(optionsParent, mainWindowParent, fontFunction)
	
	local externalFunctions = {}
	
	local titleWidthRel = 28
	local panelWidthRel = 40
	
	local userStatusPanelWidth = 250
	
	local battleStatusWidth = 480
	local panelButtonsWidth = 500
	local panelButtonsHeight = 50
	local statusWindowGapSmall = 45
	
	local chatTabHolderRight = 200
	
	local titleHeight = 125
	local titleHeightSmall = 90
	local titleWidth = 360
	
	local mainButtonsWidth = 180
	local mainButtonsWidthSmall = 140
	
	local userStatusWidth = 225
	
	local imageFudge = 0
	
	local padding = 0
	
	-- Switch to single panel mode when below the minimum screen width
	local minScreenWidth = 1280
	
	local fullscreenMode = true
	local autodetectFullscreen = true
	
	-------------------------------------------------------------------
	-- Window structure
	-------------------------------------------------------------------
	local headingWindow = Control:New {
		x = 0,
		y = 0,
		width = titleWidth,
		height = titleHeight,
		name = "headingWindow",
		caption = "", -- Your Game Here
		parent = screen0,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		children = {}
	}
	local headingImage = Image:New {
		y = 0,
		x = 0,
		right = 0,
		bottom = 0,
		keepAspect = false,
		file = Configuration:GetHeadingImage(fullscreenMode),
		OnClick = { function()
			Spring.Echo("OpenURL: uncomment me in interface_root.lua")
			-- Uncomment me to try it!
			--Spring.OpenURL("https://gitter.im/Spring-Chobby/Chobby")
			--Spring.OpenURL("/home/gajop")
		end},
		parent = headingWindow,
	}
	
	--headingWindow:SetPosRelative("20%","20%","20%","20%")
	
	local mainStatusWindow = Control:New {
		x = titleWidth,
		y = 0,
		right = 0,
		height = titleHeight,
		name = "mainStatusWindow",
		caption = "", -- Status Window
		parent = screen0,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
	}
	
	local userStatusWindow = Control:New {
		y = 0,
		right = 0,
		bottom = panelButtonsHeight,
		width = userStatusWidth,
		height = "100%",
		padding = {0, 0, 0, 0},
		parent = mainStatusWindow,
		children = {
			WG.UserStatusPanel.GetControl(),
		}
	}
	
	local battleStatusHolder = Control:New {
		x = 0,
		y = 0,
		right = userStatusWidth,
		bottom = panelButtonsHeight,
		name = "battleStatusHolder",
		caption = "", -- Battle and MM Status Window
		parent = screen0,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		parent = mainStatusWindow,
		children = {
			WG.BattleStatusPanel.GetControl(),
		}
	}
	
	local mainWindow = Control:New {
		x = 0,
		y = titleHeight,
		width = (100 - panelWidthRel) .. "%",
		bottom = 0,
		name = "mainWindow",
		caption = "", -- Main Window
		parent = screen0,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		children = {}
	}
	local buttonsPlace = Control:New {
		x = padding,
		y = padding,
		width = mainButtonsWidth,
		bottom = padding,
		name = "buttonsPlace",
		parent = mainWindow,
		padding = {0, 0, 0, 0},
		children = {}
	}
	local mainButtons = Control:New {
		x = 0,
		y = 0,
		width = "100%",
		height = "100%",
		name = "mainButtons",
		caption = "", -- Main Buttons
		parent = buttonsPlace,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		children = {}
	}

	local IMAGE_TOP_BACKGROUND = "luaui/images/top-background.png"
	local topPartImage = Image:New {
		x = 0,
		y = 0,
		right = 0,
		height = titleHeight,
		file = IMAGE_TOP_BACKGROUND,
		parent = screen0,
		keepAspect = false,
		color = {1, 1, 1, 0.2},
	}
	
	--buttonsPlace._relativeBounds.bottom = 150
	--buttonsPlace._relativeBounds.right = 150
	--buttonsPlace:UpdateClientArea(false)
	
	local contentPlaceHolder = Control:New {
		x = mainButtonsWidth,
		y = padding,
		right = padding,
		bottom = padding,
		name = "contentPlaceHolder",
		caption = "", -- Content Place
		parent = mainWindow,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		children = {}
	}
	local contentPlace = Window:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		name = "contentPlace",
		caption = "", -- Content Place
		parent = contentPlaceHolder,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		children = {}
	}
	contentPlace:Hide()
	
	local panelButtonsHolder = Control:New {
		bottom = 0,
		right = 0,
		width = panelButtonsWidth,
		height = panelButtonsHeight,
		name = "panelButtonsHolder",
		parent = mainStatusWindow,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		children = {}
	}
	local panelButtons = Control:New {
		x = "0%",
		y = "0%",
		width = "100%",
		height = "100%",
		name = "panelButtons",
		caption = "", -- Panel Buttons
		parent = panelButtonsHolder,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		children = {}
	}
	
	local panelWindowHolder = Control:New {
		x = (100 - panelWidthRel) .. "%",
		y = titleHeight,
		right = 0,
		bottom = 0,
		name = "panelWindowHolder",
		caption = "", -- Panel Window
		parent = screen0,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		children = {}
	}
	local panelWindow = Window:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		name = "panelWindow",
		caption = "", -- Panel Window
		parent = panelWindowHolder,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		children = {}
	}
	panelWindow:Hide()
	
	-- Exit button
	local exitButton = Button:New {
		x = 0,
		bottom = 0,
		width = "100%",
		height = 70,
		caption = i18n("exit"),
		font = Configuration:GetFont(3),
		parent = mainButtons,
		OnClick = {
			function(self)
				-- TODO, add popup window to confirm exit.
				Spring.Echo("Quitting...")
				Spring.SendCommands("quitforce")
			end
		},
	}
	
	-------------------------------------------------------------------
	-- In-Window Handlers
	-------------------------------------------------------------------
	local chatWindows = ChatWindows()
	
	local rightPanelTabs = {
		{name = "chat", control = chatWindows.window},
		{name = "settings", control = WG.SettingsWindow.GetControl()},
		{name = "downloads", control = WG.DownloadWindow.GetControl()},
		{name = "friends", control = WG.FriendWindow.GetControl()},
	}
	
	local submenus = {
		{
			name = "singleplayer", 
			tabs = {
				{
					name = "skirmish", 
					control = WG.BattleRoomWindow.GetSingleplayerControl(),
					entryCheck = WG.BattleRoomWindow.SetSingleplayerGame,
				},
			}
		},
		{
			name = "multiplayer", 
			entryCheck = WG.MultiplayerEntryPopup,
			tabs = {
				{name = "matchmaking", control = QueueListWindow().window},
				{name = "custom", control = BattleListWindow().window},
			},
		},
	}
	
	local battleStatusPanelHandler = GetTabPanelHandler("myBattlePanel", battleStatusHolder, contentPlace, {})
	local rightPanelHandler = GetTabPanelHandler("panelTabs", panelButtons, panelWindow, rightPanelTabs)
	local mainWindowHandler = GetSubmenuHandler(mainButtons, contentPlace, submenus)
	
	local function RescaleMainWindow(newFontSize, newButtonHeight)
		mainWindowHandler.Rescale(newFontSize, newButtonHeight)
		exitButton:SetPos(nil, nil, nil, newButtonHeight)
		exitButton._relativeBounds.bottom = 0
		exitButton:UpdateClientArea()
		
		ButtonUtilities.SetFontSizeScale(exitButton, newFontSize)
	end
	
	battleStatusPanelHandler.Rescale(4, 70)
	rightPanelHandler.Rescale(2, 70)
	RescaleMainWindow(3, 70)
	
	local function UpdateChildLayout()
		if fullscreenMode then
			chatWindows:ReattachTabHolder()
			
			rightPanelHandler.UpdateLayout(panelWindow, false)
			if not contentPlace:IsEmpty() then
				local control, index = rightPanelHandler.GetManagedControlByName(contentPlace.children[1].name)
				if control then
					contentPlace:ClearChildren()
					contentPlace:SetVisibility(false)
					rightPanelHandler.OpenTab(index)
				end
			end
		else
			chatWindows:SetTabHolderParent(mainStatusWindow, 0, titleHeightSmall - panelButtonsHeight + imageFudge, chatTabHolderRight)
			
			rightPanelHandler.UpdateLayout(contentPlace, true)
			if contentPlace:IsEmpty() and not panelWindow:IsEmpty() then
				local panelChild = panelWindow.children[1]
				local control, index = rightPanelHandler.GetManagedControlByName(panelChild.name)
				rightPanelHandler.OpenTab(index)
			else
				panelWindow:ClearChildren()	
			end
		end
	end
	
	local function UpdatePanelLayout(newFullscreen)
		if newFullscreen == fullscreenMode then
			return
		end
		fullscreenMode = newFullscreen
		
		if fullscreenMode then
			RescaleMainWindow(3, 70)
		
			-- Make main buttons wider
			contentPlaceHolder:SetPos(mainButtonsWidth)
			contentPlaceHolder._relativeBounds.right = 0
			contentPlaceHolder:UpdateClientArea()
			
			buttonsPlace:SetPos(nil, nil, mainButtonsWidth)
			
			-- Move Panel Buttons
			mainButtons:RemoveChild(panelButtons)
			panelButtonsHolder:AddChild(panelButtons)
			
			panelButtons:SetPosRelative("0%","0%", "100%","100%")
			--mainButtons:SetPosRelative("0%","0%", nil,"100%")
			
			-- Make Main Window take up more space
			panelButtonsHolder:Show()
			panelWindowHolder:Show()
			
			mainWindow:SetPos(nil, titleHeight)
			mainWindow._relativeBounds.right = panelWidthRel .. "%"
			mainWindow._relativeBounds.bottom = 0
			mainWindow:UpdateClientArea()
			
			-- Align game title and status.
			headingWindow:SetPos(0, 0, titleWidth, titleHeight)
			mainStatusWindow:SetPos(titleWidth, nil, titleHeight, titleHeight)
			mainStatusWindow._relativeBounds.right = 0
			mainStatusWindow:UpdateClientArea()
			
			userStatusWindow._relativeBounds.bottom = panelButtonsHeight
			userStatusWindow:UpdateClientArea()
			
			battleStatusHolder._relativeBounds.bottom = panelButtonsHeight
			battleStatusHolder:UpdateClientArea()
			
			topPartImage:SetPos(nil, nil, nil, titleHeight + imageFudge)
		else
			rightPanelHandler.Rescale(2, 55)
			RescaleMainWindow(2, 55)
			
			-- Make main buttons thinner
			contentPlaceHolder:SetPos(mainButtonsWidthSmall)
			contentPlaceHolder._relativeBounds.right = 0
			contentPlaceHolder:UpdateClientArea()
			
			buttonsPlace:SetPos(nil, nil, mainButtonsWidthSmall)
			
			-- Move Panel Buttons
			panelButtonsHolder:RemoveChild(panelButtons)
			mainButtons:AddChild(panelButtons)
			
			panelButtons:SetPosRelative("0%","45%", "100%","50%")
			--mainButtons:SetPosRelative("0%","0%", nil,"50%")
			
			-- Make Main Window take up more space
			panelButtonsHolder:Hide()
			panelButtonsHolder:ClearChildren()
			if panelWindowHolder.visible then
				panelWindowHolder:Hide()
			end
			mainWindow:SetPos(nil, titleHeightSmall)
			mainWindow._relativeBounds.right = 0
			mainWindow._relativeBounds.bottom = 0
			mainWindow:UpdateClientArea()
			
			-- Align game title and status.
			headingWindow:SetPos(nil, nil, mainButtonsWidthSmall + padding, titleHeightSmall)
			mainStatusWindow:SetPos(mainButtonsWidthSmall, nil, titleHeightSmall, titleHeightSmall)
			mainStatusWindow._relativeBounds.right = 0
			mainStatusWindow:UpdateClientArea()
			
			userStatusWindow._relativeBounds.bottom = 0
			userStatusWindow:UpdateClientArea()
			
			battleStatusHolder._relativeBounds.bottom = statusWindowGapSmall
			battleStatusHolder:UpdateClientArea()
			
			topPartImage:SetPos(nil, nil, nil, titleHeightSmall + imageFudge)
		end
		
		headingImage.file = Configuration:GetHeadingImage(fullscreenMode)
		headingImage:Invalidate()
		
		UpdateChildLayout()
	end
	
	-------------------------------------------------------------------
	-- External Functions
	-------------------------------------------------------------------
	function externalFunctions.UpdateSizeMode(screenWidth, screenHeight)
		if autodetectFullscreen then	
			local newFullscreen = screenWidth > minScreenWidth
			UpdatePanelLayout(newFullscreen)
		end
	end
	
	function externalFunctions.SetPanelDisplayMode(newAutodetectFullscreen, newFullscreen)
		autodetectFullscreen = newAutodetectFullscreen
		local screenWidth, screenHeight = Spring.GetViewGeometry()
		if autodetectFullscreen then
			UpdatePanelLayout(screenWidth > minScreenWidth)
		else
			UpdatePanelLayout(newFullscreen)
		end
		
		-- Make all children request realign.
		screen0:Resize(screenWidth, screenHeight)
	end
	
	function externalFunctions.GetChatWindow()
		return chatWindows
	end
	
	function externalFunctions.GetContentPlace()
		return contentPlace
	end
	
	function externalFunctions.GetStatusWindow()
		return mainStatusWindow
	end
	
	function externalFunctions.GetMainWindowHandler()
		return mainWindowHandler
	end
	
	function externalFunctions.GetRightPanelHandler()
		return rightPanelHandler
	end
	
	function externalFunctions.GetBattleStatusWindowHandler()
		return battleStatusPanelHandler
	end
	
	function externalFunctions.GetDoublePanelMode()
		return fullscreenMode
	end
	
	function externalFunctions.KeyPressed(key, mods, isRepeat, label, unicode)
		if chatWindows.visible and key == Spring.GetKeyCode("tab") and mods.ctrl then
			if mods.shift then
				chatWindows:CycleTab(-1)
			else
				chatWindows:CycleTab(1)
			end
			return true
		end
		return false
	end
	
	-------------------------------------------------------------------
	-- Listening
	-------------------------------------------------------------------
	local function onConfigurationChange(listener, key, value)
		if key == "panel_layout" then
			if value == 1 then
				externalFunctions.SetPanelDisplayMode(true)
			elseif value == 2 then
				externalFunctions.SetPanelDisplayMode(false, true)
			elseif value == 3 then
				externalFunctions.SetPanelDisplayMode(false, false)
			end
		elseif key == "singleplayer_mode" then
			headingImage.file = Configuration:GetHeadingImage(fullscreenMode)
			headingImage:Invalidate()
		end
	end
	Configuration:AddListener("OnConfigurationChange", onConfigurationChange)		
	
	-------------------------------------------------------------------
	-- Initialization
	-------------------------------------------------------------------
	local screenWidth, screenHeight = Spring.GetWindowGeometry()
	
	externalFunctions.UpdateSizeMode(screenWidth, screenHeight)
	UpdateChildLayout()

	return externalFunctions
end

return GetInterfaceRoot
