function GetSubmenuHandler(buttonWindow, panelWindow, submenus)
	
	local externalFunctions = {}
	local submenuPanelNames = {}
	
	local buttonsHolder
	
	local BUTTON_HEIGHT = 70
	local BUTTON_SPACING = 5
	local BUTTON_OFFSET = 80
	
	-------------------------------------------------------------------
	-- External Functions
	-------------------------------------------------------------------
	function externalFunctions.GetTabList(name)
		return submenuPanelNames[name]
	end
	
	function externalFunctions.SetBackAtMainMenu()
		for i = 1, #submenus do
			local panelHandler = submenus[i].panelHandler
			if panelHandler then
				panelHandler.Hide()
			end
		end
		
		if not buttonsHolder.visible then
			buttonsHolder:Show()
		end
		
		panelWindow:ClearChildren()
		if panelWindow.visible then
			panelWindow:Hide()
		end
	end
	
	-------------------------------------------------------------------
	-- Initialization
	-------------------------------------------------------------------
	buttonsHolder = Control:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		name = "buttonsHolder",
		parent = buttonWindow,
		padding = {0, 0, 0, 0},
		children = {}
	}

	local function BackToMainMenu(panelHandler) 
		panelHandler.Hide() 
		if not buttonsHolder.visible then
			buttonsHolder:Show()
		end
		
		if panelWindow.children[1] and panelHandler.GetManagedControlByName(panelWindow.children[1].name) then
			panelWindow:ClearChildren()
			if panelWindow.visible then
				panelWindow:Hide()
			end
		end
	end
	
	for i = 1, #submenus do
		
		if not submenus[i].exitGame then
			local panelHandler = GetTabPanelHandler(submenus[i].name, buttonWindow, panelWindow, submenus[i].tabs, true, BackToMainMenu)
			panelHandler.Hide()
			
			submenuPanelNames[submenus[i].name] = panelHandler
			submenus[i].panelHandler = panelHandler
		end
		
		submenus[i].button = Button:New {
			x = 0,
			y = (i - 1) * (BUTTON_HEIGHT + BUTTON_SPACING) + BUTTON_OFFSET,
			width = "100%",
			height = BUTTON_HEIGHT,
			caption = i18n(submenus[i].name),
			font = { size = 20},
			parent = buttonsHolder,
			OnClick = {function(self) 
				if submenus[i].exitGame then
					Spring.Echo("Quitting...")
					Spring.SendCommands("quitforce")
					return
				end
				
				if buttonsHolder.visible then
					buttonsHolder:Hide()
				end
				
				submenus[i].panelHandler.Show()
				
				if submenus[i].entryCheck then
					submenus[i].entryCheck()
				end
			end},
		}
	end
	
	return externalFunctions
end