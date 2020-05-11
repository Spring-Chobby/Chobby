--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Tutorial Handler",
		desc      = "Popup prompts for tutorial",
		author    = "GoogleFrog",
		date      = "11 May 2020",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Vars

local tutorialPrompt

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Status Prompt

local function InitializeTutorialPrompt()
	local queuePanel = Control:New {
		name = "tutorialprompt",
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		padding = {0,0,0,0},
		resizable = false,
		draggable = false,
	}

	local button = Button:New {
		name = "tutorial",
		x = 4,
		right = 4,
		y = 4,
		bottom = 4,
		padding = {0,0,0,0},
		caption = "Play the Tutorial",
		font = WG.Chobby.Configuration:GetFont(4),
		classname = "action_button",
		OnClick = {
			function()
				local statusAndInvitesPanel = WG.Chobby.interfaceRoot.GetStatusAndInvitesPanel()
				statusAndInvitesPanel.RemoveControl(queuePanel.name)
				WG.Chobby.interfaceRoot.OpenSingleplayerTabByName("campaign")
			end
		},
		parent = queuePanel,
	}

	local externalFunctions = {}

	function externalFunctions.GetHolder()
		return queuePanel
	end

	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Interface

local externalFunctions = {}


--------------------------------------------------------------------------------
-- Callins
--------------------------------------------------------------------------------

function DelayedInitialize()
	local statusAndInvitesPanel = WG.Chobby.interfaceRoot.GetStatusAndInvitesPanel()

	tutorialPrompt = InitializeTutorialPrompt("tutorialPrompt")
	statusAndInvitesPanel.AddControl(tutorialPrompt.GetHolder(), 15)
end

function widget:Initialize()
	CHOBBY_DIR = "LuaMenu/widgets/chobby/"
	VFS.Include("LuaMenu/widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)

	WG.TutorialPromptHandler = externalFunctions
	WG.Delay(DelayedInitialize, 1)
end

function widget:Shutdown()
	WG.TutorialPromptHandler = nil
end
