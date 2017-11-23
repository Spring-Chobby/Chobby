--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Notification Handler",
		desc      = "Handles notification.",
		author    = "GoogleFrog",
		date      = "23 November 2017",
		license   = "GNU LGPL, v2.1 or later",
		layer     = -100000,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function AddListeners()
	local function OnRung(_, userName, message, sayTime, source)
		WG.WrapperLoopback.Alert(message)
	end
	lobby:AddListener("OnRung", OnRung)
end

function widget:Initialize()
	CHOBBY_DIR = LUA_DIRNAME .. "widgets/chobby/"
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)

	AddListeners()
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
