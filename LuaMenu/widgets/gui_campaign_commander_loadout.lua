--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Campaign Commander Loadout",
		desc      = "Displays commanders and modules.",
		author    = "GoogleFrog",
		date      = "9 July 2017",
		license   = "GNU LGPL, v2.1 or later",
		layer     = 0,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Local Variables

local TOP_HEIGHT = 200
local HEADING_OFFSET = 36
local BUTTON_SIZE = 50

local modulePanelHandler

local function UpdateAllUnlocks()
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Utilities

local function ModuleIsValid(data, level, slotAllows, oldModuleName, alreadyOwned, moduleLimit)
	if (not slotAllows[data.slotType]) or (data.requireLevel or 0) > level or data.unequipable then
		return false
	end
	
	local moduleName = data.name
	
	-- Check that requirements are met
	if data.requireOneOf then
		local foundRequirement = false
		for j = 1, #data.requireOneOf do
			local reqDefName = data.requireOneOf[j]
			if (alreadyOwned[reqDefName] or 0) - ((oldModuleName == reqDefName) and 1 or 0) > 0 then
				foundRequirement = true
				break
			end
		end
		if not foundRequirement then
			return false
		end
	end
	
	-- Check that nothing prohibits this module
	if data.prohibitingModules then
		for j = 1, #data.prohibitingModules do
			-- Modules cannot prohibit themselves otherwise this check makes no sense.
			local probihitDefName = data.prohibitingModules[j]
			if (alreadyOwned[probihitDefName] or 0) - ((oldModuleName == probihitDefName) and 1 or 0) > 0 then
				return false
			end
		end
	
	end
	
	-- Check that the module limit is not reached
	if (data.limit or moduleLimit[moduleName]) and alreadyOwned[moduleName] then
		local count = (alreadyOwned[moduleName] or 0) - ((oldModuleName == moduleName) and 1 or 0)
		if count > math.min(data.limit or 100, moduleLimit[moduleName] or 100) then
			return false
		end
	end
	return true
end

