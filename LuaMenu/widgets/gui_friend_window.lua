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
-- Vars

local friendPanel
local profilePanel

local globalSizeMode = 2

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Controls

local function GetScroll(window, x, right, y, bottom, verticalScrollbar, customPadding)
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
		padding = customPadding or {4, 4, 4, 4},
		--borderColor = hideBorder and {0,0,0,0},
		--OnResize = {
		--	function()
		--	end
		--},
		parent = holder
	}
end

local function AddLinkButton(scroll, name, tooltip, link, requireLogin, x, right, y, bottom)
	local button = Button:New {
		x = x,
		y = y,
		right = right,
		bottom = bottom,
		caption = name,
		tooltip = tooltip,
		classname = "option_button",
		font = WG.Chobby.Configuration:GetFont(3),
		align = "left",
		alignPadding = 0.075,
		OnClick = {
			function ()
				WG.BrowserHandler.OpenUrl(link, requireLogin, requireLogin)
			end
		},
		OnResize = {
			function(obj, xSize, ySize)
				if globalSizeMode == 2 then
					ButtonUtilities.SetFontSizeScale(obj, 4)
				else
					ButtonUtilities.SetFontSizeScale(obj, 3)
				end
			end
		},
		parent = scroll,
	}
	ButtonUtilities.SetFontSizeScale(button, 3)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Profile

--{"Name":"GoogleFrog","Awards":[{"AwardKey":"cap","Collected":51},{"AwardKey":"reclaim","Collected":977},{"AwardKey":"pwn","Collected":1824},{"AwardKey":"vet","Collected":362},{"AwardKey":"kam","Collected":70},{"AwardKey":"ouch","Collected":952},{"AwardKey":"shell","Collected":267},{"AwardKey":"terra","Collected":278},{"AwardKey":"navy","Collected":77},{"AwardKey":"nux","Collected":16},{"AwardKey":"fire","Collected":133},{"AwardKey":"air","Collected":74},{"AwardKey":"emp","Collected":112},{"AwardKey":"share","Collected":4},{"AwardKey":"mex","Collected":758},{"AwardKey":"comm","Collected":84},{"AwardKey":"rezz","Collected":3},{"AwardKey":"friend","Collected":1},{"AwardKey":"head","Collected":8},{"AwardKey":"dragon","Collected":2},{"AwardKey":"sweeper","Collected":2},{"AwardKey":"heart","Collected":2},{"AwardKey":"mexkill","Collected":142},{"AwardKey":"slow","Collected":156},{"AwardKey":"silver","Collected":6},{"AwardKey":"bronze","Collected":3},{"AwardKey":"gold","Collected":1}],"Badges":["dev_adv","donator_0"],"Level":133,"LevelUpRatio":"0.69","EffectiveElo":2312,"EffectiveMmElo":2234,"EffectivePwElo":1670,"Kudos":724,"PwMetal":"5105.00","PwDropships":"74.00","PwBombers":"17.00","PwWarpcores":"0.00"}

