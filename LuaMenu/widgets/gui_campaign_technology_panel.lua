--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Campaign Technology Panel",
		desc      = "Displays unlocked technology.",
		author    = "GoogleFrog",
		date      = "17 April 2017",
		license   = "GNU LGPL, v2.1 or later",
		layer     = 0,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Local Variables

local REWARD_ICON_SIZE = 58

local unitRewardList, moduleRewardList, abilityRewardList

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Utilities

local function GetIconPosition(index, iconsAcross)
	index = index - 1
	return index%iconsAcross*(REWARD_ICON_SIZE + 4), 26 + math.floor(index/iconsAcross)*(REWARD_ICON_SIZE + 4)
end

local function MakeRewardList(holder, name, rewardsList, tooltipFunction, UnlockedCheck, GetPosition)
	local Configuration = WG.Chobby.Configuration
	
	local unlockList = {}
	local iconsAcross = math.floor((holder.width - 16)/(REWARD_ICON_SIZE + 4))
	
	local position = (GetPosition and GetPosition()) or 5
	local height = 30 + math.ceil(#rewardsList/iconsAcross)*(REWARD_ICON_SIZE + 4)
	
	local rewardsHolder = Control:New {
		x = 10,
		y = position,
		right = 10,
		height = height,
		padding = {0, 0, 0, 0},
		parent = holder,
	}
	TextBox:New {
		x = 4,
		y = 2,
		right = 4,
		height = 30,
		text = name,
		font = Configuration:GetFont(3),
		parent = rewardsHolder
	}
	
	for i = 1, #rewardsList do
		local info, imageFile = tooltipFunction(rewardsList[i])
		local unlocked = UnlockedCheck(rewardsList[i])
		local statusString = ""
		local color
		if not unlocked then
			color = {0.5, 0.5, 0.5, 0.5}
			statusString = " (locked)"
		end
		
		local x, y = GetIconPosition(i, iconsAcross)
		local imageControl = Image:New{
			x = x,
			y = y,
			width = REWARD_ICON_SIZE,
			height = REWARD_ICON_SIZE,
			keepAspect = true,
			color = color,
			tooltip = (info.humanName or "???") .. statusString .. "\n " .. (info.description or ""),
			file = imageFile,
			parent = rewardsHolder,
		}
		function imageControl:HitTest(x,y) return self end
		
		unlockList[i] = {
			image = imageControl,
			name = rewardsList[i],
			humanName = info.humanName or "???",
			description = info.description or "",
			unlocked = unlocked,
		}
	end
	
	local function UpdateUnlocked(index)
		local data = unlockList[index]
		local unlocked = UnlockedCheck(data.name)
		if unlocked == data.unlocked then
			return
		end
		data.unlocked = unlocked
		
		local statusString = ""
		if not unlocked then
			color = {0.5, 0.5, 0.5, 0.5}
			statusString = " (locked)"
		end
		data.image.color = color
		data.image.tooltip = data.humanName .. statusString .. "\n " .. data.description
		data.image:Invalidate()
	end
	
	local externalFunctions = {}
	
	function externalFunctions.ResizeFunction(xSize)
		iconsAcross = math.floor((xSize - 16)/(REWARD_ICON_SIZE + 4))
		if GetPosition then
			position = GetPosition()
		end
		height = 30 + math.ceil(#unlockList/iconsAcross)*(REWARD_ICON_SIZE + 4)
		rewardsHolder:SetPos(nil, position, nil, height)
		for i = 1, #unlockList do
			local x, y = GetIconPosition(i, iconsAcross)
			unlockList[i].image:SetPos(x, y)
		end
	end
	
	function externalFunctions.UpdateUnlockedList()
		for i = 1, #unlockList do
			UpdateUnlocked(i)
		end
	end
	function externalFunctions.GetBottom()
		return position + height + 18
	end
	
	return externalFunctions
end

local function UpdateAllUnlocks()
	if unitRewardList then
		unitRewardList.UpdateUnlockedList()
	end
	if moduleRewardList then
		moduleRewardList.UpdateUnlockedList()
	end
	if abilityRewardList then
		abilityRewardList.UpdateUnlockedList()
	end
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
		caption = i18n("technology"),
		parent = parentControl
	}
	
	local ResizeFunction
	
	local scrollPanel = ScrollPanel:New {
		x = 12,
		right = 12,
		y = 57,
		bottom = 16,
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
	
	local unlockList = Configuration.campaignConfig.unlocksList
	unitRewardList = MakeRewardList(scrollPanel, "Units", unlockList.units.list, WG.CampaignData.GetUnitInfo, WG.CampaignData.GetUnitIsUnlocked)
	moduleRewardList = MakeRewardList(scrollPanel, "Modules", unlockList.modules.list, WG.CampaignData.GetModuleInfo, WG.CampaignData.GetModuleIsUnlocked, unitRewardList.GetBottom)
	abilityRewardList = MakeRewardList(scrollPanel, "Abilities", unlockList.abilities.list, WG.CampaignData.GetAbilityInfo, WG.CampaignData.GetAbilityIsUnlocked, moduleRewardList.GetBottom)
	
	function ResizeFunction(xSize)
		unitRewardList.ResizeFunction(xSize)
		moduleRewardList.ResizeFunction(xSize)
		abilityRewardList.ResizeFunction(xSize)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Interface

local TechnologyHandler = {}

function TechnologyHandler.GetControl()

	local window = Control:New {
		name = "technologyHandler",
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
	
	WG.TechnologyHandler = TechnologyHandler
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------