--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Battle status panel",
		desc      = "Displays battles status.",
		author    = "gajop",
		date      = "4 July 2016",
		license   = "GNU LGPL, v2.1 or later",
		layer     = 0,
		enabled   = true  --  loaded by default?
	}
end

------------------------------------------------------------------
------------------------------------------------------------------
-- Chili
local imPlayerStatus

------------------------------------------------------------------
------------------------------------------------------------------
-- Lobby listeners

local onUpdateUserTeamStatusSelf

------------------------------------------------------------------
------------------------------------------------------------------
-- Initialization

local BattleStatusPanel = {}

local battleStatus = nil

-- TODO: globalize
local backgroundColorSuccess = {0.47, 0.84, 0.45, 0.4}
local backgroundColorInfo    = {0.47, 0.44, 0.85, 0.4}

local updateDir = 0.004
local plusAmount = 0.4
-- TODO: zz cleanup
function widget:Update()
	if battleStatus == nil then
		return
	end
	if updateDir > 0 then
		if plusAmount <= 0 then
			plusAmount = -0.2
			updateDir = -updateDir
		else
			plusAmount = plusAmount - updateDir
		end
	else
		if plusAmount >= 0 then
			plusAmount = 0.2
			updateDir = -updateDir
		else
			plusAmount = plusAmount - updateDir
		end
	end
	imPlayerStatus.color[1] = imPlayerStatus.color[1] + updateDir
	imPlayerStatus.color[2] = imPlayerStatus.color[2] + updateDir
	imPlayerStatus.color[3] = imPlayerStatus.color[3] + updateDir
	imPlayerStatus:Invalidate()
end

local function InitializeControls(window)
	local font = WG.Chobby.Configuration:GetFont(2)
-- 	font.color = foregroundColorSuccess
	local lblPlayerStatus = Label:New {
		x = 100,
		width = 480-100,
		y = 0,
		height = 40,
		align = "center",
		valign = "center",
		caption = "",
		parent = window,
		font = font,
	}
	-- FIXME: this is stupid
	local IMAGE_BLANK = "luaui/images/blank.png"
	imPlayerStatus = Image:New {
		x = 100,
		width = 480-100,
		y = 0,
		height = 50,
		file = IMAGE_BLANK,
		keepAspect = false,
		parent = window,
		color = backgroundColorSuccess,
	}
	imPlayerStatus:SetVisibility(false)

	onUpdateUserTeamStatusSelf = function(listener, userName, allyNumber, isSpectator)
		if userName == lobby:GetMyUserName() then
			if isSpectator then
				battleStatus = "spec"
				lblPlayerStatus:SetCaption(i18n("spectating_game_status"))
				imPlayerStatus.color = {0.47, 0.44, 0.85, 0.4}
				updateDir = 0.004
				plusAmount = 0.4
				if imPlayerStatus.hidden then
					imPlayerStatus:SetVisibility(true)
				end
			else
				battleStatus = "play"
				lblPlayerStatus:SetCaption(i18n("playing_game_status"))
				imPlayerStatus.color = {0.47, 0.84, 0.45, 0.4}
				updateDir = 0.004
				plusAmount = 0.4
				if imPlayerStatus.hidden then
					imPlayerStatus:SetVisibility(true)
				end
			end
		end
	end
	lobby:AddListener("OnUpdateUserTeamStatus", onUpdateUserTeamStatusSelf)

	onLeftBattle = function(listener, leftBattleID, userName)
		if userName == lobby:GetMyUserName() then
			battleStatus = nil
			lblPlayerStatus:SetCaption("")
			imPlayerStatus:SetVisibility(false)
		end
	end
	lobby:AddListener("OnLeftBattle", onLeftBattle)
end

function BattleStatusPanel.GetControl()
	local window = Control:New {
		x = 0,
		y = 0,
		width = 500,
		height = 50,
		padding = {0,0,0,0},
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


function widget:Initialize()
	
	VFS.Include("LuaUI/widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)

	WG.BattleStatusPanel = BattleStatusPanel

	-- TODO: This should probably be moved elsewhere
	WG.Delay(BattleStatusPanel.GetControl, 0.01)
end

function widget:Shutdown()
	if lobby then
		lobby:RemoveListener("OnUpdateUserTeamStatus", onUpdateUserTeamStatusSelf)
	end
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
