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

local globalSizeMode = 2
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
	
	local function UpdateCountdown()
		local difference, inTheFuture, isNow = Spring.Utilities.GetTimeDifference(timeString)
		if isNow then
			countdown:SetText("Starting " .. difference .. ".")
		elseif inTheFuture then
			countdown:SetText("Starting in " .. difference .. ".")
		else
			countdown:SetText( "Started " .. difference .. " ago.")
		end
		
		WG.Delay(UpdateCountdown, 60)
	end
	UpdateCountdown()
	
	-- Activate the tooltip.
	function localStart:HitTest(x,y) return self end
	function countdown:HitTest(x,y) return self end
	
	local externalFunctions = {}
	
	function externalFunctions.SetPosition(newY)
		localStart:SetPos(nil, newY + 6)
		countdown:SetPos(nil, newY + 26)
	end
	
	return externalFunctions
end

local function GetNewsHandler(parentControl)
	local offset = 0
	local imageSize = 120
	local paragraphSpacing = 30
	
	local holder = Control:New{
		x = 0,
		y = 0,
		right = 0,
		padding = {0,0,0,0},
		parent = parentControl,
	}
	
	local newsControls = {}
	
	local function DoResize()
		offset = 0
		for i = 1, #newsControls do
			local controls = newsControls[i]
			if controls.linkButton then
				controls.linkButton:SetPos(nil, offset + 5)
			else
				controls.heading:SetPos(nil, offset + 12)
			end
			offset = offset + 44
			
			if controls.image then
				controls.image:SetPos(nil, offset + 6)
			end
			if controls.dateTime then
				controls.dateTime.SetPosition(offset)
				offset = offset + 46
			end
			controls.text:SetPos(nil, offset + 6)
			
			local offsetSize = (#controls.text.physicalLines)*18
			if controls.image and (offsetSize < imageSize - (controls.dateTime and 46 or 0)) then
				offsetSize = imageSize - (controls.dateTime and 46 or 0)
			end
			
			offset = offset + offsetSize + paragraphSpacing
		end
		holder:SetPos(nil, nil, nil, offset - paragraphSpacing/2)
	end
	
	local externalFunctions = {}
	
	function externalFunctions.AddEntry(entryData)
		local controls = {}
		local textPos = 6
		
		if entryData.link then
			controls.linkButton = Button:New {
				x = 2,
				y = offset + 5,
				right = 2,
				height = 40,
				classname = "button_square",
				caption = "",
				padding = {0, 0, 0, 0},
				parent = holder,
				OnClick = {
					function ()
						WG.BrowserHandler.OpenUrl(entryData.link)
					end
				}
			}

			controls.heading = TextBox:New{
				x = 4,
				y = 7,
				right = 4,
				height = 34,
				align = "left",
				valign = "top",
				text = entryData.heading,
				fontsize = WG.Chobby.Configuration:GetFont(4).size,
				parent = controls.linkButton,
			}
			
			-- Possibly looks nicer without link image.
			local linkImage = Image:New {
				x = 0,
				y = 5,
				width = 28,
				height = 28,
				keepAspect = true,
				file = IMG_LINK,
				parent = controls.linkButton,
			}
			
			local length = controls.heading.font:GetTextWidth(entryData.heading)
			linkImage:SetPos(length + 8)
		else
			controls.heading = TextBox:New{
				x = textPos,
				y = offset + 12,
				right = 4,
				height = 34,
				align = "left",
				valign = "top",
				text = entryData.heading,
				fontsize = WG.Chobby.Configuration:GetFont(4).size,
				parent = holder,
			}
		end
		offset = offset + 44
		
		if entryData.imageFile then
			textPos = imageSize + 12
			
			controls.image = Image:New{
				x = 4,
				y = offset + 6,
				width = imageSize,
				height = imageSize,
				keepAspect = true,
				file = entryData.imageFile,
				parent = holder
			}
		end
		
		if entryData.atTime then
			controls.dateTime = GetDateTimeDisplay(holder, textPos, offset, entryData.atTime)
			offset = offset + 45
		end
		
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
		
		newsControls[#newsControls + 1] = controls
		DoResize()
	end
	
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
	--}
	
	local newsHolder  = GetScroll(window, 0, 0, 0, "60%", true)
	local leftCenter  = GetScroll(window, 0, "66.6%", "40%", "31%", false)
	local midCenter   = GetScroll(window, "33.4%", "33.4%", "40%", "31%", false)
	local rightCenter = GetScroll(window, "66.6%", 0, "40%", "31%", false)
	local leftLower   = GetScroll(window, 0, "33.4%", "69%", 0, false)
	local rightLower  = GetScroll(window, "66.6%", 0, "69%", 0, false)
	
	LeaveIntentionallyBlank(midCenter, "Forum (TODO)")
	LeaveIntentionallyBlank(rightCenter, "Ladder (TODO)")
	LeaveIntentionallyBlank(leftLower, "Profile (TODO)")
	LeaveIntentionallyBlank(rightLower, "(reserved)")
	
	AddLinkButton(leftCenter, "Discord", "Chat on the Zero-K Discord server.", "https://discord.gg/aab63Vt", 0, 0, 0, "75.5%")
	AddLinkButton(leftCenter, "Forum",   "Browse or post on the forums.", "http://zero-k.info/Forum",   0, 0, "25.5%", "50.5%")
	AddLinkButton(leftCenter, "Manual",  "Read the manual and unit guide.", "http://zero-k.info/mediawiki/index.php?title=Manual", 0, 0, "50.5%", "25.5%")
	AddLinkButton(leftCenter, "Replays", "Watch replays of online games.", "http://zero-k.info/Battles", 0, 0, "75.5%", 0)
	
	local newsDefs = {
		{
			imageFile = LUA_DIRNAME .. "images/news/tournmentNews.png",
			heading = "December 1v1 Tournament",
			link = "http://zero-k.info/Forum/Thread/24531",
			atTime = "2017-12-16T10:00:00",
			text = "There will be a 1v1 tournament this weekend. All participants will play seven rounds of Swiss, followed by elimination amoung the top four to determine an overall winner. Click the link above to sign up in the forum thread.",
		},
		{
			imageFile = LUA_DIRNAME .. "images/news/newRating.png",
			heading = "New Rating System",
			link = "http://zero-k.info/Forum/Thread/24536",
			text = "We have recently switched to a new rating system. Elo is being replaced by Whole History Rating. Although generally very similar to the old ratings, this means that rating values have changed for every player. See the full thread for more information.",
		},
		{
			imageFile = LUA_DIRNAME .. "images/news/communityNews.png",
			heading = "New Community Tab",
			text = "By scrolling down to the bottom of the news window you have explored the entirety of the current community tab. The aim of the tab is to get people move involved in events, forums and chat, all in the name of community building. The remaining panels are a work in progress so feel free to suggest a panel that you would like to see here.",
		},
	}
	
	local newsHandler = GetNewsHandler(newsHolder)
	for i = 1, #newsDefs do
		newsHandler.AddEntry(newsDefs[i])
	end
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
				if ySize < 650 then
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
	
end

function widget:Initialize()
	CHOBBY_DIR = LUA_DIRNAME .. "widgets/chobby/"
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)

	WG.Delay(DelayedInitialize, 1)

	WG.CommunityWindow = CommunityWindow
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
