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

local function InitializeControls(parentControl)
	local font = WG.Chobby.Configuration:GetFont(3)
	local lblPlayerStatus = Label:New {
		x = 15,
		width = 120,
		y = 15,
		height = 20,
		align = "left",
		valign = "center",
		caption = "Battle",
		parent = parentControl,
		font = font,
	}
	local infoHolder = Panel:New {
		x = 85,
		right = 5,
		y = 5,
		bottom = 5,
		parent = parentControl,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
	}
	
	parentControl.OnResize = parentControl.OnResize or {}
	parentControl.OnResize[#parentControl.OnResize + 1] = function (obj, xSize, ySize)
		local smallMode = (ySize < 60)
		if smallMode then
			lblPlayerStatus:SetPos(nil, 13)
		else
			lblPlayerStatus:SetPos(nil, 25)
		end
	end

	onUpdateUserTeamStatusSelf = function(listener, userName, allyNumber, isSpectator)
		if not userName == lobby:GetMyUserName() then
			return
		end
	end
	lobby:AddListener("OnUpdateUserTeamStatus", onUpdateUserTeamStatusSelf)
end

function BattleStatusPanel.GetControl()
	local button = Button:New {
		x = 0,
		y = 0,
		width = 500,
		bottom = 0,
		padding = {0,0,0,0},
		caption = "",
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
