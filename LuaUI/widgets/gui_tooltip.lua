function widget:GetInfo()
	return {
		name    = 'Cursor tooltip',
		desc    = 'Provides a tooltip whilst hovering the mouse',
		author  = 'Funkencool',
		date    = '2013',
		license = 'GNU GPL v2',
		layer   = 0,
		enabled = true,
	}
end

local mousePosX, mousePosY
local tipWindow, tipTextDisplay

local spGetGameFrame            = Spring.GetGameFrame
local spGetMouseState           = Spring.GetMouseState
local screenWidth, screenHeight = Spring.GetWindowGeometry()

local BATTLE_TOOLTIP_PREFIX = "battle_tooltip_"
local USER_TOOLTIP_PREFIX = "user_"
local USER_SP_TOOLTIP_PREFIX = "user_singleplayer_tooltip_"
local USER_MP_TOOLTIP_PREFIX = "user_battleroom_tooltip_"
local USER_CHAT_TOOLTIP_PREFIX = "user_tooltip_"

local TOOLTIP_TEXT_NAME = "tooltipText"

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Initialization

local function InitWindow()
	tipWindow = Chili.Window:New{
		parent    = screen0,
		width     = 75,
		height    = 75,
		minHeight = 1,
		resizable = false,
		draggable = false,
		padding   = {5,4,4,4},
	}
	tipTextDisplay = Chili.TextBox:New{
		name   = TOOLTIP_TEXT_NAME,
		x      = 0,
		y      = 0,
		right  = 0, 
		bottom = 0,
		parent = tipWindow, 
		margin = {0,0,0,0},
		font = {            
			outline          = true,
			autoOutlineColor = true,
			outlineWidth     = 3,
			outlineWeight    = 4,
		}
	}
	
	tipWindow:Hide()
end

function widget:ViewResize(vsx, vsy)
	screenWidth = vsx
	screenHeight = vsy
end

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Specific tooltip type utilities
local battleTooltip = {}
local userTooltip = {}

local function GetTooltipLine(parent, hasImage)
	local text, image
	
	local externalFunctions = {}
	
	if hasImage then
		image = Image:New {
			x = 6,
			y = 0,
			width = 19,
			height = 19,
			parent = parent,
			keepAspect = true,
			file = nil,
		}
	end
	
	text = TextBox:New {
		x = (hasImage and 29) or 6,
		y = 0,
		right = 0,
		height = 20,
		align = "left",
		parent = parent,
		fontsize = WG.Chobby.Configuration:GetFont(2).size,
		text = "",
	}
	
	function externalFunctions.Update(newPosition, newText, newImage)
		if not text.visible then
			text:Show()
		end
		text:SetText(newText)
		text:SetPos(nil, newPosition)
		if hasImage then
			if not image.visible then
				image:Show()
			end
			image.file = newImage
			image:SetPos(nil, newPosition - 4)
			image:Invalidate()
		end
	end
	
	function externalFunctions.UpdatePosition(newPosition)
		if not text.visible then
			text:Show()
			text:SetPos(nil, newPosition)
		end
		if hasImage and not image.visible then
			image:Show()
			image:SetPos(nil, newPosition - 4)
		end
	end
	
	function externalFunctions.Hide()
		if text.visible then
			text:Hide()
		end
		if hasImage and image.visible then
			image:Hide()
		end
	end
	
	return externalFunctions
end

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Battle tooltip

local function GetBattleTooltip(battleID, battle)
	local Configuration = WG.Chobby.Configuration
	
	if not battleTooltip.mainControl then
		
		battleTooltip.mainControl = Chili.Control:New {
			x = 0,
			y = 0,
			width = 140,
			height = 120,
			padding = {0, 0, 0, 0},
		}
		
	end
	
	--local text = "Battle " .. battleID
	--for key, value in pairs(battle) do
	--	text = text .. "\n" .. key .. " = " .. tostring(value)
	--end
	return battleTooltip.mainControl
