function GetInterfaceRoot(optionsParent, mainWindowParent, fontFunction)

	local externalFunctions = {}

	local globalKeyListener = false

	local titleWidthRel = 28
	local panelWidthRel = 40

	local userStatusPanelWidth = 250

	local battleStatusWidth = 480
	local panelButtonsWidth = 500
	local panelButtonsHeight = 42
	local statusWindowGapSmall = 44

	local chatTabHolderHeight = 50

	local battleStatusTopPadding = 20
	local battleStatusBottomPadding = 20
	local battleStatusLeftPadding = 30

	local smallStatusLeftPadding = 5
	local battleStatusTopPaddingSmall = 5

	local chatTabHolderRight = 0

	local titleHeight = 125
	local titleHeightSmall = 90
	local titleWidth = 360

	local mainButtonsWidth = 180
	local mainButtonsWidthSmall = 140

	local userStatusWidth = 225

	local imageFudge = 0

	local padding = 0

	local statusButtonWidth = 420
	local statusButtonWidthSmall = 310
	
	local topBarHeight = 50

	-- Switch to single panel mode when below the minimum screen width
	local minScreenWidth = 1280

	local gameRunning = false
	local showTopBar = false
	local doublePanelMode = true
	local autodetectDoublePanel = true

	local IMAGE_TOP_BACKGROUND = LUA_DIRNAME .. "images/top-background.png"

	local INVISIBLE_COLOR = {0, 0, 0, 0}
	local VISIBLE_COLOR = {1, 1, 1, 1}

	-------------------------------------------------------------------
	-- Window structure
	-------------------------------------------------------------------
	local ingameInterfaceHolder = Control:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		name = "ingameInterfaceHolder",
		parent = screen0,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		children = {},
		preserveChildrenOrder = true
	}
	ingameInterfaceHolder:Hide()
	
	local lobbyInterfaceHolder = Control:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		name = "lobbyInterfaceHolder",
		parent = screen0,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		children = {},
	}
	
	local mainInterfaceHolder = Window:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		name = "mainInterfaceHolder",
		parent = lobbyInterfaceHolder,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		children = {},
		preserveChildrenOrder = true
	}
	
	local topBarHolder = Control:New {
		x = 0,
		y = 0,
		right = 0,
		height = topBarHeight,
		name = "topBarHolder",
		parent = lobbyInterfaceHolder,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		children = {}
	}
	topBarHolder:Hide()
	
	local headingWindow = Control:New {
		x = 0,
		y = 0,
		width = titleWidth,
		height = titleHeight,
		name = "headingWindow",
		parent = mainInterfaceHolder,
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
		file = Configuration:GetHeadingImage(doublePanelMode),
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
		parent = mainInterfaceHolder,
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
		x = battleStatusLeftPadding,
		y = battleStatusTopPadding,
		right = userStatusWidth,
		bottom = battleStatusBottomPadding,
		name = "battleStatusHolder",
		caption = "", -- Battle and MM Status Window
		parent = mainInterfaceHolder,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		parent = mainStatusWindow,
	}

	local mainWindow = Control:New {
		x = 0,
		y = titleHeight,
		width = (100 - panelWidthRel) .. "%",
		bottom = 0,
		name = "mainWindow",
		caption = "", -- Main Window
		parent = mainInterfaceHolder,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		children = {}
	}
	local mainButtonsHolder = Control:New {
		x = padding,
		y = padding,
		width = mainButtonsWidth,
		bottom = padding,
		name = "mainButtonsHolder",
		parent = mainWindow,
		padding = {0, 0, 0, 0},
		children = {},
	}
	local mainButtons = Control:New {
		x = 0,
		y = 0,
		width = "100%",
		height = "100%",
		name = "mainButtons",
		caption = "", -- Main Buttons
		parent = mainButtonsHolder,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		children = {}
	}
	
	local topPartImage = Image:New {
		x = 0,
		y = 0,
		right = 0,
		height = titleHeight,
		file = IMAGE_TOP_BACKGROUND,
		parent = mainInterfaceHolder,
		keepAspect = false,
		color = {0.218, 0.23, 0.49, 0.25},
	}

	local mainButtonsImage = Image:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		file = IMAGE_TOP_BACKGROUND,
		parent = mainButtonsHolder,
		keepAspect = false,
		color = {0.218, 0.23, 0.49, 0.1},
	}

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
		parent = mainInterfaceHolder,
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

	local function ExitSpring()
		Spring.Echo("Quitting...")
		Spring.Quit()
	end

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
				ConfirmationPopup(ExitSpring, "Are you sure you want to quit?", nil, 315, 200)
			end
		},
	}

	local backgroundHolder = Background()
	
	-------------------------------------------------------------------
	-- In-Window Handlers
	-------------------------------------------------------------------
	local chatWindows = ChatWindows()
	local mainWindowHandler

	local function CleanMultiplayerState(notFromBackButton)
		if notFromBackButton then
			mainWindowHandler.SetBackAtMainMenu("multiplayer")
		end
		WG.BattleRoomWindow.LeaveBattle(true)
	end

	local rightPanelTabs = {
		{name = "chat", control = chatWindows.window},
		{name = "settings", control = WG.SettingsWindow.GetControl()},
		{name = "downloads", control = WG.DownloadWindow.GetControl()},
		{name = "friends", control = WG.FriendWindow.GetControl()},
	}

	local queueListWindow = QueueListWindow()
	local battleListWindow = BattleListWindow()

	local submenus = {
		{
			name = "singleplayer",
			tabs = Configuration:GetGameConfig(false, "singleplayerMenu.lua", Configuration.shortnameMap[Configuration.singleplayer_mode]) or {}
		},
		{
			name = "multiplayer",
			entryCheck = WG.MultiplayerEntryPopup,
			tabs = {
				{name = "matchmaking", control = queueListWindow.window},
				{name = "serverList", control = battleListWindow.window},
			},
			cleanupFunction = CleanMultiplayerState
		},
	}

	local battleStatusTabControls = {
		myBattle = WG.BattleStatusPanel.GetControl
	}

	local battleStatusPanelHandler = GetTabPanelHandler("myBattlePanel", battleStatusHolder, contentPlace, {}, nil, nil, nil, nil, statusButtonWidth, battleStatusTabControls)
	local rightPanelHandler = GetTabPanelHandler("panelTabs", panelButtons, panelWindow, rightPanelTabs)
	mainWindowHandler = GetSubmenuHandler(mainButtons, contentPlace, submenus)

	-------------------------------------------------------------------
	-- Resizing functions
	-------------------------------------------------------------------

	local function RescaleMainWindow(newFontSize, newButtonHeight)
		mainWindowHandler.Rescale(newFontSize, newButtonHeight)
		exitButton:SetPos(nil, nil, nil, newButtonHeight)

		ButtonUtilities.SetFontSizeScale(exitButton, newFontSize)
	end

	local function UpdateChildLayout()
		if doublePanelMode then
			chatWindows:ReattachTabHolder()

			rightPanelHandler.UpdateLayout(panelWindow, false)
			if not contentPlace:IsEmpty() then
				local control, index = rightPanelHandler.GetManagedControlByName(contentPlace.children[1].name)
				if control then
					contentPlace:ClearChildren()
					contentPlace:SetVisibility(false)
					rightPanelHandler.OpenTab(index)
				elseif panelWindow.visible then
					panelWindow:Hide()
				end
			elseif panelWindow.visible then
				panelWindow:Hide()
			end

		else
			chatWindows:SetTabHolderParent(mainStatusWindow, smallStatusLeftPadding, titleHeightSmall - chatTabHolderHeight + imageFudge, chatTabHolderRight)

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
	
	local function UpdateDoublePanel(newDoublePanel)
		if newDoublePanel == doublePanelMode then
			return
		end
		doublePanelMode = newDoublePanel
		
		if doublePanelMode then
			battleStatusPanelHandler.Rescale(3, nil, statusButtonWidth)
			RescaleMainWindow(3, 70)

			-- Make main buttons wider
			contentPlaceHolder:SetPos(mainButtonsWidth)
			contentPlaceHolder._relativeBounds.right = 0
			contentPlaceHolder:UpdateClientArea()

			--contentPlace.color = VISIBLE_COLOR

			mainButtonsHolder:SetPos(nil, nil, mainButtonsWidth)

			-- Move Panel Buttons
			mainButtons:RemoveChild(panelButtons)
			panelButtonsHolder:AddChild(panelButtons)

			panelButtons:SetPosRelative("0%","0%", "100%","100%")
			--mainButtons:SetPosRelative("0%","0%", nil,"100%")

			-- Make Main Window take up more space
			panelButtonsHolder:Show()
			panelWindowHolder:Show()
			panelWindowHolder:SetPos(nil, titleHeight)

			mainWindow:SetPos(nil, titleHeight)
			mainWindow._relativeBounds.right = panelWidthRel .. "%"
			mainWindow._relativeBounds.bottom = 0
			mainWindow:UpdateClientArea()

			-- Align game title and status.
			headingWindow:SetPos(0, 0, titleWidth, titleHeight)
			mainStatusWindow:SetPos(titleWidth, 0, titleHeight, titleHeight)
			mainStatusWindow._relativeBounds.right = 0
			mainStatusWindow:UpdateClientArea()

			userStatusWindow._relativeBounds.bottom = panelButtonsHeight
			userStatusWindow:UpdateClientArea()

			battleStatusHolder:SetPos(battleStatusLeftPadding, battleStatusTopPadding)
			battleStatusHolder._relativeBounds.bottom = battleStatusBottomPadding
			battleStatusHolder:UpdateClientArea()

			topPartImage:SetPos(nil, nil, nil, titleHeight + imageFudge)
		else
			rightPanelHandler.Rescale(2, 55)
			battleStatusPanelHandler.Rescale(3, nil, statusButtonWidthSmall)
			RescaleMainWindow(2, 55)

			-- Make main buttons thinner
			contentPlaceHolder:SetPos(mainButtonsWidthSmall)
			contentPlaceHolder._relativeBounds.right = 0
			contentPlaceHolder:UpdateClientArea()

			--contentPlace.color = INVISIBLE_COLOR

			mainButtonsHolder:SetPos(nil, nil, mainButtonsWidthSmall)

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
			headingWindow:SetPos(0, 0, mainButtonsWidthSmall + padding, titleHeightSmall)
			mainStatusWindow:SetPos(mainButtonsWidthSmall, 0, titleHeightSmall, titleHeightSmall)
			mainStatusWindow._relativeBounds.right = 0
			mainStatusWindow:UpdateClientArea()

			userStatusWindow._relativeBounds.bottom = 0
			userStatusWindow:UpdateClientArea()

			battleStatusHolder:SetPos(smallStatusLeftPadding, battleStatusTopPaddingSmall)
			battleStatusHolder._relativeBounds.bottom = statusWindowGapSmall
			battleStatusHolder:UpdateClientArea()

			topPartImage:SetPos(nil, nil, nil, titleHeightSmall + imageFudge)
		end

		headingImage.file = Configuration:GetHeadingImage(doublePanelMode)
		headingImage:Invalidate()

		UpdateChildLayout()
	end

	local function UpdatePadding(screenWidth, screenHeight)
		local leftPad, rightPad, bottomPad, middlePad
		if screenWidth < 1366 or (not doublePanelMode) then
			leftButtonPad = 0
			leftPad = 0
			rightPad = 0
			bottomPad = 0
			middlePad = 0
		elseif screenWidth < 1650 then
			leftButtonPad = 20
			leftPad = 5
			rightPad = 15
			bottomPad = 20
			middlePad = 10
		else
			leftButtonPad = 30
			leftPad = 10
			rightPad = 40
			bottomPad = 40
			middlePad = 20
		end
		
		contentPlace:SetPos(leftPad)
		contentPlace._relativeBounds.right = middlePad
		contentPlace._relativeBounds.bottom = bottomPad
		contentPlace:UpdateClientArea()

		panelWindow:SetPos(middlePad)
		panelWindow._relativeBounds.right = rightPad
		panelWindow._relativeBounds.bottom = bottomPad
		panelWindow:UpdateClientArea()

		panelButtonsHolder._relativeBounds.right = rightPad
		panelWindow:UpdateClientArea()

		exitButton._relativeBounds.bottom = bottomPad
		exitButton:UpdateClientArea()

		if doublePanelMode then
			battleStatusHolder._relativeBounds.right = panelButtonsWidth + rightPad
			battleStatusHolder:UpdateClientArea()
		else
			battleStatusHolder._relativeBounds.right = userStatusWidth
			battleStatusHolder:UpdateClientArea()
		end

		mainButtonsHolder:SetPos(leftButtonPad)
		local contentOffset = leftButtonPad
		if doublePanelMode then
			contentOffset = contentOffset + mainButtonsWidth
		else
			contentOffset = contentOffset + mainButtonsWidthSmall
		end
		contentPlaceHolder:SetPos(contentOffset)
		contentPlaceHolder._relativeBounds.right = 0
		contentPlaceHolder:UpdateClientArea()
	end
	
	-------------------------------------------------------------------
	-- Visibility and size handlers
	-------------------------------------------------------------------

	local function SetMainInterfaceVisible(newVisible)
		if lobbyInterfaceHolder.visible == newVisible then
			return
		end
		backgroundHolder:SetEnabled(newVisible)
		if newVisible then
			lobbyInterfaceHolder:Show()
			ingameInterfaceHolder:Hide()
		else
			lobbyInterfaceHolder:Hide()
			ingameInterfaceHolder:Show()
		end
	end
		
	local function SetTopBarVisible(newVisible)
		Spring.Echo("newVisible == showTopBar", newVisible, showTopBar)
		if newVisible == showTopBar then
			return
		end
		topBarHolder:SetVisibility(newVisible)
		showTopBar = newVisible
		
		local topOffset = (showTopBar and topBarHeight) or 0
		mainInterfaceHolder._relativeBounds.top = topOffset
		mainInterfaceHolder._relativeBounds.bottom = 0
		mainInterfaceHolder:UpdateClientArea()
		
		local screenWidth, screenHeight = Spring.GetViewGeometry()
		screen0:Resize(screenWidth, screenHeight)
	end
	
	-------------------------------------------------------------------
	-- Top bar initialisation
	-------------------------------------------------------------------
	
	local switchToMenuButton = Button:New {
		y = 5,
		right = 5,
		width = 100,
		height = 41,
		name = "switchToMenuButton",
		caption = "Menu",
		font = WG.Chobby.Configuration:GetFont(3),
		parent = ingameInterfaceHolder,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		
		OnClick = {
			function ()
				SetMainInterfaceVisible(true)
			end
		}
	}
	local switchToGameButton = Button:New {
		y = 5,
		right = 5,
		width = 100,
		height = 41,
		name = "switchToGameButton",
		caption = "Game",
		font = WG.Chobby.Configuration:GetFont(3),
		parent = topBarHolder,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		
		OnClick = {
			function ()
				SetMainInterfaceVisible(false)
			end
		}
	}
	local leaveGameButton = Button:New {
		y = 5,
		right = 110,
		width = 100,
		height = 41,
		height = topBarHeight - 10,
		name = "leaveGameButton",
		caption = "Leave",
		font = WG.Chobby.Configuration:GetFont(3),
		parent = topBarHolder,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		
		OnClick = {
			function ()
				Spring.Reload("")
			end
		}
	}
	
	local topBarImage = Image:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		file = IMAGE_TOP_BACKGROUND,
		parent = topBarHolder,
		keepAspect = false,
		color = {0.218, 0.23, 0.49, 0.9},
	}
	
	-------------------------------------------------------------------
	-- External Functions
	-------------------------------------------------------------------
	function externalFunctions.ViewResize(screenWidth, screenHeight)
		if autodetectDoublePanel then
			local newDoublePanel = minScreenWidth <= screenWidth
			UpdateDoublePanel(newDoublePanel)
		end
		UpdatePadding(screenWidth, screenHeight)
	end

	function externalFunctions.SetPanelDisplayMode(newAutodetectDoublePanel, newDoublePanel)
		autodetectDoublePanel = newAutodetectDoublePanel
		local screenWidth, screenHeight = Spring.GetViewGeometry()
		if autodetectDoublePanel then
			UpdateDoublePanel(screenWidth > minScreenWidth)
		else
			UpdateDoublePanel(newDoublePanel)
		end
		UpdatePadding(screenWidth, screenHeight)
		-- Make all children request realign.
		screen0:Resize(screenWidth, screenHeight)
	end
	
	function externalFunctions.SetIngame(newIngame)
		gameRunning = not newIngame
		SetMainInterfaceVisible(not newIngame)
		SetTopBarVisible(newIngame)
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
		return doublePanelMode
	end

	function externalFunctions.CleanMultiplayerState()
		CleanMultiplayerState(true)
	end

	function externalFunctions.KeyPressed(key, mods, isRepeat, label, unicode)
		if globalKeyListener then
			return globalKeyListener(key, mods, isRepeat, label, unicode)
		end
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

	function externalFunctions.SetGlobalKeyListener(newListenerFunc)
		-- This is intentially set up such that there is only one global key
		-- listener at a time. This is indended for popups that monopolise input.
		globalKeyListener = newListenerFunc
	end

	function externalFunctions.GetLobbyInterfaceHolder()
		return lobbyInterfaceHolder
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
			headingImage.file = Configuration:GetHeadingImage(doublePanelMode)
			headingImage:Invalidate()

			local newShortname = Configuration.shortnameMap[value]
			local replacementTabs = Configuration:GetGameConfig(false, "singleplayerMenu.lua", newShortname) or {}

			mainWindowHandler.SetBackAtMainMenu()
			mainWindowHandler.ReplaceSubmenu(1, replacementTabs)
		end
	end
	Configuration:AddListener("OnConfigurationChange", onConfigurationChange)

	-------------------------------------------------------------------
	-- Initialization
	-------------------------------------------------------------------
	local screenWidth, screenHeight = Spring.GetWindowGeometry()

	battleStatusPanelHandler.Rescale(4, 70)
	rightPanelHandler.Rescale(2, 70)
	RescaleMainWindow(3, 70)

	externalFunctions.ViewResize(screenWidth, screenHeight)
	UpdatePadding(screenWidth, screenHeight)
	UpdateChildLayout()

	return externalFunctions
end

return GetInterfaceRoot
