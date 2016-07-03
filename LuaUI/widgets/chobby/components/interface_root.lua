
function GetInterfaceRoot(optionsParent, mainWindowParent, fontFunction)
	
	local titleHeight = 18
	local titleWidth = 28
	local panelWidth = 40
	
	local panelButtonHeightAbsolute = 60
	local mainButtonsWidthAbsolute = 240
	
	local padding = 5
	
	local headingWindow = Window:New {
		x = "0%",
		y = 0,
		width = titleWidth .. "%",
		height = titleHeight .. "%",
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
		x = titleWidth .. "%",
		y = 0,
		width = (100 - titleWidth - panelWidth) .. "%",
		height = titleHeight .. "%",
		name = "statusWindow",
		caption = "Status Window",
		parent = screen0,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		children = {}
	}
	
	local mainWindow = Window:New {
		x = 0,
		y = titleHeight .. "%",
		width = (100 - panelWidth) .. "%",
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
		width = mainButtonsWidthAbsolute,
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
		x = mainButtonsWidthAbsolute,
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
	
	local panelButtonsHolder = Control:New {
		x = (100 - panelWidth) .. "%",
		height = panelButtonHeightAbsolute,
		right = 0,
		bottom = (100 - titleHeight) .. "%",
		name = "panelButtonsHolder",
		parent = screen0,
		padding = {0, 0, 0, 0},
		children = {}
	}
	local panelButtons = Window:New {
		x = 0,
		height = 0,
		right = 0,
		bottom = 0,
		name = "panelButtons",
		caption = "Panel Buttons",
		parent = panelButtonsHolder,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		children = {}
	}
	local panelWindow = Window:New {
		x = (100 - panelWidth) .. "%",
		y = titleHeight .. "%",
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
		
	-- Switch to single panel mode when below the minimum screen width
	local minScreenWidth = 1280
	
	local fullscreenMode = true
	
	local function UpdateSizeMode(screenWidth, screenHeight)
		local newFullscreen = screenWidth > minScreenWidth
		if newFullscreen == fullscreenMode then
			return 
		end
		fullscreenMode = newFullscreen
		
		if fullscreenMode then
			-- Move Panel Buttons
			buttonsPlace:RemoveChild(panelButtons)
			panelButtonsHolder:AddChild(panelButtons)
			
			panelButtons:SetPosRelative("0%","0%", "100%","100%")
			mainButtons:SetPosRelative("0%","0%", nil,"100%")
			
			-- Make Main Window take up more space
			panelButtonsHolder:Show()
			panelWindow:Show()
			mainWindow._relativeBounds.right = panelWidth .. "%"
			mainWindow:UpdateClientArea(false)
			
			-- Align game title and status.
			headingWindow:SetPosRelative("0%",nil, titleWidth .. "%")
			statusWindow:SetPosRelative(titleWidth .. "%", nil, (100 - titleWidth - panelWidth) .. "%")
		else
			-- Move Panel Buttons
			panelButtonsHolder:RemoveChild(panelButtons)
			buttonsPlace:AddChild(panelButtons)
			
			panelButtons:SetPosRelative("0%","50%", "100%","50%")
			mainButtons:SetPosRelative("0%","0%", nil,"50%")
			
			-- Make Main Window take up more space
			panelButtonsHolder:Hide()
			panelWindow:Hide()
			mainWindow._relativeBounds.right = 0
			mainWindow:UpdateClientArea(false)
			
			-- Align game title and status.
			headingWindow:SetPos(nil, nil, mainButtonsWidthAbsolute)
			statusWindow:SetPos(mainButtonsWidthAbsolute)
			statusWindow:SetPosRelative(nil, nil, "100%")
		end
	end
	
	local screenWidth, screenHeight = Spring.GetWindowGeometry()
	UpdateSizeMode(screenWidth, screenHeight)
	
	return {
		UpdateSizeMode = UpdateSizeMode,
	}
end

return GetInterfaceRoot