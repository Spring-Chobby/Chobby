function GetInterfaceRoot(optionsParent, mainWindowParent, fontFunction)
	
	local externalFunctions = {}
	
	local titleWidthRel = 28
	local panelWidthRel = 40
	
	local titleHeight = 180
	local titleWidth = 400
	local battleStatusWidth = 480
	local panelButtonsHeight = 50
	local mainButtonsWidth = 180
	
	local padding = 0
	
	-- Switch to single panel mode when below the minimum screen width
	local minScreenWidth = 1280
	
	local fullscreenMode = true
	local autodetectFullscreen = true
	
	-------------------------------------------------------------------
	-- Window structure
	-------------------------------------------------------------------
	local headingWindow = Window:New {
		x = 0,
		y = 0,
		width = titleWidth,
		height = titleHeight,
		name = "headingWindow",
		caption = "Your Game Here",
		parent = screen0,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		children = {}
	}
	
	--headingWindow:SetPosRelative("20%","20%","20%","20%")
	
	local statusWindow = Window:New {
		x = titleWidth,
		y = 0,
		right = 0,
		height = titleHeight - panelButtonsHeight,
		name = "statusWindow",
		caption = "Status Window",
		parent = screen0,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		children = {
			WG.UserStatusPanel.GetControl()
		}
	}
	
	local battleStatusHolder = Window:New {
		x = 0,
		y = 0,
		width = battleStatusWidth,
		bottom = 0,
		name = "battleStatusHolder",
		caption = "Battle and MM Status Window",
		parent = screen0,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		parent = statusWindow,
		children = {}
	}
	
	local mainWindow = Window:New {
		x = 0,
		y = titleHeight,
		width = (100 - panelWidthRel) .. "%",
		bottom = 0,
		name = "mainWindow",
		caption = "Main Window",
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
	local mainButtons = Window:New {
		x = 0,
		y = 0,
		width = "100%",
		height = "100%",
		name = "mainButtons",
		caption = "Main Buttons",
		parent = buttonsPlace,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		children = {}
	}
	
	--buttonsPlace._relativeBounds.bottom = 150
	--buttonsPlace._relativeBounds.right = 150
	--buttonsPlace:UpdateClientArea(false)
	
	local contentPlace = Window:New {
		x = mainButtonsWidth,
		y = padding,
		right = padding,
		bottom = padding,
		name = "contentPlace",
		caption = "Content Place",
		parent = mainWindow,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		children = {}
	}
	contentPlace:Hide()
	
	local panelButtonsHolder = Window:New {
		x = (100 - panelWidthRel) .. "%",
		y = titleHeight - panelButtonsHeight,
		right = 0,
		height = panelButtonsHeight,
		name = "panelButtonsHolder",
		parent = screen0,
		padding = {0, 0, 0, 0},
		children = {}
	}
	local panelButtons = Control:New {
		x = "0%",
		y = "0%",
		width = "100%",
		height = "100%",
		name = "panelButtons",
		caption = "Panel Buttons",
		parent = panelButtonsHolder,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		children = {}
	}
	local panelWindow = Window:New {
		x = (100 - panelWidthRel) .. "%",
		y = titleHeight,
		right = 0,
		bottom = 0,
		name = "panelWindow",
		caption = "Panel Window",
		parent = screen0,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		children = {}
	}
	panelWindow:Hide()
	
	-- Exit button
	local exitButton = Button:New {
		x = 0,
		bottom = 10,
		width = "100%",
		height = 70,
		caption = i18n("exit"),
		font = {size = 20},
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
		-- TODO: Implement
		{name = "downloads", control = WG.SettingsWindow.GetControl()},
		-- TODO: Implement
		{name = "friends", control = WG.SettingsWindow.GetControl()},
	}
	
	local submenus = {
		{
			name = "singleplayer", 
			tabs = {
				{
					name = "custom_caps", 
					control = WG.BattleRoomWindow.GetSingleplayerControl(),
					entryCheck = WG.BattleRoomWindow.SetSingleplayerGame,
				},
			}
		},
		{
			name = "multiplayer", 
			entryCheck = WG.MultiplayerEntryPopup,
			tabs = {
				{name = "matchmaking_caps", control = QueueListWindow().window},
				{name = "custom_caps", control = BattleListWindow().window},
			},
		},
	}
	
	local battleStatusPanelHandler = GetTabPanelHandler("myBattlePanel", battleStatusHolder, contentPlace, {})
	local rightPanelHandler = GetTabPanelHandler("panelTabs", panelButtons, panelWindow, rightPanelTabs)
	local mainWindowHandler = GetSubmenuHandler(mainButtons, contentPlace, submenus)
	
	local function UpdateChildLayout()
		if fullscreenMode then
			local chatTabs = chatWindows.tabPanel
			local chatTabsName = chatTabs.tabBar.name
			if not chatTabs:GetChildByName(chatTabsName) then
				chatTabs:AddChild(chatTabs.tabBar)
				chatTabs.tabBar:BringToFront()
				chatTabs.tabBar:UpdateClientArea()
				chatTabs:Invalidate()
			end
			
			rightPanelHandler.UpdateLayout(panelWindow, false)
			if not contentPlace:IsEmpty() then
				local control, index = rightPanelHandler.GetManagedControlByName(contentPlace.children[1].name)
				if control then
					contentPlace:ClearChildren()
					rightPanelHandler.OpenTab(index)
				end
			end
		else
			local chatTabs = chatWindows.tabPanel
			local chatTabsName = chatTabs.tabBar.name
			if not screen0:GetChildByName(chatTabsName) then
				screen0:AddChild(chatTabs.tabBar)
				chatTabs.tabBar:SetPos(titleHeight, titleHeight - panelButtonsHeight + 14)
				chatTabs.tabBar._relativeBounds.right = 0
				chatTabs.tabBar:UpdateClientArea()
				
				chatTabs.OnTabClick = {
					function()
						local control, index = rightPanelHandler.GetManagedControlByName(chatWindows.window.name)
						rightPanelHandler.OpenTab(index)
					end
				}
			end
			
			
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
			-- Move Panel Buttons
			mainButtons:RemoveChild(panelButtons)
			panelButtonsHolder:AddChild(panelButtons)
			
			panelButtons:SetPosRelative("0%","0%", "100%","100%")
			--mainButtons:SetPosRelative("0%","0%", nil,"100%")
			
			-- Make Main Window take up more space
			panelButtonsHolder:Show()
			panelWindow:Show()
			mainWindow._relativeBounds.right = panelWidthRel .. "%"
			mainWindow:UpdateClientArea()
			
			-- Align game title and status.
			headingWindow:SetPos(0, 0, titleWidth, titleHeight)
			statusWindow:SetPos(titleWidth)
			statusWindow._relativeBounds.right = 0
			statusWindow:UpdateClientArea()
		else
			-- Move Panel Buttons
			panelButtonsHolder:RemoveChild(panelButtons)
			mainButtons:AddChild(panelButtons)
			
			panelButtons:SetPosRelative("0%","40%", "100%","50%")
			--mainButtons:SetPosRelative("0%","0%", nil,"50%")
			
			-- Make Main Window take up more space
			panelButtonsHolder:Hide()
			panelButtonsHolder:ClearChildren()
			if panelWindow.visible then
				panelWindow:Hide()
			end
			mainWindow._relativeBounds.right = 0
			mainWindow:UpdateClientArea()
			
			-- Align game title and status.
			headingWindow:SetPos(nil, nil, mainButtonsWidth + padding)
			statusWindow:SetPos(mainButtonsWidth)
			statusWindow._relativeBounds.right = 0
			statusWindow:UpdateClientArea()
		end
		
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
	
	function externalFunctions.GetContentPlace()
		return contentPlace
	end
	
	function externalFunctions.GetStatusWindow()
		return statusWindow
	end
	
	function externalFunctions.GetMainWindowHandler()
		return mainWindowHandler
	end
	
	function externalFunctions.GetBattleStatusWindowHandler()
		return battleStatusPanelHandler
	end
	
	-------------------------------------------------------------------
	-- Initialization
	-------------------------------------------------------------------
	local screenWidth, screenHeight = Spring.GetWindowGeometry()
	
	externalFunctions.UpdateSizeMode(screenWidth, screenHeight)
	UpdateChildLayout()

	return externalFunctions
end

return GetInterfaceRoot