end

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- User tooltip

local IMAGE_MODERATOR = "luaui/images/ranks/moderator.png"

local function GetUserTooltip(userName, userInfo, userBattleInfo, inBattleroom)
	local Configuration = WG.Chobby.Configuration
	
	if not userTooltip.mainControl then
		userTooltip.mainControl = Chili.Control:New {
			x = 0,
			y = 0,
			width = 140,
			height = 120,
			padding = {0, 0, 0, 0},
		}
	end
	local offset = 7
	local width = 160
	
	-- User Name
	if not userTooltip.name then
		userTooltip.name = GetTooltipLine(userTooltip.mainControl)
	end
	userTooltip.name.Update(offset, userName)
	offset = offset + 20
	
	-- Clan
	if userInfo.clan then
		if not userTooltip.clan then
			userTooltip.clan = GetTooltipLine(userTooltip.mainControl)
		end
		userTooltip.clan.Update(offset, userInfo.clan)
		offset = offset + 20
	elseif userTooltip.clan then
		userTooltip.clan.Hide()
	end
	
	-- Country
	if userInfo.country then
		if not userTooltip.country then
			userTooltip.country = GetTooltipLine(userTooltip.mainControl, true)
		end
		userTooltip.country.Update(
			offset, 
			Configuration:GetCountryLongname(userInfo.country), 
			WG.UserHandler.CountryShortnameToFlag(userInfo.country)
		)
		offset = offset + 20
	elseif userTooltip.country then
		userTooltip.country:Hide()
	end
	
	-- Moderator
	if userInfo.isAdmin then
		if not userTooltip.moderator then
			userTooltip.moderator = GetTooltipLine(userTooltip.mainControl, true)
			userTooltip.moderator.Update(
				offset, 
				"Moderator", 
				IMAGE_MODERATOR
			)
		end
		userTooltip.moderator.UpdatePosition(offset)
		offset = offset + 20
	elseif userTooltip.moderator then
		userTooltip.moderator:Hide()
	end
	
	-- Level
	if userInfo.level or userBattleInfo.aiLib then
		if not userTooltip.level then
			userTooltip.level = GetTooltipLine(userTooltip.mainControl, true)
		end
		local isBot = (userInfo.isBot or userBattleInfo.aiLib)
		local text
		if userInfo.isBot then
			text = "Autohost"
		elseif userBattleInfo.aiLib then
			text = "AI: " .. userBattleInfo.aiLib
		else
			text = "Level: " .. userInfo.level
		end
		
		userTooltip.level.Update(
			offset, 
			text,
			WG.UserHandler.UserLevelToImage(userInfo.level, isBot)
		)
		offset = offset + 20
	elseif userTooltip.level then
		userTooltip.level:Hide()
	end
	
	-- Debug Mode
	if Configuration.debugMode then
		offset = offset + 50
		width = 250
		
		if not userTooltip.debugText then
			userTooltip.debugText = Chili.TextBox:New{
				x      = 5,
				y      = 200,
				right  = 5, 
				bottom = 5,
				parent = tipWindow, 
				margin = {0,0,0,0},
				font = {            
					outline          = true,
					autoOutlineColor = true,
					outlineWidth     = 3,
					outlineWeight    = 4,
				},
				parent = userTooltip.mainControl,
			}
		end
		userTooltip.debugText:SetPos(nil, offset)
		
		if not userTooltip.debugText.parent then
			userTooltip.mainControl:AddChild(userTooltip.debugText)
		end
		
		local text = userName
		for key, value in pairs(userInfo) do
			text = text .. "\n" .. key .. " = " .. tostring(value)
		end
		for key, value in pairs(userBattleInfo) do
			text = text .. "\n" .. key .. " = " .. tostring(value)
		end
		Spring.Echo("set text", text)
		userTooltip.debugText:SetText(text)
		userTooltip.debugText:UpdateLayout()
		local _, _, numLines = userTooltip.debugText.font:GetTextHeight(text)
		local height = numLines * 14 + 8 + 7
		
		offset = offset + height
	elseif userTooltip.debugText and userTooltip.debugText.parent then
		userTooltip.mainControl:RemoveChild(userTooltip.debugText)
	end
	
	userTooltip.mainControl:SetPos(nil, nil, width, offset)
	
	return userTooltip.mainControl
