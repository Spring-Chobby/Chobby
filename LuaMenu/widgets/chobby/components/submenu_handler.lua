function GetSubmenuHandler(buttonWindow, panelWindow, submenus)
	
	local externalFunctions = {}
	local submenuPanelNames = {}
	
	local buttonsHolder
	
	local fontSizeScale = 3
	local buttonHeight = 70
	
	local BUTTON_SPACING = 5
	local BUTTON_SIDE_SPACING = 3
	local buttonOffset = 50
	
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
			BUTTON_SIDE_SPACING, 
			(index - 1) * (buttonHeight + BUTTON_SPACING) + buttonOffset - BUTTON_SPACING, 
			nil, 
			buttonHeight
		)
		submenus[index].button._relativeBounds.right = BUTTON_SIDE_SPACING
		submenus[index].button:UpdateClientArea()
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
	
	function externalFunctions.SetBackAtMainMenu(submenuName)
		if submenuName then
			local index = externalFunctions.GetCurrentSubmenu()
			if index and (submenuName ~= submenus[index].name) then
				return
			end
		end
		
		local clearMainWindow = false
		for i = 1, #submenus do
			local panelHandler = submenus[i].panelHandler
			if panelHandler then
				clearMainWindow = panelHandler.CloseSubmenu() or clearMainWindow
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
	
	function externalFunctions.ReplaceSubmenu(index, newTabs, newCleanupFunction)
		externalFunctions.SetBackAtMainMenu()
		submenus[index].panelHandler.Destroy()
		
		local newPanelHandler = GetTabPanelHandler(submenus[index].name, buttonWindow, panelWindow, newTabs, true, BackToMainMenu, newCleanupFunction, fontSizeScale)
		Spring.Utilities.TableEcho(newPanelHandler, "newPanelHandler")
		newPanelHandler.Rescale(fontSizeScale, buttonHeight, nil, buttonOffset)
		newPanelHandler.Hide()
		submenus[index].panelHandler = newPanelHandler
	end
	
	function externalFunctions.Rescale(newFontSize, newButtonHeight, newButtonOffset)
		fontSizeScale = newFontSize or fontSizeScale
		buttonHeight = newButtonHeight or buttonHeight
		if newButtonOffset then
			buttonOffset = newButtonOffset
		end
		for i = 1, #submenus do
			submenus[i].panelHandler.Rescale(newFontSize, newButtonHeight, nil, newButtonOffset)
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
		
		local panelHandler = GetTabPanelHandler(submenus[i].name, buttonWindow, panelWindow, submenus[i].tabs, true, BackToMainMenu, submenus[i].cleanupFunction, fontSizeScale)
		panelHandler.Hide()
		
		submenuPanelNames[submenus[i].name] = panelHandler
		submenus[i].panelHandler = panelHandler
		
		submenus[i].button = Button:New {
			x = BUTTON_SIDE_SPACING,
			y = (i - 1) * (buttonHeight + BUTTON_SPACING) + buttonOffset - BUTTON_SPACING,
			right = BUTTON_SIDE_SPACING,
			height = buttonHeight,
			caption = i18n(submenus[i].name),
			font = { size = 20},
			parent = buttonsHolder,
			OnClick = {
				function(self) 
					if buttonsHolder.visible then
						buttonsHolder:Hide()
					end
					
					submenus[i].panelHandler.Show()
					
					if submenus[i].entryCheck then
						submenus[i].entryCheck()
					end
				end
			},
		}
	end
	
	return externalFunctions
end
