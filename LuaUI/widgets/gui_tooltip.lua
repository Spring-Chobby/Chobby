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
local USER_MP_TOOLTIP_PREFIX = "user_tooltip_"

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
-- Tooltip maintence

local function GetTooltip()
	if screen0.currentTooltip then -- this gives chili absolute priority, otherwise TraceSreenRay() would ignore the fact ChiliUI is underneath the mouse
		return screen0.currentTooltip
	end
end

local function SetTooltipPos()
	local text         = tipTextDisplay.text
	local x,y          = spGetMouseState()
	local height,decender,numLines = tipTextDisplay.font:GetTextHeight(text)
	local height       = numLines * 14 + 8 + 7
	local width        = tipTextDisplay.font:GetTextWidth(text) + 10
	
	x = x + 20
	y = screenHeight - y -- Spring y is from the bottom, chili is from the top

	-- Making sure the tooltip is within the boundaries of the screen
	y = (y + height > screenHeight) and (y - height) or (y + 20)
	x = (x + width > screenWidth) and (screenWidth - width) or x

	tipWindow:SetPos(x, y, width, height)
   
	if tipWindow.hidden then tipWindow:Show() end
	tipWindow:BringToFront()
end

local function UpdateTooltip(inputText)
	if inputText:starts(USER_TOOLTIP_PREFIX) then
		local userName, myLobby 
		if inputText:starts(USER_MP_TOOLTIP_PREFIX) then
			userName = string.sub(inputText, 14)
			myLobby = lobby
		else
			userName = string.sub(inputText, 27)
			myLobby = WG.LibLobby.lobbySkirmish
		end
		local userInfo = myLobby:GetUser(userName) or {}
		local userBattleInfo = myLobby:GetUserBattleStatus(userName) or {}
	
		local text = userName
		for key, value in pairs(userInfo) do
			text = text .. "\n" .. key .. " = " .. tostring(value)
		end
		for key, value in pairs(userBattleInfo) do
			text = text .. "\n" .. key .. " = " .. tostring(value)
		end
	
		tipTextDisplay:SetText(text)
		tipTextDisplay:UpdateLayout()
	elseif inputText:starts(BATTLE_TOOLTIP_PREFIX) then
		local battleID = tonumber(string.sub(inputText, 16))
		local battle = lobby:GetBattle(battleID) or {}
		
		local text = "Battle " .. battleID
		for key, value in pairs(battle) do
			text = text .. "\n" .. key .. " = " .. tostring(value)
		end
		
		tipTextDisplay:SetText(text)
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

