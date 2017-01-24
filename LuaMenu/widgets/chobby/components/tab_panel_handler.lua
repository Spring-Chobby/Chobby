function GetTabPanelHandler(name, buttonWindow, displayPanel, initialTabs, tabsVertical, backFunction, cleanupFunction, fontSizeScale, tabWidth, tabControlOverride)

	local externalFunctions = {}

	local BUTTON_SPACING = 5
	local BUTTON_SIDE_SPACING = 3

	-------------------------------------------------------------------
	-- Local variables
	-------------------------------------------------------------------
	local buttonsHolder

	local fontSizeScale = fontSizeScale or 3
	local buttonOffset = 0
	local buttonWidth = tabWidth
	local buttonHeight = 70

	local heading -- has a value if the tab panel has a heading
	local backButton

	local tabs = {}

	-------------------------------------------------------------------
	-- Local functions
	-------------------------------------------------------------------

	local function OpenSubmenu(panelHandler)
		buttonsHolder:SetVisibility(false)
		panelHandler.Show()
	end
	
	local function ToggleShow(obj, tab, openOnly)
		if tab.panelHandler then
			OpenSubmenu(tab.panelHandler)
			return
		end
		
		local control = tab.control
		if not control then
			return
		end

		if displayPanel.visible then
			if displayPanel:GetChildByName(control.name) then
				if not openOnly then
					displayPanel:ClearChildren()
				end
				return
			end
		end
		displayPanel:ClearChildren()
		displayPanel:AddChild(control)
		if not displayPanel.visible then
			displayPanel:Show()
		end

		ButtonUtilities.SetButtonSelected(obj)
	end

	local function SetButtonPositionAndSize(index)
		if tabsVertical then
			tabs[index].button:SetPos(
				BUTTON_SIDE_SPACING,
				(index - 1) * (buttonHeight + BUTTON_SPACING) + buttonOffset,
				nil,
				buttonHeight
			)
			tabs[index].button._relativeBounds.right = BUTTON_SIDE_SPACING
			tabs[index].button:UpdateClientArea()
		elseif buttonWidth then
			tabs[index].button:SetPos(
				(index - 1) * (buttonWidth + BUTTON_SPACING) + buttonOffset,
				nil,
				buttonWidth
			)
			tabs[index].button._relativeBounds.right = nil
			tabs[index].button:SetPosRelative(
				nil,
				"0%",
				nil,
				"100%"
			)
		else
			local buttonSize = 100/#tabs
			local pos = (index - 1)*buttonSize .. "%"
			tabs[index].button._relativeBounds.right = nil
			tabs[index].button:SetPosRelative(
				(index - 1)*buttonSize .. "%",
				0,
				buttonSize .. "%",
				"100%"
			)
		end
	end

	local function UpdateButtonLayout(newTabsVertical)
		if newTabsVertical ~= nil then
			tabsVertical = newTabsVertical
		end
		for i = 1, #tabs do
			SetButtonPositionAndSize(i)
		end
	end


	local function OpenConfirmationPopup(sucessFunction)
		local backConfirm = Configuration.backConfirmation[name]
		if not backConfirm then
			return false
		end
		for i = 1, #backConfirm do
			local confirmData = backConfirm[i]
			if (not Configuration[confirmData.doNotAskAgainKey]) and confirmData.testFunction() then
				ConfirmationPopup(sucessFunction, confirmData.question, confirmData.doNotAskAgainKey)
				return true
			end
		end
		return false
	end

	-------------------------------------------------------------------
	-- External Functions
	-------------------------------------------------------------------
	function externalFunctions.UpdateLayout(panelParent, newTabsVertical)
		displayPanel = panelParent
		UpdateButtonLayout(newTabsVertical)
	end

	function externalFunctions.Hide()
		buttonsHolder:SetVisibility(false)
	end

	function externalFunctions.Show()
		buttonsHolder:SetVisibility(true)
	end

	function externalFunctions.IsVisible()
		return buttonsHolder.visible
	end

	function externalFunctions.IsTabSelected(tabName)
		for i = 1, #tabs do
			if tabs[i].control and tabs[i].control.parent and ((not tabName) or tabName == tabs[i].name)then
				return true
			end
		end
		return false
	end

	function externalFunctions.Rescale(newFontSize, newButtonHeight, newButtonWidth, newButtonOffset)
		for i = 1, #tabs do
			if tabs[i].panelHandler then
				tabs[i].panelHandler.Rescale(newFontSize, newButtonHeight, newButtonWidth, newButtonOffset)
			end
		end
		
		fontSizeScale = newFontSize or fontSizeScale
		buttonWidth = newButtonWidth or buttonWidth
		buttonHeight = newButtonHeight or buttonHeight
		
		if newButtonOffset then
			buttonOffset = newButtonOffset - BUTTON_SPACING
		end
		if heading then
			heading:Dispose()
			local size = Configuration:GetFont(fontSizeScale).size
			local buttonSize = math.min(size * 1.7)
			heading = TextBox:New {
				x = 4 + 2*size,
				y = 34 - size,
				right = 0,
				height = 30,
				valign = "center",
				align = "center",
				parent = buttonsHolder,
				fontsize = size,
				text = i18n(name),
			}

			backButton:SetPos(4, 36 - size * 1.5, buttonSize, buttonSize)
		end

		for i = 1, #tabs do
			if tabs[i].button then
				SetButtonPositionAndSize(i)
				ButtonUtilities.SetFontSizeScale(tabs[i].button, fontSizeScale)
			end
		end
	end

	function externalFunctions.OpenTab(tabIndex)
		if tabs[tabIndex] then
			ToggleShow(tabs[tabIndex].button, tabs[tabIndex], true)
		end
	end

	function externalFunctions.OpenTabByName(tabName)
		for i = 1, #tabs do
			if tabs[i].name == tabName then
				externalFunctions.OpenTab(i)
				return
			end
		end
	end
	
	function externalFunctions.GetTabByName(tabName)
		for i = 1, #tabs do
			if tabs[i].name == tabName then
				return i
			end
		end
	end

	function externalFunctions.GetManagedControlByName(controlName)
		for i = 1, #tabs do
			if tabs[i].control and tabs[i].control.name == controlName then
				return tabs[i].control, i
			end
		end
		return false
	end

	function externalFunctions.Destroy()
		for i = 1, #tabs do
			if tabs[i].control then
				tabs[i].control:Dispose()
			end
			tabs[i].button:Dispose()
		end
		buttonsHolder:Dispose()
		tabs = nil
	end

	function externalFunctions.RemoveTab(name, killControl)
		local index = 1
		local found = false
		while index <= #tabs do
			if found then
				tabs[index] = tabs[index + 1]
				index = index + 1
			elseif tabs[index].name == name then
				tabs[index].button:Dispose()
				if killControl then
					tabs[index].control:Dispose()
				end
				found = true
			else
				index = index + 1
			end
		end
		if found then
			UpdateButtonLayout()
		end
	end

	function externalFunctions.SetActivity(name, activityCount, priorityLevel)
		priorityLevel = priorityLevel or 1
		activityCount = activityCount or 0
		for i = 1, #tabs do
			local tab = tabs[i]
			if tab.name == name and tab.activityLabel then
				local activityLabel
				if activityCount > 0 then
					tab.priorityLevel = math.max(priorityLevel, tab.priorityLevel or 1)
					activityLabel = "(" .. tostring(activityCount) .. ")"
				else
					tab.priorityLevel = 1
					activityLabel = ""
				end
				if tab.priorityLevel == 1 then
					tab.activityLabel.font.outline = true
					tab.activityLabel.font.outlineColor = {1,1,1,1}
					tab.activityLabel.font.color = {1,1,1,1}
				elseif tab.priorityLevel == 2 then
					tab.activityLabel.font.outline = true
					tab.activityLabel.font.outlineColor = {1,0,0,1}
					tab.activityLabel.font.color = {1,0,0,1}
				else
					tab.activityLabel.font.outline = true
					tab.activityLabel.font.outlineColor = {0.8,1,0,1}
					tab.activityLabel.font.color = {0.8,1,0,1}
				end
				tab.activityLabel:SetCaption(activityLabel)
			end
		end
	end

	function externalFunctions.SetTabCaption(name, caption)
		for i = 1, #tabs do
			if tabs[i].name == name and tabs[i].activityLabel then
				ButtonUtilities.SetCaption(tabs[i].button, caption)
			end
		end
	end

	function externalFunctions.AddTab(name, humanName, control, onClick, rank, selected, entryCheck, submenuData)
		local newTab = {}

		newTab.name = name
		newTab.rank = rank or (#tabs + 1)
		newTab.control = control
		newTab.entryCheck = entryCheck
		local button
		
		if tabControlOverride and tabControlOverride[name] then
			button = tabControlOverride[name]()
		else
			button = Button:New {
				name = name .. "_button",
				x = "0%",
				y = "0%",
				width = "100%",
				height = "100%",
				padding = {0,0,0,0},
				caption = humanName,
				font = Configuration:GetFont(fontSizeScale),
			}
		end

		buttonsHolder:AddChild(button)

		button.OnClick = button.OnClick or {}
		button.OnClick[#button.OnClick + 1] = function(obj)
			if newTab.entryCheck then
				newTab.entryCheck(ToggleShow, obj, newTab)
			else
				ToggleShow(obj, newTab)
			end
		end
		
		if submenuData then
			local function BackToSubmenu(subPanelHandler)
				subPanelHandler.Hide() 
				if not buttonsHolder.visible then
					buttonsHolder:Show()
				end
				
				if displayPanel.children[1] and subPanelHandler.GetManagedControlByName(displayPanel.children[1].name) then
					displayPanel:ClearChildren()
					if displayPanel.visible then
						displayPanel:Hide()
					end
				end
			end
		
			local panelHandler = GetTabPanelHandler(name, buttonWindow, displayPanel, submenuData.tabs, tabsVertical, BackToSubmenu, submenuData.cleanupFunction, fontSizeScale)
			panelHandler.Hide()
			newTab.panelHandler = panelHandler
		end
		
		newTab.activityLabel = Label:New {
			name = "activity_label",
			y = 2,
			right = 2,
			width = 50,
			height = 5,
			valign = "top",
			align = "right",
			parent = button,
			font = Configuration:GetFont(1),
			caption = "",
		}

		newTab.activityLabel:BringToFront()

		if selected then
			ToggleShow(button, newTab)
		end

		if control then
			control.OnOrphan = control.OnOrphan or {}
			control.OnOrphan[#control.OnOrphan + 1] = function(obj)
				ButtonUtilities.SetButtonDeselected(button)

				if (displayPanel:IsEmpty() or displayPanel:GetChildByName(control.name))
						and displayPanel.visible then
					displayPanel:Hide()
				end
			end
		end

		newTab.button = button

		local index = #tabs + 1
		while index > 1 and newTab.rank < tabs[index - 1].rank do
			tabs[index] = tabs[index - 1]
			index = index - 1
		end
		tabs[index] = newTab

		UpdateButtonLayout()
	end

	-------------------------------------------------------------------
	-- Initialization
	-------------------------------------------------------------------
	buttonsHolder = Control:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		name = "buttons_" .. name,
		parent = buttonWindow,
		padding = {0, 0, 0, 0},
		children = {}
	}

	if backFunction then
		-- Add heading and back button
		buttonOffset = 50 - BUTTON_SPACING

		local function SucessFunction()
			if cleanupFunction then
				cleanupFunction() -- Cleans up state information created by the submenu
			end
			backFunction(externalFunctions) -- Returns UI to main menu
		end

		local size = Configuration:GetFont(fontSizeScale).size
		local buttonSize = math.min(size * 1.5)
		heading = TextBox:New {
			x = 4 + size*2,
			y = 36 - size,
			right = 0,
			height = 30,
			valign = "center",
			align = "center",
			parent = buttonsHolder,
			fontsize = size,
			text = i18n(name),
		}
		backButton = Button:New {
			name = name .. "_back_button",
			x = 1,
			y = 35 - size * 1.5,
			width = buttonSize,
			height = buttonSize,
			caption = "",
			padding = {1,0,1,1},
			children = {
				Image:New {
					x = 0,
					y = 0,
					right = 0,
					bottom = 0,
					file = LUA_DIRNAME .. "widgets/chobby/images/left.png",
				}
			},
			parent = buttonsHolder,
			OnClick = {
				function (obj)
					if OpenConfirmationPopup(SucessFunction) then
						return
					end
					SucessFunction()
				end
			},
		}
	end

	for i = 1, #initialTabs do
		externalFunctions.AddTab(
			initialTabs[i].name,
			i18n(initialTabs[i].name),
			initialTabs[i].control,
			nil, nil, nil,
			initialTabs[i].entryCheck,
			initialTabs[i].submenuData
		)
	end
	
	externalFunctions.Rescale()

	return externalFunctions
end
