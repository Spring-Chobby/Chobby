function GetTabPanelHandler(holderName, buttonWindow, displayPanel, tabs, tabsVertical)
	
	local externalFunctions = {}
	
	local BUTTON_HEIGHT = 80
	
	-------------------------------------------------------------------
	-- Local variables
	-------------------------------------------------------------------
	local buttonsHolder
	
	-------------------------------------------------------------------
	-- Local functions
	-------------------------------------------------------------------
	local function getFont() 
		return {
			size = 16,
			outlineWidth = 6,
			outlineHeight = 6,
			outline = true,
			outlineColor = {0.54,0.72,1,0.3},
			autoOutlineColor = false,
			font = fontName
		}
	end
	
	local function ToggleShow(self, tab)
		if type(tab.control) == "function" then
			tab.control = tab.control()
			tab.control.OnOrphan = {
				function(self)
					tab.button:SetCaption(tab.button.oldCaption)
					tab.button.font = tab.button.oldFont
					tab.button.backgroundColor = tab.button.oldBackgroundColor
					tab.button:Invalidate()
					
					if (displayPanel:IsEmpty() or displayPanel:GetChildByName(tab.control.name)) and displayPanel.visible then
						displayPanel:Hide()
					end
				end
			}
		end
		
		local control = tab.control
		
		if displayPanel.visible then
			if displayPanel:GetChildByName(control.name) then
				displayPanel:ClearChildren()
				return
			end
		end
		displayPanel:ClearChildren()
		displayPanel:AddChild(control)
		if not displayPanel.visible then
			displayPanel:Show()
		end
		
		self:SetCaption(Configuration:GetSelectedColor() .. self.oldCaption .. "\b")
		self.font = Chili.Font:New(getFont())
		self.backgroundColor = Configuration:GetButtonSelectedColor()
		self:Invalidate()
	end
	
	local function SetButtonPositionAndSize(index)
		if tabsVertical then
			tabs[index].button:SetPos(nil, nil, nil, BUTTON_HEIGHT)
			tabs[index].button:SetPosRelative(
				"0%",
				(index - 1) * BUTTON_HEIGHT,
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
	
	function externalFunctions.OpenTab(tabIndex)
		if tabs[tabIndex] then
			ToggleShow(tabs[tabIndex].button, tabs[tabIndex])
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
	
	function externalFunctions.RemoveTab(name)
		local index = 1
		local found = false
		while index <= #tabs do
			if found then
				tabs[index] = tabs[index + 1]
				index = index + 1
			elseif tabs[index].internalName == name then
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
	
	function externalFunctions.AddTab(name, onClick, rank, control, selected, internalName)
		local newTab = {}
		local rank = rank or (#tabs + 1)
		
		newTab.name = name
		newTab.rank = rank
		newTab.internalName = internalName
		newTab.control = control
		local button
		if control then
			button = Button:New {
				x = "0%",
				y = "0%",
				width = "100%",
				height = "100%",
				caption = name,
				font = {size = 20},
				parent = buttonsHolder,
				OnClick = {function(self) ToggleShow(self, newTab) end},
			}
		
			
			button.oldFont = button.font
			button.oldCaption = button.caption
			button.oldBackgroundColor = button.backgroundColor
			
			if selected then
				ToggleShow(button, newTab)
			end
			
			if type(control) ~= "function" then
				control.OnOrphan = {
					function(self)
						button:SetCaption(button.oldCaption)
						button.font = button.oldFont
						button.backgroundColor = button.oldBackgroundColor
						button:Invalidate()
					
						if (displayPanel:IsEmpty() or displayPanel:GetChildByName(control.name)) and displayPanel.visible then
							displayPanel:Hide()
						end
					end
				}
			end
		else
			button = Button:New {
				x = "0%",
				y = "0%",
				width = "100%",
				height = "100%",
				caption = name,
				font = {size = 20},
				parent = buttonsHolder,
				OnClick = {onClick},
			}
		end

		newTab.button = button
		
		local index = #tabs + 1
		while index > 1 and rank < tabs[index - 1].rank do
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
		name = holderName,
		parent = buttonWindow,
		padding = {0, 0, 0, 0},
		children = {}
	}
	
	for i = 1, #tabs do
		local thisTab = tabs[i] -- Protect against tab reordering
		local button = Button:New {
			name = thisTab.name .. "_button",
			x = "0%",
			y = "0%",
			width = "100%",
			height = "100%",
			caption = i18n(thisTab.name),
			font = { size = 20},
			parent = buttonsHolder,
			OnClick = {function(self) ToggleShow(self, thisTab) end},
		}
		thisTab.button = button
		SetButtonPositionAndSize(i)
		
		button.oldFont = button.font
		button.oldCaption = button.caption
		button.oldBackgroundColor = button.backgroundColor
		
		thisTab.rank = i
		if type(thisTab.control) ~= "function" then
			thisTab.control.OnOrphan = {
				function(self)
					button:SetCaption(button.oldCaption)
					button.font = button.oldFont
					button.backgroundColor = button.oldBackgroundColor
					button:Invalidate()
					
					if (displayPanel:IsEmpty() or displayPanel:GetChildByName(thisTab.control.name)) and displayPanel.visible then
						displayPanel:Hide()
					end
				end
			}
		end
	end
	
	return externalFunctions
end