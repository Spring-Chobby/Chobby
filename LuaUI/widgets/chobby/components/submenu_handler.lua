function GetSubmenuHandler(buttonWindow, panelWindow, submenus)
	
	local externalFunctions = {}
	local submenuPanelNames = {}
	
	local buttonsHolder
	
	local fontSizeScale = 3
	local buttonHeight = 70
	
	local BUTTON_SPACING = 5
	local BUTTON_OFFSET = 50
	
	-------------------------------------------------------------------
	-- Local Functions
	-------------------------------------------------------------------
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
	
	local function SetButtonPositionAndSize(index)
		submenus[index].button:SetPos(
			nil, 
			(index - 1) * (buttonHeight + BUTTON_SPACING) + BUTTON_OFFSET, 
			nil, 
			buttonHeight
		)
		submenus[index].button:SetPosRelative(
			"0%",
			nil,
			"100%"
		)
	end
	
	-------------------------------------------------------------------
	-- External Functions
	-------------------------------------------------------------------
	function externalFunctions.GetTabList(name)
		return submenuPanelNames[name]
	end
	
	function externalFunctions.GetCurrentSubmenu()
		for i = 1, #submenus do
			local panelHandler = submenus[i].panelHandler
			if panelHandler.IsVisible() then
				return i
			end
		end
		return false
	end
	
	function externalFunctions.SetBackAtMainMenu()
		local clearMainWindow = false
		for i = 1, #submenus do
			local panelHandler = submenus[i].panelHandler
			if panelHandler.IsTabSelected() then
				clearMainWindow = true
			end
			if panelHandler then
				panelHandler.Hide()
			end
		end
		
		if not buttonsHolder.visible then
			buttonsHolder:Show()
		end
		
		if clearMainWindow then
			panelWindow:ClearChildren()
			if panelWindow.visible then
				panelWindow:Hide()
			end
		end
	end
	
	function externalFunctions.ReplaceSubmenu(index, newTabs)
		externalFunctions.SetBackAtMainMenu()
		submenus[index].panelHandler.Destroy()
		
		local newPanelHandler = GetTabPanelHandler(submenus[index].name, buttonWindow, panelWindow, newTabs, true, BackToMainMenu)
		newPanelHandler.Hide()
		submenus[index].panelHandler = newPanelHandler
	end
	
	function externalFunctions.Rescale(newFontSize, newButtonHeight)
		fontSizeScale = newFontSize or fontSizeScale
		buttonHeight = newButtonHeight or buttonHeight
		for i = 1, #submenus do
			submenus[i].panelHandler.Rescale(newFontSize, newButtonHeight)
			ButtonUtilities.SetFontSizeScale(submenus[i].button, fontSizeScale)
			SetButtonPositionAndSize(i)
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
	
	for i = 1, #submenus do
		
		local panelHandler = GetTabPanelHandler(submenus[i].name, buttonWindow, panelWindow, submenus[i].tabs, true, BackToMainMenu, fontSizeScale)
		panelHandler.Hide()
		
		submenuPanelNames[submenus[i].name] = panelHandler
		submenus[i].panelHandler = panelHandler
		
		submenus[i].button = Button:New {
			x = 0,
			y = (i - 1) * (buttonHeight + BUTTON_SPACING) + BUTTON_OFFSET,
			width = "100%",
			height = buttonHeight,
			caption = i18n(submenus[i].name),
			font = { size = 20},
			parent = buttonsHolder,
			OnClick = {function(self) 
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
