--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Missions Handles",
		desc      = "Handles missions.",
		author    = "GoogleFrog",
		date      = "24 November 2016",
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

local function LoadMissions()
	local path = "missions/missions.json"
	if VFS.FileExists(path) then
		local file = VFS.LoadFile(path)
		return Spring.Utilities.json.decode(file)
	end
	Spring.Echo("Error loading missions.")
	return false
end

local function CreateMissionEntry(missionData)
	local Configuration = WG.Chobby.Configuration
	
	local holder = Panel:New {
		x = 0,
		y = 0,
		width = "100%",
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
	}
	
	local imagePanel = Panel:New {
		x = 2,
		y = 2,
		width = 76,
		height = 76,
		padding = {1,1,1,1},
		parent = holder,
	}
	local imageFile = (missionData.MissionID and "missions/" .. missionData.MissionID .. ".png")
	if imageFile then
		local image = Image:New {
			name = "image",
			x = 0,
			y = 0,
			right = 0,
			bottom = 0,
			keepAspect = true,
			file = imageFile,
			parent = imagePanel,
		}
	end
	
	local startButton = Button:New {
		x = 86,
		y = 36,
		width = 65,
		height = 34,
		caption = i18n("play"),
		classname = "action_button",
		font = WG.Chobby.Configuration:GetFont(2),
		OnClick = {
			function()
				local startScript = missionData.Script
			
				startScript = startScript:gsub("%%MAP%%", missionData.Map)
				startScript = startScript:gsub("%%MOD%%",  WG.Chobby.Configuration.gameConfig.defaultGameArchiveName)
				startScript = startScript:gsub("%%NAME%%", WG.Chobby.localLobby:GetMyUserName())
				
				WG.Chobby.localLobby:StartGameFromStringg(startScript)
			end
		},
		parent = holder,
	}
	
	local missionName = TextBox:New {
		name = "missionName",
		x = 86,
		y = 8,
		right = 0,
		height = 20,
		valign = 'center',
		fontsize = Configuration:GetFont(3).size,
		text = missionData.DisplayName,
		parent = holder,
	}
	local missionDifficulty = TextBox:New {
		name = "missionDifficulty",
		x = 170,
		y = 42,
		right = 0,
		height = 20,
		valign = 'center',
		fontsize = Configuration:GetFont(2).size,
		text = string.format("Difficulty %.1f", missionData.Difficulty),
		parent = holder,
	}
	local missionMap = TextBox:New {
		name = "missionMap",
		x = 320,
		y = 42,
		right = 0,
		height = 20,
		valign = 'center',
		fontsize = Configuration:GetFont(2).size,
		text = missionData.Map,
		parent = holder,
	}
	
	return holder, {missionData.DisplayName, missionData.Difficulty, missionData.Map}
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
		caption = "Missions",
	}
	
	local missions = LoadMissions()
	
	if not missions then
		local missingPanel = Panel:New {
			classname = "overlay_window",
			x = "10%",
			y = "45%",
			right = "10%",
			bottom = "45%",
			parent = parentControl,
		}
		
		local missingLabel = Label:New {
			x = "5%",
			y = "5%",
			width = "90%",
			height = "90%",
			align = "center",
			valign = "center",
			parent = missingPanel,
			font = Configuration:GetFont(3),
			caption = "Error Loading Missions",
		}
		return
	end
	
	-------------------------
	-- Generate List
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
		{name = "Name", x = 88, width = 157},
		{name = "Difficulty", x = 250, width = 125},
		{name = "Map", x = 380, right = 5},
	}
	
	local missionList = WG.Chobby.SortableList(listHolder, headings, 80, 2)

	local items = {}
	for i = 1, #missions do
		local controls, order = CreateMissionEntry(missions[i])
		items[#items + 1] = {#items, controls, order}
	end
		
	missionList:AddItems(items)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Interface

local MissionHandler = {}

function MissionHandler.GetControl()

	local window = Control:New {
		name = "missionHandler",
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
end

function widget:Initialize()
	CHOBBY_DIR = LUA_DIRNAME .. "widgets/chobby/"
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)

	--WG.Delay(DelayedInitialize, 1)

	WG.MissionHandler = MissionHandler
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------