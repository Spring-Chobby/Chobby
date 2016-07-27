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

local function InitializeControls(window)
	local font = WG.Chobby.Configuration:GetFont(2)
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

	onUpdateUserTeamStatusSelf = function(listener, userName, allyNumber, isSpectator)
		if not userName == lobby:GetMyUserName() then
			return
		end
	end
	lobby:AddListener("OnUpdateUserTeamStatus", onUpdateUserTeamStatusSelf)

	onLeftBattle = function(listener, leftBattleID, userName)
		if userName == lobby:GetMyUserName() then
			battleStatus = nil
			lblPlayerStatus:SetCaption("")
		end
	end
	lobby:AddListener("OnLeftBattle", onLeftBattle)
end

function BattleStatusPanel.GetControl()
	local button = Button:New {
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
	return button
end


function widget:Initialize()
	
	VFS.Include("LuaUI/widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)

	WG.BattleStatusPanel = BattleStatusPanel
end

function widget:Shutdown()
	if lobby then
		lobby:RemoveListener("OnUpdateUserTeamStatus", onUpdateUserTeamStatusSelf)
	end
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
