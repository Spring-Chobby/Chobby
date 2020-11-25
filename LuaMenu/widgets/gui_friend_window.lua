--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Friend Window",
		desc      = "Handles friends.",
		author    = "gajop",
		date      = "13 August 2016",
		license   = "GNU LGPL, v2.1 or later",
		layer     = -100000,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Controls

local function GetScroll(window, x, right, y, bottom, verticalScrollbar)
	local holder = Control:New {
		x = x,
		y = y,
		right = right,
		bottom = bottom,
		padding = {2, 2, 2, 2},
		parent = window
	}
	return ScrollPanel:New {
		x = 2,
		right = 2,
		y = 2,
		bottom = 2,
		horizontalScrollbar = false,
		verticalScrollbar = verticalScrollbar,
		padding = {0, 0, 0, 0},
		--borderColor = hideBorder and {0,0,0,0},
		--OnResize = {
		--	function()
		--	end
		--},
		parent = holder
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Profile

--{"Name":"GoogleFrog","Awards":[{"AwardKey":"cap","Collected":51},{"AwardKey":"reclaim","Collected":977},{"AwardKey":"pwn","Collected":1824},{"AwardKey":"vet","Collected":362},{"AwardKey":"kam","Collected":70},{"AwardKey":"ouch","Collected":952},{"AwardKey":"shell","Collected":267},{"AwardKey":"terra","Collected":278},{"AwardKey":"navy","Collected":77},{"AwardKey":"nux","Collected":16},{"AwardKey":"fire","Collected":133},{"AwardKey":"air","Collected":74},{"AwardKey":"emp","Collected":112},{"AwardKey":"share","Collected":4},{"AwardKey":"mex","Collected":758},{"AwardKey":"comm","Collected":84},{"AwardKey":"rezz","Collected":3},{"AwardKey":"friend","Collected":1},{"AwardKey":"head","Collected":8},{"AwardKey":"dragon","Collected":2},{"AwardKey":"sweeper","Collected":2},{"AwardKey":"heart","Collected":2},{"AwardKey":"mexkill","Collected":142},{"AwardKey":"slow","Collected":156},{"AwardKey":"silver","Collected":6},{"AwardKey":"bronze","Collected":3},{"AwardKey":"gold","Collected":1}],"Badges":["dev_adv","donator_0"],"Level":133,"LevelUpRatio":"0.69","EffectiveElo":2312,"EffectiveMmElo":2234,"EffectivePwElo":1670,"Kudos":724,"PwMetal":"5105.00","PwDropships":"74.00","PwBombers":"17.00","PwWarpcores":"0.00"}

local function GetAwardsHandler(parentControl, iconWidth, iconHeight, GetEntryData)
	local fontsize = WG.Chobby.Configuration:GetFont(1).size
	local imageList
	local externalFunctions = {}

	function externalFunctions.PositionAwards()
		if not imageList then
			return
		end

		local gridWidth = math.floor(parentControl.width/(iconWidth + 2))
		if gridWidth < 1 then
			return
		end

		for i = 1, #imageList do
			local x, y = (iconWidth + 2)*((i - 1)%gridWidth), (iconHeight + 2)*math.floor((i - 1)/gridWidth)
			imageList[i]:SetPos(x, y)
		end
	end

	function externalFunctions.SetAwards(awardsList)
		parentControl:ClearChildren()
		imageList = {}
		for i = 1, #awardsList do
			local imageName, count = GetEntryData(awardsList[i])
			imageList[i] = Image:New{
				width = iconWidth,
				height = iconHeight,
				keepAspect = true,
				file = imageName,
				parent = parentControl,
			}
			if count and count > 1 then
				Label:New {
					x = 2,
					y = "60%",
					right = 2,
					bottom = 6,
					align = "right",
					fontsize = fontsize,
					caption = count,
					parent = imageList[i],
				}
			end
		end
	end

	return externalFunctions
end

local function GetProfileHandler(parentControl)

	local holder = Control:New{
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		padding = {0,0,0,0},
		parent = parentControl,
	}
	local nameHolder = Control:New{
		x = "36%",
		y = "7%",
		right = 0,
		height = 28,
		padding = {0,0,0,0},
		parent = holder,
	}

	local awardsHandler, awardsLabel
	local GetAwardImage = WG.Chobby.Configuration.gameConfig.GetAward
	if GetAwardImage then
		local awardsHolder = Control:New{
			x = 10,
			y = "60%",
			right = 6,
			bottom = 0,
			padding = {0,0,0,0},
			parent = holder,
		}
		local function GetAwardInfo(entry)
			return GetAwardImage(entry.AwardKey), entry.Collected
		end
		awardsHandler = GetAwardsHandler(awardsHolder, 38, 38, GetAwardInfo)
	end

	local badgesHandler
	local badgeDecs = WG.Chobby.Configuration.gameConfig.badges
	if badgeDecs then
		local badgeHolder = Control:New{
			x = "42%",
			y = "46%",
			right = 0,
			height = 22,
			padding = {0,0,0,0},
			parent = holder,
		}
		local function GetBadgeInfo(entry)
			return (badgeDecs[entry] or {}).image
		end
		badgesHandler = GetAwardsHandler(badgeHolder, 46, 19, GetBadgeInfo)
	end

	local experienceBar, rankBar, backgroundImage

	local function MakeProgressBar(yPos, tooltip)
		local progressBar = Progressbar:New {
			x = "24%",
			y = yPos,
			right = "24%",
			height = 20,
			value = 0,
			max = 1,
			caption = "Level " .. 2,
			tooltip = tooltip,
			font = WG.Chobby.Configuration:GetFont(2),
			parent = holder,
		}
		function progressBar:HitTest(x,y) return self end
		return progressBar
	end

	local function DoResize()
		if awardsHandler then
			awardsHandler.PositionAwards()
		end
	end

	parentControl.OnResize = parentControl.OnResize or {}
	parentControl.OnResize[#parentControl.OnResize + 1] = function ()
		WG.Delay(DoResize, 0.01)
	end

	local externalFunctions = {}

	function externalFunctions.UpdateProfile(profileData)
		local level = profileData.Level
		local levelProgress = tonumber(profileData.LevelUpRatio) or 0
		local rank = profileData.Rank
		local rankProgress = tonumber(profileData.RankUpRatio) or 0

		experienceBar = experienceBar or MakeProgressBar("22%", "Your level. Play on the server to level up.")
		rankBar = rankBar or MakeProgressBar("34%", "Your skill rating and progress to the next rank.")

		experienceBar:SetCaption("Level " .. (level or "??"))
		experienceBar:SetValue(levelProgress)

		if awardsHandler and profileData.Awards then
			awardsHandler.SetAwards(profileData.Awards)
			awardsHandler.PositionAwards()
			if not awardsLabel then
				awardsLabel = Label:New {
					x = 5,
					y = "48%",
					width = 80,
					height = 22,
					align = "right",
					fontsize = WG.Chobby.Configuration:GetFont(2).size,
					caption = "Awards:",
					parent = holder,
				}
			end
		end
		if badgesHandler and profileData.Badges then
			badgesHandler.SetAwards(profileData.Badges)
			badgesHandler.PositionAwards()
		end

		local GetRankAndImage = WG.Chobby.Configuration.gameConfig.GetRankAndImage
		if rank and GetRankAndImage then
			local rankName, rankImage = GetRankAndImage(rank)

			rankBar:SetCaption(rankName)
			rankBar:SetValue(rankProgress or 0)
			backgroundImage = backgroundImage or Image:New{
				x = 0,
				y = 0,
				right = 0,
				bottom = 0,
				keepAspect = true,
				parent = holder,
			}
			backgroundImage.file = rankImage
			backgroundImage:Invalidate()
			backgroundImage:SendToBack()
		end
	end

	local userControl
	function externalFunctions.UpdateUserName()
		nameHolder:ClearChildren()
		userControl = WG.UserHandler.GetCommunityProfileUser(lobby:GetMyUserName())
		nameHolder:AddChild(userControl)
	end

	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Initialization

local function InitializeControls(window)
	local lobby = WG.LibLobby.lobby

	local upperHalf   = GetScroll(window, 0, 0, 0, "46%", false)
	local lowerHalf   = GetScroll(window, 0, 0, "56%", 0, false)
	
	WG.Chobby.FriendListWindow(lowerHalf)
	
	-- Profile Handler
	local profileHandle = GetProfileHandler(upperHalf)
	local function OnUserProfile(_, profileData)
		profileHandle.UpdateProfile(profileData)
	end
	lobby:AddListener("OnUserProfile", OnUserProfile)

	local function OnAccepted(listener)
		profileHandle.UpdateUserName()
	end
	lobby:AddListener("OnAccepted", OnAccepted)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Interface

local FriendWindow = {}

function FriendWindow.GetControl()
	local window = Control:New {
		name = "friendWindow",
		x = "0%",
		y = "0%",
		width = "100%",
		height = "100%",
		padding = {8, 8, 8, 12},
		OnParent = {
			function(obj)
				if obj:IsEmpty() then
					InitializeControls(obj)
				end
			end
		}
	}
	return window
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

local function DelayedInitialize()
end

function widget:Initialize()
	CHOBBY_DIR = LUA_DIRNAME .. "widgets/chobby/"
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)

	WG.Delay(DelayedInitialize, 1)

	WG.FriendWindow = FriendWindow
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
