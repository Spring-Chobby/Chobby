--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Community Window",
		desc      = "Handles community news and links.",
		author    = "GoogleFrog",
		date      = "14 December 2017",
		license   = "GNU LGPL, v2.1 or later",
		layer     = -100000,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Vars

local IMG_LINK = LUA_DIRNAME .. "images/link.png"
local IMG_MISSING = LUA_DIRNAME .. "images/minimapNotFound1.png"
local IMG_BULLET = LUA_DIRNAME .. "images/bullet.png"

local globalSizeMode = 2

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- News Update
local NEWS_FILE = "news/community.json"

local function LoadStaticCommunityData()
	if not VFS.FileExists(NEWS_FILE) then
		return {}
	end
	local data
	xpcall(
		function()
			data = Spring.Utilities.json.decode(VFS.LoadFile(NEWS_FILE))
		end,
		function(err)
			Spring.Log("community", LOG.ERROR, err)
			Spring.Log("community", LOG.ERROR, debug.traceback(err))
		end
	)
	return data or {}
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
		padding = {4, 4, 4, 4},
		--borderColor = hideBorder and {0,0,0,0},
		--OnResize = {
		--	function()
		--	end
		--},
		parent = holder
	}
end

local function LeaveIntentionallyBlank(scroll, caption)
	Label:New {
		x = 12,
		y = 10,
		width = 120,
		height = 20,
		align = "left",
		valign = "tp",
		font = WG.Chobby.Configuration:GetFont(1),
		caption = caption,
		parent = scroll
	}
end

