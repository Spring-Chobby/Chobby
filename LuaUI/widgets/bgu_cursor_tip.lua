-- WIP
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

local Chili, screen, tipWindow, tip
local mousePosX, mousePosY
local oldTime
local tipType = false
local tooltip = ''
local ID

local spGetGameFrame            = Spring.GetGameFrame
local spGetTimer                = Spring.GetTimer
local spDiffTimers              = Spring.DiffTimers
local spTraceScreenRay          = Spring.TraceScreenRay
local spGetMouseState           = Spring.GetMouseState
local screenWidth, screenHeight = Spring.GetWindowGeometry()
-----------------------------------
function firstToUpper(str)
	-- make the first char of a string into upperCase
	return (str:gsub("^%l", string.upper))
end
-----------------------------------
local function initWindow()
	tipWindow = Chili.Window:New{
		parent    = screen,
		width     = 75,
		height    = 75,
		minHeight = 1,
		padding   = {5,4,4,4},
	}
	tip = Chili.TextBox:New{
		parent = tipWindow, 
		x      = 0,
		y      = 0,
		right  = 0, 
		bottom = 0,
		margin = {0,0,0,0},
		font = {            
			outline          = true,
			autoOutlineColor = true,
			outlineWidth     = 3,
			outlineWeight    = 4,
		}
	}
	
	oldTime = spGetTimer()
	tipWindow:Hide()
end

function widget:ViewResize(vsx, vsy)
	screenWidth = vsx
	screenHeight = vsy
end

-----------------------------------
local unitTooltip = "Right click to switch between unit info/properties"
local function getTooltip()
	if screen.currentTooltip then -- this gives chili absolute priority, otherwise TraceSreenRay() would ignore the fact ChiliUI is underneath the mouse
		tipType = 'chili'
		return screen.currentTooltip
	elseif WG.Prospector and WG.Prospector.tooltip then
		tipType = 'prospector'
		return WG.Prospector.tooltip
	else
		tipType, ID = spTraceScreenRay(spGetMouseState())
		
		if tipType == 'unit' and #Spring.GetSelectedUnits()==0 then
			return unitTooltip --sInfo shows 'tooltips' for units (and features)
		else
			tipType = false
			return ''
		end
	end
end
-----------------------------------
local function setTooltipPos(text)
	local text         = text or tip.text
	local x,y          = spGetMouseState()
	local _,_,numLines = tip.font:GetTextHeight(text)
	local height       = numLines * 14 + 8
	local width        = tip.font:GetTextWidth(text) + 10
	
	x = x + 20
	y = screenHeight - y -- Spring y is from the bottom, chili is from the top

	-- Making sure the tooltip is within the boundaries of the screen
	y = (y > screenHeight * .75) and (y - height) or (y + 20)
	x = (x + width > screenWidth) and (screenWidth - width) or x

	tipWindow:SetPos(x, y, width, height)
   
	if tipWindow.hidden then tipWindow:Show() end
	tipWindow:BringToFront()
end
-----------------------------------
function widget:Update()
	local curTime = spGetTimer()
	local text = getTooltip()
	
	if text and (tip.text ~= text) then
		tip:SetText(text)
		oldTime = spGetTimer()
		if not tipType and tipWindow.visible then 
			tipWindow:Hide()
		end
	elseif tipType and (tipWindow.visible or spDiffTimers(curTime, oldTime) > 1 or tipType == 'chili' or tipType == 'prospector') then
		setTooltipPos(text)
	end
end
-----------------------------------
function widget:Initialize()
	if not WG.Chili then return end
	Chili = WG.Chili
	screen = Chili.Screen0
	initWindow()
end

function widget:Shutdown()
	tipWindow:Dispose()
end