local function GetValidReplacementModuleSlot(moduleName, level, slot)
	local commConfig = WG.Chobby.Configuration.campaignConfig.commConfig
	local chassisDef = commConfig.chassisDef
	local moduleDefs = commConfig.moduleDefs
	local moduleDefNames = commConfig.moduleDefNames
	
	local commanderLevel, _, commanderLoadout = WG.CampaignData.GetPlayerCommanderInformation()
	local loadoutModuleCounts = WG.CampaignData.GetCommanderModuleCounts()
	local moduleList, moduleLimit = WG.CampaignData.GetModuleListAndLimit()
	
	commanderLevel = math.min(commanderLevel, chassisDef.highestDefinedLevel)
	local slotAllows = chassisDef.levelDefs[commanderLevel].upgradeSlots[slot].slotAllows
	
	local validList = {}
	for i = 1, #moduleList do
		local newModuleData = moduleDefNames[moduleList[i]] and moduleDefs[moduleDefNames[moduleList[i]]] -- filters out _LIMIT_ unlock entries.
		if newModuleData and ModuleIsValid(newModuleData, commanderLevel, slotAllows, moduleName, loadoutModuleCounts, moduleLimit) then
			validList[#validList + 1] = moduleList[i]
		end
	end
	
	if slotAllows.module then
		validList[#validList + 1] = "nullmodule"
	else
		validList[#validList + 1] = "nullbasicweapon"
	end
	
	return validList
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Components

local function GetModuleButton(parentControl, ClickFunc, moduleName, level, slot, position)
	local moduleDefs = WG.Chobby.Configuration.campaignConfig.commConfig.moduleDefs
	local moduleDefNames = WG.Chobby.Configuration.campaignConfig.commConfig.moduleDefNames
	
	local moduleData = moduleDefs[moduleDefNames[moduleName]]
	
	local button = Button:New{
		x = 5,
		y = position,
		right = 5,
		height = BUTTON_SIZE,
		padding = {0, 0, 0, 0},
		caption = "",
		OnClick = { 
			function(self) 
				ClickFunc(self, moduleName, level, slot)
			end 
		},
		tooltip = moduleData.description,
		parent = parentControl
	}
	local nameBox = TextBox:New{
		x = BUTTON_SIZE + 4,
		y = 14,
		right = 4,
		height = BUTTON_SIZE,
		text = moduleData.humanName,
		fontsize = WG.Chobby.Configuration:GetFont(2).size,
		OnClick = { 
			function(self) 
				ClickFunc(self, moduleName, level, slot)
			end 
		},
		parent = button
	}
	local image = Image:New{
		x = 4,
		y = 4,
		width = BUTTON_SIZE - 8,
		height = BUTTON_SIZE - 8,
		keepAspect = true,
		file = moduleData.image,
		parent = button,
	}
	
	local externalFunctions = {}
	function externalFunctions.SetModuleName(newModuleName)
		if newModuleName == moduleName then
			return
		end
		moduleName = newModuleName
		moduleData = moduleDefs[moduleDefNames[moduleName]]
		
		button.tooltip = moduleData.tooltip
		button:Invalidate()
		nameBox:SetText(moduleData.humanName)
		image.file = moduleData.image
		image:Invalidate()
	end
	
	function externalFunctions.SetVisibility(newVisiblity)
		button:SetVisibility(newVisiblity)
	end
	
	return externalFunctions
end

local function GetModuleList(parentControl, ClickFunc, left, right)
	local Configuration = WG.Chobby.Configuration
	
	local listScroll = ScrollPanel:New {
		x = left,
		right = right,
		y = 0,
		bottom = 0,
		horizontalScrollbar = false,
		padding = {4, 4, 4, 4},
		parent = parentControl,
	}
	
	local offset = 0
	local buttonList = {}
	
	local externalFunctions = {}
	
	function externalFunctions.AddHeading(text)
		local heading = Label:New {
			x = 10,
			y = offset + 7,
			right = 5,
			height = 20,
			align = "left",
			font = Configuration:GetFont(3),
			caption = text,
			parent = listScroll
		}
		offset = offset + HEADING_OFFSET
	end
	
	function externalFunctions.AddModule(moduleName, level, slot)
		local button = GetModuleButton(listScroll, ClickFunc, moduleName, level, slot, offset)
		if slot then
			buttonList[level] = buttonList[level] or {}
			buttonList[level][slot] = button
		else
			buttonList[level] = button
		end
		offset = offset + BUTTON_SIZE + 4
	end
	
	function externalFunctions.UpdateModule(moduleName, level, slot)
		if slot then
			if buttonList[level] and buttonList[level][slot] then
				buttonList[level][slot].SetModuleName(moduleName)
				buttonList[level][slot].SetVisibility(true)
			else
				externalFunctions.AddModule(moduleName, level, slot)
			end
		else
			if buttonList[level] then
				buttonList[level].SetModuleName(moduleName)
				buttonList[level].SetVisibility(true)
			else
				externalFunctions.AddModule(moduleName, level, slot)
			end
		end
	end
	
	function externalFunctions.UpdateModuleList(newModuleList)
		-- Only works on modules indexed by 'level' directly
		local count = math.max(#newModuleList, #buttonList)
		for i = 1, count do
			if newModuleList[i] then
				externalFunctions.UpdateModule(newModuleList[i], i)
			else
				buttonList[i].SetVisibility(false)
			end
		end
	end
	
	function externalFunctions.SetVisibility(newVisiblity)
		listScroll:SetVisibility(newVisiblity)
	end
	
	return externalFunctions
end

local function MakeModulePanelHandler(parentControl)
	local highlightedButton, applyLevel, applySlot
	
	local function ApplyModule(button, moduleName)
		WG.CampaignData.PutModuleInSlot(moduleName, applyLevel, applySlot)
	end
	
	local moduleSelector = GetModuleList(parentControl, ApplyModule, "51%", 0)
	moduleSelector.SetVisibility(false)
	
	local function SelectModuleSlot(button, moduleName, level, slot)
		if highlightedButton then
			ButtonUtilities.SetButtonDeselected(highlightedButton)
		end
		applyLevel, applySlot = level, slot
		highlightedButton = button
		ButtonUtilities.SetButtonSelected(button)
		
		moduleSelector.UpdateModuleList(GetValidReplacementModuleSlot(moduleName, level, slot))
		moduleSelector.SetVisibility(true)
	end
	
	local currentLoadout = GetModuleList(parentControl, SelectModuleSlot, 0, "51%")
	
	local externalFunctions = {}
	
	function externalFunctions.UpdateLoadoutDisplay(commanderLevel, commanderName, commanderLoadout)
		for level = 0, commanderLevel do
			local slots = commanderLoadout[level]
			if slots then
				currentLoadout.AddHeading("Level " .. (level + 1))
				for i = 1, #slots do
					currentLoadout.AddModule(slots[i], level, i)
				end
			end
		end
	end
	
	local function ModuleSelected(listener, moduleName, oldModule, level, slot)
		if highlightedButton then
			ButtonUtilities.SetButtonDeselected(highlightedButton)
		end
		moduleSelector.SetVisibility(false)
		currentLoadout.UpdateModule(moduleName, level, slot)
	end
	
	WG.CampaignData.AddListener("ModulePutInSlot", ModuleSelected)
	
	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Intitialize

local function InitializeControls(parentControl)
	local Configuration = WG.Chobby.Configuration
	
	Label:New {
		x = 20,
		right = 5,
		y = 17,
		height = 20,
		font = Configuration:GetFont(3),
		caption = i18n("configure_commander"),
		parent = parentControl
	}
	
	
	local btnClose = Button:New {
		right = 11,
		y = 7,
		width = 80,
		height = 45,
		caption = i18n("close"),
		font = Configuration:GetFont(3),
		classname = "negative_button",
		OnClick = {
			function()
				parentControl:Hide()
			end
		},
		parent = parentControl
	}
	
	local informationPanel = ScrollPanel:New {
		x = 12,
		right = 12,
		y = 57,
		height = TOP_HEIGHT,
		horizontalScrollbar = false,
		padding = {4, 4, 4, 4},
		borderColor = {0,0,0,0},
		OnResize = {
			function(self, xSize, ySize)
				if ResizeFunction then
					ResizeFunction(xSize)
				end
			end
		},
		parent = parentControl,
	}
	
	local modulePanel = Control:New {
		x = 12,
		right = 12,
		y = 57 + TOP_HEIGHT + 4,
		bottom = 16,
		horizontalScrollbar = false,
		padding = {0, 0, 0, 0},
		borderColor = {0,0,0,0},
		OnResize = {
			function(self, xSize, ySize)
				if ResizeFunction then
					ResizeFunction(xSize)
				end
			end
		},
		parent = parentControl,
	}
	
	modulePanelHandler = MakeModulePanelHandler(modulePanel)
	
	local function UpdateCommanderDisplay()
		local commanderLevel, commanderName, commanderLoadout = WG.CampaignData.GetPlayerCommanderInformation()
		
		modulePanelHandler.UpdateLoadoutDisplay(commanderLevel, commanderName, commanderLoadout)
	end
	UpdateCommanderDisplay()
	
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Interface

local CommanderHandler = {}

function CommanderHandler.GetControl()

	local window = Control:New {
		name = "commanderHandler",
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		padding = {0, 0, 0, 0},
		OnParent = {
			function(obj)
				if obj:IsEmpty() then
					InitializeControls(obj)
				end
			end
		},
	}
	return window
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

function widget:Initialize()
	CHOBBY_DIR = LUA_DIRNAME .. "widgets/chobby/"
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)
	
	WG.CampaignData.AddListener("CampaignLoaded", UpdateAllUnlocks)
	WG.CampaignData.AddListener("RewardGained", UpdateAllUnlocks)
	
	WG.CommanderHandler = CommanderHandler
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------