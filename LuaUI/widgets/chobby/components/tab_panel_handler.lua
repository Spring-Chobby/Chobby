function GetTabPanelHandler(name, buttonWindow, displayPanel, initialTabs, tabsVertical, backFunction, cleanupFunction, fontSizeScale, tabWidth, tabControlOverride)
	
	local externalFunctions = {}
	
	local BUTTON_SPACING = 5

	-------------------------------------------------------------------
	-- Local variables
	-------------------------------------------------------------------
	local buttonsHolder
	local titleBackControl
	
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
	
	local function ToggleShow(obj, tab, openOnly)
		local control = tab.control
		
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
				nil, 
				(index - 1) * (buttonHeight + BUTTON_SPACING) + buttonOffset, 
				nil, 
				buttonHeight
			)
			tabs[index].button:SetPosRelative(
				"0%",
				nil,
				"100%"
			)
		elseif buttonWidth then
			tabs[index].button:SetPos(
				(index - 1) * (buttonWidth + BUTTON_SPACING) + buttonOffset,
				nil,
				buttonWidth
			)
			tabs[index].button:SetPosRelative(
				nil,
				"0%",
				nil,
				"100%"
			)
		else
			local buttonSize = 100/#tabs
			local pos = (index - 1)*buttonSize .. "%"
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
		if buttonsHolder.visible then
			buttonsHolder:Hide()
		end
	end
	
	function externalFunctions.Show()
		if not buttonsHolder.visible then
			buttonsHolder:Show()
		end
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
	
	function externalFunctions.Rescale(newFontSize, newButtonHeight, newButtonWidth)
		fontSizeScale = newFontSize or fontSizeScale
		buttonWidth = newButtonWidth or buttonWidth
		buttonHeight = newButtonHeight or buttonHeight
		if heading then
			heading:Dispose()
			local size = Configuration:GetFont(fontSizeScale).size
			heading = TextBox:New {
				x = 4 + 2*size,
				y = 40 - size,
				right = 0,
				height = 30,
				valign = "center",
				align = "center",
				parent = buttonsHolder,
				fontsize = size,
				text = i18n(name),
			}
			
			backButton:SetPos(4, 48 - size*2, size*2, size*2)
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
		tabs = nil
	end
	
	function externalFunctions.RemoveTab(name)
		local index = 1
		local found = false
		while index <= #tabs do
			if found then
				tabs[index] = tabs[index + 1]
				index = index + 1
			elseif tabs[index].name == name then
				tabs[index].button:Dispose()
				found = true
			else
				index = index + 1
			end
		end
		if found then
			UpdateButtonLayout()
		end
	end
	
	function externalFunctions.SetActivity(name, activityCount)
		for i = 1, #tabs do
			if tabs[i].name == name and tabs[i].activityLabel then
				local activityLabel
				if activityCount > 0 then
					activityLabel = "(" .. tostring(activityCount) .. ")"
				else
					activityLabel = ""
				end
				tabs[i].activityLabel:SetCaption(activityLabel)
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
	
	function externalFunctions.AddTab(name, humanName, control, onClick, rank, selected, entryCheck)
		local newTab = {}
		
		newTab.name = name
		newTab.rank = rank or (#tabs + 1)
		newTab.control = control
		newTab.entryCheck = entryCheck
		local button
		if control then
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
			
			if selected then
				ToggleShow(button, newTab)
			end
			
			control.OnOrphan = control.OnOrphan or {}
			control.OnOrphan[#control.OnOrphan + 1] = function(obj)
				ButtonUtilities.SetButtonDeselected(button)
				
				if (displayPanel:IsEmpty() or displayPanel:GetChildByName(control.name))
						and displayPanel.visible then
					displayPanel:Hide()
				end
			end
		else
			button = Button:New {
				x = "0%",
				y = "0%",
				width = "100%",
				height = "100%",
				caption = humanName,
				font = Configuration:GetFont(fontSizeScale),
				parent = buttonsHolder,
				OnClick = {onClick},
			}
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
		buttonOffset = 50

		local function SucessFunction()
			if cleanupFunction then
				cleanupFunction() -- Cleans up state information created by the submenu
			end
			backFunction(externalFunctions) -- Returns UI to main menu
		end
		
		local size = Configuration:GetFont(fontSizeScale).size
		heading = TextBox:New {
			x = 4 + size*2,
			y = 40 - size,
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
			x = 4,
			y = 48 - size*2,
			width = size*2,
			height = size*2,
			caption = "",
			padding = {2,2,2,2},
			children = {
				Image:New {
					x = 0,
					y = 0,
					right = 0,
					bottom = 0,
					file = "luaui/widgets/chobby/images/left.png",
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
			initialTabs[i].entryCheck
		)
	end
	
	return externalFunctions
end