local function AddLinkButton(scroll, name, tooltip, link, x, right, y, bottom)
	local button = Button:New {
		x = x,
		y = y,
		right = right,
		bottom = bottom,
		caption = name,
		tooltip = tooltip,
		classname = "option_button",
		align = "left",
		alignPadding = 0.12,
		font = WG.Chobby.Configuration:GetFont(3),
		OnClick = {
			function ()
				WG.BrowserHandler.OpenUrl(link)
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
-- Ladder Handler

local function GetLadderHandler(parentControl)
	local lobby = WG.LibLobby.lobby

	local holder = Control:New{
		x = 0,
		y = 0,
		right = 0,
		padding = {0,0,0,0},
		parent = parentControl,
	}
	local playerHolder = Control:New{
		x = 28,
		y = 30,
		right = 0,
		bottom = 0,
		padding = {0,0,0,0},
		parent = holder,
	}

	local heading = TextBox:New{
		x = 4,
		y = 7,
		right = 4,
		height = 24,
		align = "left",
		valign = "top",
		text = "Ladder",
		fontsize = WG.Chobby.Configuration:GetFont(3).size,
		parent = holder,
	}

	local numberBox = {}

	local externalFunctions = {}

	function externalFunctions.UpdateLadder(ladderEntries)
		local offset = 2
		playerHolder:ClearChildren()
		for i = 1, #ladderEntries do
			local data = ladderEntries[i]
			local lobbyData = {
				accountID = data.AccountID,
				icon = data.Icon,
				country = data.Country,
				clan = data.Clan
			}
			lobby:LearnAboutOfflineUser(data.Name, lobbyData)
			local user = WG.UserHandler.GetLadderUser(data.Name)

			user:SetPos(nil, offset)
			playerHolder:AddChild(user)

			if not numberBox[i] then
				numberBox[i] = Label:New{
					x = 1,
					y = offset + 32,
					width = 30,
					height = 24,
					align = "right",
					valign = "top",
					caption = i .. ". ",
					font = WG.Chobby.Configuration:GetFont(2),
					parent = holder,
				}
			end

			offset = offset + 26
		end

		holder:SetPos(nil, nil, nil, offset + 34)
	end

	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Tutorial

local TUTORIAL_PLANET = 69

local function StartTutorial()
	WG.CampaignSaveWindow.PromptInitialSaveName()
	WG.Chobby.interfaceRoot.OpenSingleplayerTabByName("campaign")
	WG.CampaignHandler.OpenPlanetScreen(TUTORIAL_PLANET)
	WG.CampaignHandler.StartPlanetMission(TUTORIAL_PLANET)
end

local function GetTutorialControl()
	local Configuration = WG.Chobby.Configuration
	
	local holder = Control:New {
		x = 0,
		y = 0,
		right = 0,
		height = 500,
	}
	
	local heading = Label:New {
		x = 0,
		y = 15,
		height = 35,
		align = "center",
		fontsize = Configuration:GetFont(5).size,
		caption = "Welcome to Zero-K",
		parent = holder,
	}

	TextBox:New {
		x = 8,
		right = 8,
		y = 76,
		height = 35,
		fontsize = Configuration:GetFont(2).size,
		text = [[Embark on a campaign, under 'Singleplayer & Coop', to uncover the secrets of a seemingly empty galaxy and learn Zero-K along the way. To begin, click 'Play the Tutorial' below. Alternately, play a full skirmish game with a range of non-cheating AIs. Play either option with friends by inviting them via the Steam friends list.]],
		parent = holder,
	}

	TextBox:New {
		x = 8,
		right = 8,
		y = 188,
		height = 35,
		fontsize = Configuration:GetFont(2).size,
		text = [[Click 'Multiplayer' for private games, public games, and the matchmaker. Say 'hi' on Discord or the forum, or even get into modding and development. Zero-K runs on involvement as it is entirely community-made.]],
		parent = holder,
	}

	local function CancelFunc()
		if not tutorialPrompt then
			local statusAndInvitesPanel = WG.Chobby.interfaceRoot.GetStatusAndInvitesPanel()
			tutorialPrompt = InitializeTutorialPrompt()
			statusAndInvitesPanel.AddControl(tutorialPrompt.GetHolder(), 15)
		end
	end

	local offset = 262
	Button:New {
		x = "18%",
		y = offset,
		right = "18%",
		height = 70,
		caption = "Play the Tutorial",
		font = Configuration:GetFont(4),
		classname = "action_button",
		padding = {2,4,4,4},
		OnClick = {
			function()
				StartTutorial()
			end
		},
		parent = holder,
	}
	offset = offset + 74

	--Button:New {
	--	right = 2,
	--	bottom = 2,
	--	width = 110,
	--	height = 42,
	--	classname = "negative_button",
	--	caption = i18n("close"),
	--	font = Configuration:GetFont(3),
	--	OnClick = {
	--		CancelFunc
	--	},
	--	parent = holder,
	--}
	
	local externalFunctions = {}
	
	function externalFunctions.GetHolder()
		return holder
	end
	
	function externalFunctions.DoResize()
		heading:SetPos(0, 15, holder.width)
		return 350
	end
	
	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- News

local function GetDateTimeDisplay(parentControl, xPosition, yPosition, timeString)
	local localTimeString = Spring.Utilities.ArchaicUtcToLocal(timeString, i18n)
	if localTimeString then
		localTimeString = localTimeString .. " local time."
	end
	local utcTimeString = string.gsub(timeString, "T", " at ") .. " UTC"

	local localStart = TextBox:New{
		x = xPosition,
		y = yPosition + 6,
		right = 4,
		height = 22,
		align = "left",
		valign = "top",
		text = localTimeString or utcTimeString, -- Fallback
		tooltip = string.gsub(timeString, "T", " at ") .. " UTC",
		fontsize = WG.Chobby.Configuration:GetFont(2).size,
		parent = parentControl,
	}

	local countdown = TextBox:New{
		x = xPosition,
		y = yPosition + 26,
		right = 4,
		height = 22,
		align = "left",
		valign = "top",
		tooltip = utcTimeString,
		fontsize = WG.Chobby.Configuration:GetFont(2).size,
		parent = parentControl,
	}

	-- Activate the tooltip.
	function localStart:HitTest(x,y) return self end
	function countdown:HitTest(x,y) return self end

	local externalFunctions = {
		visible = true
	}

	function externalFunctions.SetPosition(newY)
		localStart:SetPos(nil, newY + 6)
		countdown:SetPos(nil, newY + 26)
	end

	function externalFunctions.SetVisibility(visible)
		localStart:SetVisibility(visible)
		countdown:SetVisibility(visible)
		externalFunctions.visible = visible
	end

	function externalFunctions.UpdateCountdown()
		local difference, inTheFuture, isNow = Spring.Utilities.GetTimeDifference(timeString)
		if isNow then
			countdown:SetText("Starting " .. difference .. ".")
		elseif inTheFuture then
			countdown:SetText("Starting in " .. difference .. ".")
		else
			countdown:SetText( "Started " .. difference .. " ago.")
		end
	end
	externalFunctions.UpdateCountdown()

	return externalFunctions
end

local headingFormats = {
	[2] = {
		buttonSize = 28,
		height = 24,
		linkSize = 16,
		spacing = 2,
		buttonPos = 2,
		inButton = 4,
		paragraphSpacing = 0,
		topHeadingOffset = 30,
		imageSize = 120,
		buttonBot = 6,
	},
	[4] = {
		buttonSize = 40,
		height = 34,
		linkSize = 28,
		spacing = 16,
		buttonPos = 5,
		inButton = 7,
		paragraphSpacing = 30,
		topHeadingOffset = 50,
		imageSize = 120,
		buttonBot = 10,
	},
}

local function GetNewsEntry(parentHolder, index, headingSize, timeAsTooltip, showBulletHeading)
	local linkString
	local controls = {}

	local headFormat = headingFormats[headingSize]

	local holder = Control:New{
		x = 0,
		y = 0,
		right = 0,
		height = 500,
		padding = {0,0,0,0},
		parent = parentHolder,
	}

	local externalFunctions = {}

	function externalFunctions.AddEntry(entryData, parentPosition)
		local textPos = 6
		local headingPos = 2
		local offset = 0

		if showBulletHeading then
			if not controls.bullet then
				controls.bullet = Image:New{
					x = 2,
					y = offset + 5,
					width = 16,
					height = 16,
					file = IMG_BULLET,
					parent = holder,
				}
			end
			headingPos = 18
		end

		if entryData.link then
			linkString = entryData.link
			if not controls.linkButton then
				controls.linkButton = Button:New {
					x = headingPos,
					y = offset + 5,
					right = 2,
					height = headFormat.buttonSize,
					classname = "button_square",
					caption = "",
					padding = {0, 0, 0, 0},
					parent = holder,
					OnClick = {
						function ()
							WG.BrowserHandler.OpenUrl(linkString)
						end
					}
				}
			else
				controls.linkButton:SetVisibility(true)
			end

			if not controls.heading then
				controls.heading = TextBox:New{
					x = 4,
					y = headFormat.inButton,
					right = 4,
					height = headFormat.height,
					align = "left",
					valign = "top",
					text = entryData.heading,
					fontsize = WG.Chobby.Configuration:GetFont(headingSize).size,
					parent = controls.linkButton,
				}
			else
				controls.heading:SetText(entryData.heading)
			end

			-- Possibly looks nicer without link image.
			if not showBulletHeading then
				if not controls.linkImage then
					controls.linkImage = Image:New {
						x = 0,
						y = 5,
						width = headFormat.linkSize,
						height = headFormat.linkSize,
						keepAspect = true,
						file = IMG_LINK,
						parent = controls.linkButton,
					}
				end

				local length = controls.heading.font:GetTextWidth(entryData.heading)
				controls.linkImage:SetPos(length + 8)
			end

			if controls.freeHeading then
				controls.freeHeading:SetVisibility(false)
			end
		else
			if not controls.freeHeading then
				controls.freeHeading = TextBox:New{
					x = headingPos + 4,
					y = offset + 12,
					right = 4,
					height = headFormat.height,
					align = "left",
					valign = "top",
					text = entryData.heading,
					fontsize = WG.Chobby.Configuration:GetFont(4).size,
					parent = holder,
				}
			else
				controls.freeHeading:SetText(entryData.heading)
				controls.freeHeading:SetVisibility(true)
			end

			if controls.linkButton then
				controls.linkButton:SetVisibility(false)
			end
		end
		offset = offset + 40

		if entryData.imageFile then
			textPos = headFormat.imageSize + 12
			local imagePath = entryData.imageFile
			if not controls.image then
				controls.image = Image:New{
					name = "news" .. index,
					x = 4,
					y = offset + 6,
					width = headFormat.imageSize,
					height = headFormat.imageSize,
					keepAspect = true,
					checkFileExists = true,
					fallbackFile = IMG_MISSING,
					file = imagePath,
					parent = holder
				}
			else
				controls.image.file = imagePath
				controls.image:Invalidate()
				controls.image:SetVisibility(true)
			end
		elseif controls.image then
			controls.image:SetVisibility(false)
		end

		if entryData.atTime and not timeAsTooltip then
			if not controls.dateTime then
				controls.dateTime = GetDateTimeDisplay(holder, textPos, offset, entryData.atTime)
			else
				controls.dateTime.SetVisibility(true)
			end
			offset = offset + 45
		elseif controls.dateTime then
			controls.dateTime.SetVisibility(false)
		end

		if entryData.text then
			if not controls.text then
				controls.text = TextBox:New{
					x = textPos,
					y = offset + 6,
					right = 4,
					height = 120,
					align = "left",
					valign = "top",
					text = entryData.text,
					fontsize = WG.Chobby.Configuration:GetFont(2).size,
					parent = holder,
				}
			else
				controls.text:SetText(entryData.text)
				controls.text:SetVisibility(true)
				controls.text:SetPos(textPos, offset + 6)
				controls.text._relativeBounds.right = 4
				controls.text:UpdateClientArea(false)
			end
		elseif controls.text then
			controls.text:SetVisibility(false)
		end

		return parentPosition + offset
	end

	function externalFunctions.DoResize(parentPosition, numberVisible)
		if numberVisible < index then
			holder:SetVisibility(false)
			return parentPosition
		end
		holder:SetVisibility(true)

		local offset = 0

		if controls.bullet then
			controls.bullet:SetPos(nil, offset + 5)
		end

		local headingSize
		if controls.linkButton and controls.linkButton.visible then
			headingSize = (#controls.heading.physicalLines)*headFormat.fontSize
			controls.linkButton:SetPos(nil, offset + headFormat.buttonPos, nil, headingSize + headFormat.buttonBot)
			controls.heading:SetPos(nil, nil, nil, headingSize)
		elseif controls.freeHeading then
			headingSize = (#controls.freeHeading.physicalLines)*headFormat.fontSize
			controls.freeHeading:SetPos(nil, offset + 12, nil, headingSize)
		end
		offset = offset + headingSize + headFormat.spacing

		if controls.image and controls.image.visible then
			controls.image:SetPos(nil, offset + 6)
		end
		if controls.dateTime and controls.dateTime.visible then
			controls.dateTime.SetPosition(offset)
			offset = offset + 46
		end
		if controls.text and controls.text.visible then
			controls.text:SetPos(nil, offset + 6)
		end

		local offsetSize = (controls.text and (#controls.text.physicalLines)*18) or 6
		if controls.image and controls.image.visible and ((not controls.text) or (offsetSize < headFormat.imageSize - (controls.dateTime and 46 or 0))) then
			offsetSize = headFormat.imageSize - (controls.dateTime and 46 or 0)
		end

		holder:SetPos(nil, parentPosition, nil, offset + offsetSize + 10)
		return parentPosition + offset + offsetSize + headFormat.paragraphSpacing
	end

	function externalFunctions.UpdateCountdown()
		if controls.dateTime then
			controls.dateTime.UpdateCountdown()
		end
	end

	return externalFunctions
end

local function GetNewsHandler(parentControl, headingSize, timeAsTooltip, topHeading, showBulletHeading)
	local headFormat = headingFormats[headingSize]
	headFormat.fontSize = WG.Chobby.Configuration:GetFont(headingSize).size

	local offset = topHeading and headFormat.topHeadingOffset or 0
	local staticOffset = 0
	local visibleItems = 0
	local staticNotice

	local holder = Control:New{
		x = 0,
		y = 0,
		right = 0,
		padding = {0,0,0,0},
		parent = parentControl,
	}

	local topHeadingLabel = topHeading and TextBox:New{
		x = 4,
		y = 7,
		right = 4,
		height = headFormat.height,
		align = "left",
		valign = "top",
		text = topHeading,
		fontsize = WG.Chobby.Configuration:GetFont(3).size,
		parent = holder,
	}

	local newsEntries = {}

	local function DoResize()
		if staticNotice then
			staticOffset = staticNotice.DoResize()
		end
		offset = (topHeading and headFormat.topHeadingOffset or 0) + staticOffset
		for i = 1, #newsEntries do
			offset = newsEntries[i].DoResize(offset, visibleItems)
		end
		holder:SetPos(nil, nil, nil, offset - headFormat.paragraphSpacing/2)
	end

	local function UpdateCountdown()
		for i = 1, #newsEntries do
			newsEntries[i].UpdateCountdown()
		end
		WG.Delay(UpdateCountdown, 60)
	end

	local externalFunctions = {}

	function externalFunctions.ReplaceNews(items)
		if not items then
			visibleItems = 0
			DoResize()
			return
		end
		for i = 1, #items do
			local entry = {
				heading = items[i].Header,
				link = items[i].Url,
				atTime = items[i].Time,
				text = items[i].Text,
			}
			if items[i].Image then
				local imagePos = string.find(items[i].Image, "news")
				if imagePos then
					local imagePath = string.sub(items[i].Image, imagePos)
					if not VFS.FileExists(imagePath) then
						Spring.CreateDir("news")
						WG.WrapperLoopback.DownloadImage({ImageUrl = items[i].Image, TargetPath = imagePath})
					end
					entry.imageFile = imagePath
				end
			end

			if not newsEntries[i] then
				newsEntries[i] = GetNewsEntry(holder, i, headingSize, timeAsTooltip, showBulletHeading)
			end
			offset = newsEntries[i].AddEntry(entry, offset)
		end

		visibleItems = #items
		DoResize()
	end

	function externalFunctions.SetStaticNotice(noticeData)
		staticNotice = noticeData
		holder:AddChild(noticeData.GetHolder())
		DoResize()
	end

	-- Initialization
	UpdateCountdown()

	parentControl.OnResize = parentControl.OnResize or {}
	parentControl.OnResize[#parentControl.OnResize + 1] = function ()
		WG.Delay(DoResize, 0.01)
	end

	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Initialization

local function InitializeControls(window)
	-- Save space
	--Label:New {
	--	x = 15,
	--	y = 11,
	--	width = 180,
	--	height = 30,
	--	parent = window,
	--	font = WG.Chobby.Configuration:GetFont(3),
	--	caption = "Community",

	local lobby = WG.LibLobby.lobby
	local staticCommunityData = LoadStaticCommunityData()

	local topWide     = GetScroll(window, 0, 0, 0, "31%", true)
	local leftCenter  = GetScroll(window, 0, "66.6%", "69%", 0, false)
	local bottomRight = GetScroll(window, "33.4%", 0, "69%", 0, true)
	--local midCenter   = GetScroll(window, "33.4%", "33.4%", "69%", 0, true)
	--local rightCenter = GetScroll(window, "66.6%", 0, "69%", 0, true)
	
	--local lowerWide   = GetScroll(window, 0, 0, "69%", 0, true)
	--local leftLower   = GetScroll(window, 0, "33.4%", "69%", 0, false)
	--local rightLower  = GetScroll(window, "66.6%", 0, "69%", 0, false)
	--LeaveIntentionallyBlank(rightLower, "(reserved)")

	-- Populate link panel
	AddLinkButton(leftCenter, "Website",    "Visit the Zero-K website.", "http://zero-k.info/", 0, 0, "75.5%", 0)
	AddLinkButton(leftCenter, "Forum",   "Browse or post on the forums.", "http://zero-k.info/Forum",   0, 0, "25.5%", "50.5%")
	AddLinkButton(leftCenter, "Manual",  "Read the manual and unit guide.", "http://zero-k.info/mediawiki/index.php?title=Manual", 0, 0, "50.5%", "25.5%")
	AddLinkButton(leftCenter, "Discord", "Chat on the Zero-K Discord server.", "https://discord.gg/aab63Vt", 0, 0, 0, "75.5%")


	-- News Handler
	local newsHandler = GetNewsHandler(topWide, 4)
	if staticCommunityData and staticCommunityData.NewsItems then
		newsHandler.ReplaceNews(staticCommunityData.NewsItems)
	end

	if not WG.Chobby.Configuration.hideWelcomeMessage then
		local tutorialControl = GetTutorialControl()
		newsHandler.SetStaticNotice(tutorialControl)
	end

	local function OnNewsList(_, newsItems)
		newsHandler.ReplaceNews(newsItems)
	end
	lobby:AddListener("OnNewsList", OnNewsList)

	-- Forum Handler
	local forumHandler = GetNewsHandler(bottomRight, 2, true, "Recent Posts", true)
	if staticCommunityData and staticCommunityData.ForumItems then
		forumHandler.ReplaceNews(staticCommunityData.ForumItems)
	end

	local function OnForumList(_, forumItems)
		forumHandler.ReplaceNews(forumItems)
	end
	lobby:AddListener("OnForumList", OnForumList)

	-- Ladder Handler
	--local ladderHandler = GetLadderHandler(rightCenter)
	--if staticCommunityData and staticCommunityData.LadderItems then
	--	ladderHandler.UpdateLadder(staticCommunityData.LadderItems)
	--end
	--
	--local function OnLadderList(_, ladderItems)
	--	ladderHandler.UpdateLadder(ladderItems)
	--end
	--lobby:AddListener("OnLadderList", OnLadderList)

	-- Profile Handler
	--local profileHandle = GetProfileHandler(lowerWide)
	--local function OnUserProfile(_, profileData)
	--	profileHandle.UpdateProfile(profileData)
	--end
	--lobby:AddListener("OnUserProfile", OnUserProfile)

	--local function OnAccepted(listener)
	--	profileHandle.UpdateUserName()
	--end
	--lobby:AddListener("OnAccepted", OnAccepted)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Interface

local CommunityWindow = {}

function CommunityWindow.GetControl()

	local window = Control:New {
		name = "communityHandler",
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
				if ySize < 12750 then -- Never used
					globalSizeMode = 1
				else
					globalSizeMode = 2
				end
			end
		}
	}
	return window
end

CommunityWindow.LoadStaticCommunityData = LoadStaticCommunityData

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

function widget:ActivateGame()
	if not WG.Chobby.Configuration.firstBattleStarted then
		WG.Chobby.Configuration:SetConfigValue("firstBattleStarted", true)
	end
end

local function DelayedInitialize()
	--if WG.Chobby.Configuration.firstBattleStarted then
	WG.Chobby.interfaceRoot.OpenRightPanelTab("welcome")
	--end
end

function widget:Initialize()
	CHOBBY_DIR = LUA_DIRNAME .. "widgets/chobby/"
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)

	WG.Delay(DelayedInitialize, 0.6) -- After user handler

	WG.CommunityWindow = CommunityWindow
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
