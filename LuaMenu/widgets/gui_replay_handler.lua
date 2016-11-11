--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Replays window",
		desc      = "Handles local replays.",
		author    = "GoogleFrog",
		date      = "20 October 2016",
		license   = "GNU LGPL, v2.1 or later",
		layer     = -100000,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Local Variables


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Utilities

local function CreateReplayEntry(replayPath, engineName)
	local Configuration = WG.Chobby.Configuration
	
	local fileName = string.sub(replayPath, 7)
	local engineStart = string.find(fileName, engineName, 15)
	if not engineStart then
		-- Don't show replays of the wrong engine
		return
	end
	
	local mapName = string.gsub(string.sub(fileName, 17, engineStart - 2), "_", " ")
	local replayTime = string.sub(fileName, 0, 15)
	replayTime = string.sub(fileName, 0, 4) .. "-" .. string.sub(fileName, 5, 6) .. "-" .. string.sub(fileName, 7, 8) .. " at " .. string.sub(fileName, 10, 11) .. ":" .. string.sub(fileName, 12, 13) .. ":" .. string.sub(fileName, 14, 15)
	
	local replayPanel = Panel:New {
		x = 0,
		y = 0,
		width = "100%",
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
	}
	
	local startButton = Button:New {
		x = 3,
		y = 3,
		bottom = 3,
		width = 65,
		caption = i18n("start"),
		classname = "action_button",
		font = WG.Chobby.Configuration:GetFont(2),
		OnClick = {
			function()
				WG.Chobby.localLobby:StartReplay(replayPath)
			end
		},
		parent = replayPanel,
	}
	
	local replayDate = TextBox:New {
		name = "replayDate",
		x = 85,
		y = 12,
		right = 0,
		height = 20,
		valign = 'center',
		fontsize = Configuration:GetFont(2).size,
		text = replayTime,
		parent = replayPanel,
	}
	local replayMap = TextBox:New {
		name = "replayMap",
		x = 305,
		y = 12,
		right = 0,
		height = 20,
		valign = 'center',
		fontsize = Configuration:GetFont(2).size,
		text = mapName,
		parent = replayPanel,
	}
	local replayName = TextBox:New {
		name = "replayName",
		x = 535,
		y = 5,
		right = 0,
		height = 20,
		valign = 'center',
		fontsize = Configuration:GetFont(2).size,
		text = fileName,
		parent = replayPanel,
	}
	
	return replayPanel, {replayTime, string.lower(mapName), fileName}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Controls

local function InitializeControls(parentControl)
	local Configuration = WG.Chobby.Configuration
	
	Label:New {
		x = 15,
		y = 11,
		width = 180,
		height = 30,
		parent = parentControl,
		font = Configuration:GetFont(3),
		caption = "Replays",
	}
	
	-------------------------
	-- Replay List
	-------------------------
	
	local listHolder = Control:New {
		x = 12,
		right = 15,
		y = 52,
		bottom = 15,
		parent = parentControl,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
	}
	
	local headings = {
		{name = "Time", x = 88, width = 207},
		{name = "Map", x = 300, width = 225},
		{name = "Name", x = 530, right = 5},
	}
	
	local engineName = Game.version
	engineName = string.gsub(engineName, "%.", "%%%.")
	engineName = string.gsub(engineName, "%-", "%%%-")
	local replayList = WG.Chobby.SortableList(listHolder, headings)
	
	local function AddReplays()
		local items = {}
		local replays = VFS.DirList("demos")
		
		for	i = 1, #replays do
			local replayPath = replays[i]
			local control, sortData = CreateReplayEntry(replayPath, engineName)
			if control then
				items[#items + 1] = {replayPath, control, sortData}
			end
		end	
		
		replayList:AddItems(items)
	end
		
	AddReplays()
	
	-------------------------
	-- Buttons
	-------------------------
	
	Button:New {
		x = 100,
		y = 5,
		width = 100,
		height = 38,
		caption = i18n("refresh"),
		font = Configuration:GetFont(3),
		classname = "option_button",
		parent = parentControl,
		OnClick = {
			function ()
				AddReplays()
			end
		},
	}
		
	if WG.WrapperLoopback and Configuration.gameConfig.link_replays then
		Button:New {
			x = 210,
			y = 5,
			width = 210,
			height = 38,
			caption = i18n("download_replays"),
			font = Configuration:GetFont(3),
			classname = "option_button",
			parent = parentControl,
			OnClick = {
				function ()
					WG.WrapperLoopback.OpenUrl(Configuration.gameConfig.link_replays())
				end
			},
		}
	end
	
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Interface

local ReplayHandler = {}

function ReplayHandler.GetControl()

	local window = Control:New {
		name = "replayHandler",
		x = "0%",
		y = "0%",
		width = "100%",
		height = "100%",
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

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

local function DelayedInitialize()
	local Configuration = WG.Chobby.Configuration
	battleStartDisplay = Configuration.game_fullscree
end

function widget:Initialize()
	CHOBBY_DIR = LUA_DIRNAME .. "widgets/chobby/"
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)

	WG.Delay(DelayedInitialize, 1)

	WG.ReplayHandler = ReplayHandler
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------