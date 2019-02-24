--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function widget:GetInfo()
	return {
		name      = "Discord Handler",
		desc      = "Handles discord stuff.",
		author    = "GoogleFrog",
		date      = "19 December 2017",
		license   = "GPL-v2",
		layer     = 0,
		handler   = true,
		enabled   = true,
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Utilities

local function SetDiscordPlaying(details)
	if WG.WrapperLoopback then
		WG.WrapperLoopback.DiscordUpdatePresence({
			state = details,
			--details = details,
			--startTimestamp = Spring.Utilities.GetCurrentUtc(),
		})
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Externals Functions

local DiscordHandler = {}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Initialization

local function DelayedInitialize()
	SetDiscordPlaying("In Menu")
	
	local function OnBattleAboutToStart(_, battleType)
		if battleType and string.find(battleType, "campaign") then
			SetDiscordPlaying("Playing Campaign")
		elseif battleType == "tutorial" then
			SetDiscordPlaying("Playing Tutorial")
		elseif battleType == "skirmish" then
			SetDiscordPlaying("Playing Skirmish")
		elseif battleType == "replay" then
			SetDiscordPlaying("Watching Replay")
		else
			SetDiscordPlaying("Playing Multiplayer")
		end
	end
	
	WG.LibLobby.lobby:AddListener("OnBattleAboutToStart", OnBattleAboutToStart)
	WG.LibLobby.localLobby:AddListener("OnBattleAboutToStart", OnBattleAboutToStart)
end

function widget:ActivateMenu()
	SetDiscordPlaying("In Menu")
end

function widget:Initialize() 
	WG.Delay(DelayedInitialize, 0.5)
end
