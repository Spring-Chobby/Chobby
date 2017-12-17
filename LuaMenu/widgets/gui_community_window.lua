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
		return
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
	return data
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
	
	-- Activate the tooltip.
	function localStart:HitTest(x,y) return self end
	function countdown:HitTest(x,y) return self end
	
	local externalFunctions = {}
	
	function externalFunctions.SetPosition(newY)
		localStart:SetPos(nil, newY + 6)
		countdown:SetPos(nil, newY + 26)
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
		paragraphSpacing = 1,
		topHeadingOffset = 30,
	},
	[4] = {
		buttonSize = 40,
		height = 34,
		linkSize = 28,
		spacing = 10,
		buttonPos = 5,
		inButton = 7,
		paragraphSpacing = 30,
		topHeadingOffset = 50,
	},
}

local function GetNewsHandler(parentControl, headingSize, timeAsTooltip, topHeading, showBulletHeading)
	local imageSize = 120
	local headFormat = headingFormats[headingSize]
	headFormat.fontSize = WG.Chobby.Configuration:GetFont(headingSize).size
	
	local offset = topHeading and headFormat.topHeadingOffset or 0
	
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
	
	local newsControls = {}
	
	local function DoResize()
		offset = topHeading and headFormat.topHeadingOffset or 0
		for i = 1, #newsControls do
			local controls = newsControls[i]
			
			if controls.bullet then
				controls.bullet:SetPos(nil, offset + 5)
			end
			
			local headingSize = (#controls.heading.physicalLines)*headFormat.fontSize
			if controls.linkButton then
				controls.linkButton:SetPos(nil, offset + headFormat.buttonPos, nil, headingSize + 4)
				controls.heading:SetPos(nil, nil, nil, headingSize)
			else
				controls.heading:SetPos(nil, offset + 12, nil, headingSize)
			end
			offset = offset + headingSize + headFormat.spacing
			
			if controls.image then
				controls.image:SetPos(nil, offset + 6)
			end
			if controls.dateTime then
				controls.dateTime.SetPosition(offset) 
				offset = offset + 46
			end
			if controls.text then
				controls.text:SetPos(nil, offset + 6)
			end
			
			local offsetSize = (controls.text and (#controls.text.physicalLines)*18) or 6
			if controls.image and ((not controls.text) or (offsetSize < imageSize - (controls.dateTime and 46 or 0))) then
				offsetSize = imageSize - (controls.dateTime and 46 or 0)
			end
			
			offset = offset + offsetSize + headFormat.paragraphSpacing
		end
		holder:SetPos(nil, nil, nil, offset - headFormat.paragraphSpacing/2)
	end
	
	local function UpdateCountdown()
		for i = 1, #newsControls do
			local controls = newsControls[i]
			if controls.dateTime then
				controls.dateTime.UpdateCountdown() 
			end
		end
		WG.Delay(UpdateCountdown, 60)
	end
	
	local externalFunctions = {}
	
	function externalFunctions.AddEntry(entryData)
		local controls = {}
		local textPos = 6
		local headingPos = 2
		
		if showBulletHeading then
			controls.bullet = Image:New{
				x = 2,
				y = offset + 5,
				width = 16,
				height = 16,
				file = IMG_BULLET,
				parent = holder,
			}
			headingPos = 18
		end
		
		if entryData.link then
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
						WG.BrowserHandler.OpenUrl(entryData.link)
					end
				}
			}

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
			
			-- Possibly looks nicer without link image.
			if not showBulletHeading then
				local linkImage = Image:New {
					x = 0,
					y = 5,
					width = headFormat.linkSize,
					height = headFormat.linkSize,
					keepAspect = true,
					file = IMG_LINK,
					parent = controls.linkButton,
				}
				
				local length = controls.heading.font:GetTextWidth(entryData.heading)
				linkImage:SetPos(length + 8)
			end
		else
			controls.heading = TextBox:New{
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
		end
		offset = offset + 40
		
		if entryData.imageFile then
			textPos = imageSize + 12
			local imagePath = entryData.imageFile
			if not VFS.FileExists(imagePath) then
				controls.wantImage = imagePath
				imagePath = IMG_MISSING
			end
			controls.image = Image:New{
				x = 4,
				y = offset + 6,
				width = imageSize,
				height = imageSize,
				keepAspect = true,
				file = imagePath,
				parent = holder
			}
		end
		
		if entryData.atTime and not timeAsTooltip then
			controls.dateTime = GetDateTimeDisplay(holder, textPos, offset, entryData.atTime)
			offset = offset + 45
		end
		
		if entryData.text then
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
		end
		
		newsControls[#newsControls + 1] = controls
		DoResize()
	end
	
	function externalFunctions.Clear()
		-- Hopefully this eventually disposes of the controls.
		holder:ClearChildren()
		if topHeadingLabel then
			holder:AddChild(topHeadingLabel)
		end
		newsControls = {}
	end
	
	function externalFunctions.ReloadImages()
		for i = 1, #newsControls do
			local controls = newsControls[i]
			if controls.wantImage and controls.image and VFS.FileExists(controls.wantImage) then
				controls.image.file = controls.wantImage
				controls.image:Invalidate()
			end
		end
	end
	
	function externalFunctions.ReplaceNews(items)
		externalFunctions.Clear()
		
		for i = 1, #items do
			local entry = {
				heading = items[i].Header,
				link = items[i].Url,
				atTime = items[i].Time,
				text = items[i].Text,
			}
			if items[i].Image then
				local imagePos = string.find(items[i].Image, "news")
				local imagePath = string.sub(items[i].Image, imagePos)
				if not VFS.FileExists(imagePath) then
					WG.WrapperLoopback.DownloadImage({ImageUrl = items[i].Image, TargetPath = imagePath})
				end
				entry.imageFile = imagePath
			end
			externalFunctions.AddEntry(entry)
		end
	end
	
	-- Initialization
	UpdateCountdown()
	
	local function ImageDownloadFinished()
		WG.Delay(newsHandler.ReloadImages, 2)
	end
	WG.DownloadHandler.AddListener("ImageDownloadFinished", ImageDownloadFinished)
	
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
	
	local topWide     = GetScroll(window, 0, 0, 0, "60%", true)
	local leftCenter  = GetScroll(window, 0, "66.6%", "40%", "31%", false)
	local midCenter   = GetScroll(window, "33.4%", "33.4%", "40%", "31%", true)
	local rightCenter = GetScroll(window, "66.6%", 0, "40%", "31%", false)
	local leftLower   = GetScroll(window, 0, "33.4%", "69%", 0, false)
	local rightLower  = GetScroll(window, "66.6%", 0, "69%", 0, false)
	
	LeaveIntentionallyBlank(rightCenter, "Ladder (TODO)")
	LeaveIntentionallyBlank(leftLower, "Profile (TODO)")
	LeaveIntentionallyBlank(rightLower, "(reserved)")
	
	-- Populate link panel
	AddLinkButton(leftCenter, "Discord", "Chat on the Zero-K Discord server.", "https://discord.gg/aab63Vt", 0, 0, 0, "75.5%")
	AddLinkButton(leftCenter, "Forum",   "Browse or post on the forums.", "http://zero-k.info/Forum",   0, 0, "25.5%", "50.5%")
	AddLinkButton(leftCenter, "Manual",  "Read the manual and unit guide.", "http://zero-k.info/mediawiki/index.php?title=Manual", 0, 0, "50.5%", "25.5%")
	AddLinkButton(leftCenter, "Replays", "Watch replays of online games.", "http://zero-k.info/Battles", 0, 0, "75.5%", 0)
	
	-- News Handler
	local newsHandler = GetNewsHandler(topWide, 4)
	if staticCommunityData and staticCommunityData.NewsItems then
		newsHandler.ReplaceNews(staticCommunityData.NewsItems)
	end
	
	local function OnNewsList(_, newsItems)
		newsHandler.ReplaceNews(newsItems)
	end
	
	lobby:AddListener("OnNewsList", OnNewsList)
	
	-- Forum Handler
	local forumHandler = GetNewsHandler(midCenter, 2, true, "Recent Posts", true)
	if staticCommunityData and staticCommunityData.ForumItems then
		forumHandler.ReplaceNews(staticCommunityData.ForumItems)
	end
	
	local function OnForumList(_, forumItems)
		forumHandler.ReplaceNews(forumItems)
	end
	
	lobby:AddListener("OnForumList", OnForumList)
	
	-- Ladder Handler
	
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