local function GetAwardsHandler(parentControl, iconWidth, iconHeight, iconSpacing, textOffset, GetEntryData, centerAlign)
	local fontsize = WG.Chobby.Configuration:GetFont(1).size
	local imageList, labelList
	local externalFunctions = {}

	function externalFunctions.PositionAwards()
		if not imageList then
			return
		end

		local gridWidth = math.floor(parentControl.width/(iconWidth + iconSpacing))
		if gridWidth < 1 then
			return
		end

		local leftEdge = 0
		if centerAlign then
			local awardCount = math.min(gridWidth, #imageList)
			leftEdge = (parentControl.width - (iconWidth*awardCount + iconSpacing*(awardCount - 1)))/2
			--Spring.Echo("awardCount", awardCount, "pw", parentControl.width, "icon", iconWidth*awardCount + iconSpacing*(awardCount - 1), "le", leftEdge)
		end

		for i = 1, #imageList do
			local x, y = (iconWidth + iconSpacing)*((i - 1)%gridWidth) + leftEdge, (iconHeight + textOffset + iconSpacing)*math.floor((i - 1)/gridWidth)
			imageList[i]:SetPos(x, y)
			
			if labelList[i] then
				labelList[i]:SetPos(x, y + iconHeight - 1, iconWidth + 4) -- Width makes align work correctly.
			end
		end
	end

	function externalFunctions.SetAwards(awardsList)
		parentControl:ClearChildren()
		imageList = {}
		labelList = {}
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
				labelList[i] = Label:New {
					width = iconWidth + 4,
					height = fontsize,
					align = "center",
					fontsize = fontsize,
					caption = count,
					parent = parentControl,
				}
			end
		end
	end

	return externalFunctions
end

local function GetProfileHandler()
	local holder = Control:New{
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		padding = {0,0,0,0},
	}
	local awardsHolder = Control:New{
		x = 10,
		y = "53%",
		right = 6,
		bottom = 0,
		padding = {0,0,0,0},
		parent = holder,
	}
	local topHolder = Control:New{
		x = 0,
		y = "8%",
		right = 0,
		bottom = "47%",
		parent = holder,
	}
	local nameHolder = Control:New{
		x = "36%",
		y = 0,
		right = 0,
		height = 28,
		padding = {0,0,0,0},
		parent = topHolder,
	}

	local awardsHandler, awardsLabel
	local GetAwardImage = WG.Chobby.Configuration.gameConfig.GetAward
	if GetAwardImage then
		local awardsListHolder = Control:New{
			x = 14,
			y = 32,
			right = 10,
			bottom = 0,
			padding = {2,2,2,2},
			parent = awardsHolder,
		}
		local function GetAwardInfo(entry)
			return GetAwardImage(entry.AwardKey), entry.Collected
		end
		awardsHandler = GetAwardsHandler(awardsListHolder, 30, 40, 5, 12, GetAwardInfo, false)
	end

	local badgesHandler
	local badgeDecs = WG.Chobby.Configuration.gameConfig.badges
	if badgeDecs then
		local badgeHolder = Control:New{
			x = 0,
			right = 0,
			height = 44,
			bottom = 0,
			padding = {2,2,2,2},
			parent = topHolder,
		}
		local function GetBadgeInfo(entry)
			return (badgeDecs[entry] or {}).image
		end
		badgesHandler = GetAwardsHandler(badgeHolder, 100, 40, 4, 0, GetBadgeInfo, true)
	end

	local experienceBar, rankBar, backgroundImage

	local function MakeProgressBar(yPos, tooltip)
		local progressBar = Progressbar:New {
			x = "24%",
			y = yPos,
			right = "24%",
			height = 26,
			value = 0,
			max = 1,
			caption = "Level " .. 2,
			tooltip = tooltip,
			font = WG.Chobby.Configuration:GetFont(2),
			parent = topHolder,
		}
		function progressBar:HitTest(x,y) return self end
		return progressBar
	end

	local function DoResize()
		if awardsHandler then
			awardsHandler.PositionAwards()
		end
		if badgesHandler then
			badgesHandler.PositionAwards()
		end
	end

	local externalFunctions = {}

	function externalFunctions.UpdateProfile(profileData)
		local level = profileData.Level
		local levelProgress = tonumber(profileData.LevelUpRatio) or 0
		local rank = profileData.Rank
		local rankProgress = tonumber(profileData.RankUpRatio) or 0

		experienceBar = experienceBar or MakeProgressBar("24%", "Your level. Play games on the server to level up.")
		rankBar = rankBar or MakeProgressBar("48%", "Your skill rating and progress to the next rank.")

		experienceBar:SetCaption("Level " .. (level or "??"))
		experienceBar:SetValue(levelProgress)

		if awardsHandler and profileData.Awards then
			awardsHandler.SetAwards(profileData.Awards)
			awardsHandler.PositionAwards()
			if not awardsLabel then
				awardsLabel = Label:New {
					x = 5,
					y = 5,
					width = 80,
					height = 22,
					align = "right",
					fontsize = WG.Chobby.Configuration:GetFont(2).size,
					caption = "Awards:",
					parent = awardsHolder,
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
	
	function externalFunctions.SetParent(parentControl)
		parentControl:AddChild(holder)
		
		parentControl.OnResize = parentControl.OnResize or {}
		parentControl.OnResize[#parentControl.OnResize + 1] = function ()
			WG.Delay(DoResize, 0.01)
		end
	end

	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Initialization

local function InitializeControls(window)
	if not friendPanel then
		return
	end

	local upperHalf   = GetScroll(window, 0, 0, 0, "38.5%", false, {0, 0, 0, 0})
	local lowerLeft   = GetScroll(window, 0, "50%", "61.5%", 0, false)
	local lowerRight  = GetScroll(window, "50%", 0, "61.5%", 0, false, {0, 0, 0, 0})

	profilePanel.SetParent(upperHalf)
	lowerRight:AddChild(friendPanel.window)

	--https://zero-k.info/Clans
	--https://zero-k.info/My/Commanders
	--https://zero-k.info/Battles?Title=&Map=&PlayersFrom=&PlayersTo=&Age=0&Mission=0&Bots=0&Rank=8&Victory=0&UserId=15114
	--https://zero-k.info/Charts/Ratings?RatingCategory=1&UserId=15114
	--https://zero-k.info/Forum?CategoryID=&Search=&OnlyUnread=false&User=GoogleFrog&grorder=&grdesc=False&grpage=1

	-- Populate link panel
	AddLinkButton(lowerLeft, "Com Loadout", "Edit custom commanders for use in games on the Zero-K server.",
		"https://zero-k.info/My/Commanders", true, 0, 0, 0, "80.5%")
	AddLinkButton(lowerLeft, "Ladder Ratings",  "View detailed ladder statistics and charts.",
		"https://zero-k.info/Charts/Ratings?RatingCategory=1&UserId=_USER_ID_", true, 0, 0, "20.5%", "60.5%")
	AddLinkButton(lowerLeft, "Replay List",     "View and comment on your recent games on the Zero-K server.",
		"https://zero-k.info/Battles?Title=&Map=&PlayersFrom=&PlayersTo=&Age=0&Mission=0&Bots=0&Rank=8&Victory=0&UserId=_USER_ID_", true, 0, 0, "40.5%", "40.5%")
	AddLinkButton(lowerLeft, "Recent Posts",    "View your recently posted in forum threads.",
		"https://zero-k.info/Forum?CategoryID=&Search=&OnlyUnread=false&User=_USER_NAME_&grorder=&grdesc=False&grpage=1", true, 0, 0, "60.5%", "20.5%")
	AddLinkButton(lowerLeft, "Clan List",       "View the list of clans.",
		"https://zero-k.info/Clans", false, 0, 0, "80.5%", 0)
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
		},
		OnResize = {
			function(obj, xSize, ySize)
				if ySize < 750 then
					globalSizeMode = 1
				else
					globalSizeMode = 2
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
	local lobby = WG.LibLobby.lobby
	friendPanel = WG.Chobby.FriendListWindow()
	
	profilePanel = GetProfileHandler()
	local function OnUserProfile(_, profileData)
		profilePanel.UpdateProfile(profileData)
	end
	lobby:AddListener("OnUserProfile", OnUserProfile)

	local function OnAccepted(listener)
		profilePanel.UpdateUserName()
	end
	lobby:AddListener("OnAccepted", OnAccepted)
end

function widget:Initialize()
	CHOBBY_DIR = LUA_DIRNAME .. "widgets/chobby/"
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)

	WG.Delay(DelayedInitialize, 0.2)

	WG.FriendWindow = FriendWindow
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
