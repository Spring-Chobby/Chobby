--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Download Window",
		desc      = "Handles download visuals.",
		author    = "GoogleFrog",
		date      = "19 July 2016",
		license   = "GNU LGPL, v2.1 or later",
		layer     = -100000,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Local Variables

local completedDownloadPosition = 0
local itemSpacing = 28
local parentWindow
local completedMaps

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Utilities

local function DownloadUpdateFunction(downloadCount, failure)
	local interfaceRoot = WG.Chobby and WG.Chobby.interfaceRoot
	if not interfaceRoot then
		return
	end
	interfaceRoot.GetRightPanelHandler().SetActivity("downloads", downloadCount)
end

local function DownloadCompleteFunction(name, success)
	local text = name
	if not success then
		text = text .. WG.Chobby.Configuration:GetErrorColor() .. " Failed"
	end

	Label:New {
		x = 15,
		y = completedDownloadPosition,
		width = 180,
		height = 30,
		parent = parentWindow,
		font = WG.Chobby.Configuration:GetFont(2),
		caption = text,
		parent = completedMaps,
	}
	completedDownloadPosition = completedDownloadPosition + itemSpacing
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Initialization

local initialized = false

local function InitializeControls(window)
	initialized = true

	Label:New {
		x = 15,
		y = 11,
		width = 180,
		height = 30,
		parent = window,
		font = WG.Chobby.Configuration:GetFont(3),
		caption = "Downloads",
	}

	Label:New {
		x = 15,
		y = 360,
		width = 180,
		height = 30,
		parent = window,
		font = WG.Chobby.Configuration:GetFont(3),
		caption = "Complete",
	}
	
	completedMaps = ScrollPanel:New {
		x = 5,
		right = 5,
		y = 395,
		bottom = 8,
		borderColor = {0, 0, 0, 0},
		horizontalScrollbar = false,
		parent = window,
	}

end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Interface

local DownloadWindow = {}

function DownloadWindow.GetControl()
	local window = Control:New {
		x = "0%",
		y = "0%",
		width = "100%",
		height = "100%",
		OnParent = {
			function(obj)
				if not initialized then
					InitializeControls(obj)
				end
			end
		},
	}

	local downloader = WG.Chobby.Downloader(
		{
			x = 20,
			height = 260,
			right = 40,
			y = 85,
			parent = window,
		},
		false,
		DownloadUpdateFunction,
		DownloadCompleteFunction,
		2
	)

	parentWindow = window

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

	WG.DownloadWindow = DownloadWindow
end

function widget:Shutdown()
	if WG.LibLobby then
		-- RemoveListener
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