end

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Tooltip maintence

local function GetTooltip()
	if screen0.currentTooltip then -- this gives chili absolute priority, otherwise TraceSreenRay() would ignore the fact ChiliUI is underneath the mouse
		return screen0.currentTooltip
	end
end

local function SetTooltipPos()
	local tooltipChild = tipWindow.children[1]
	if not tooltipChild then
		if tipWindow.visible then 
			tipWindow:Hide()
		end
		return
	end
	
	local x,y = spGetMouseState()
	local width,height

	if tooltipChild.name == TOOLTIP_TEXT_NAME then
		local text = tipTextDisplay.text
		local _, _, numLines = tipTextDisplay.font:GetTextHeight(text)
		
		width  = tipTextDisplay.font:GetTextWidth(text) + 10
		height = numLines * 14 + 8 + 7
	else
		-- Fudge numbers correspond to padding
		width, height = tooltipChild.width + 9, tooltipChild.height + 8
	end
	
	x = x + 20
	y = screenHeight - y -- Spring y is from the bottom, chili is from the top

	-- Making sure the tooltip is within the boundaries of the screen
	y = (y + height > screenHeight) and (y - height) or (y + 20)
	x = (x + width > screenWidth) and (screenWidth - width) or x

	tipWindow:SetPos(x, y, width, height)
   
	if tipWindow.hidden then 
		tipWindow:Show() 
	end
	tipWindow:BringToFront()
end

local function UpdateTooltip(inputText)
	if inputText:starts(USER_TOOLTIP_PREFIX) then
		local userName, myLobby, inBattleroom
		if inputText:starts(USER_SP_TOOLTIP_PREFIX) then
			userName = string.sub(inputText, 27)
			myLobby = WG.LibLobby.lobbySkirmish
			inBattleroom = true
		else
			userName = string.sub(inputText, 14)
			myLobby = lobby
			if inputText:starts(USER_MP_TOOLTIP_PREFIX) then
				inBattleroom = true
			end
		end
		local userInfo = myLobby:GetUser(userName) or {}
		local userBattleInfo = myLobby:GetUserBattleStatus(userName) or {}
		
		local tooltipControl = GetUserTooltip(userName, userInfo, userBattleInfo, inBattleroom)
		
		tipWindow:ClearChildren()
		tipWindow:AddChild(tooltipControl)
		
	elseif inputText:starts(BATTLE_TOOLTIP_PREFIX) then
		local battleID = tonumber(string.sub(inputText, 16))
		local battle = lobby:GetBattle(battleID) or {}
		
		local tooltipControl = GetBattleTooltip(battleID, battle)
		
		tipWindow:ClearChildren()
		tipWindow:AddChild(tooltipControl)
		
	else -- For everything else display a normal tooltip
		tipWindow:ClearChildren()
		tipTextDisplay:SetText(text)
		tipWindow:AddChild(tipTextDisplay)
		tipTextDisplay:UpdateLayout()
	end
end

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Widget callins

function widget:Update()
	local text = GetTooltip()
	if text then
		if tipTextDisplay.text ~= text then
			UpdateTooltip(text)
		end
		SetTooltipPos()
	else
		if tipWindow.visible then 
			tipWindow:Hide()
		end
	end
end

function widget:Initialize()
	CHOBBY_DIR = "LuaUI/widgets/chobby/"
	VFS.Include("LuaUI/widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)
	
	InitWindow()
end

function widget:Shutdown()
	tipWindow:Dispose()
end

