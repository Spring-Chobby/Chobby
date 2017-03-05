--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function widget:GetInfo()
	return {
		name      = "Ingame Interface",
		desc      = "Contains the interface between ingame and luaMenu",
		author    = "GoogleFrog",
		date      = "18 November 2016",
		license   = "GPL-v2",
		layer     = -0,
		handler   = true,
		api       = true,
		enabled   = true,
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Externals Functions

local externalFunctions = {}

function externalFunctions.SetLobbyOverlayActive(newActive)
	if Spring.SendLuaUIMsg then
		Spring.SendLuaUIMsg("LobbyOverlayActive" .. ((newActive and "1") or "0"))
	else
		Spring.Echo("Spring.SendLuaUIMsg does not exist in LuaMenu")
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Patterns to match

local TTT_SAY = "textToSpeechSay_"
local TTS_VOLUME = "textToSpeechVolume_"
local REMOVE_BUTTON = "disableLobbyButton"
local ENABLE_OVERLAY = "showLobby"

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Text To Speech

local function HandleTextToSpeech(msg)
	local Configuration = WG.Chobby.Configuration
	if not Configuration.enableTextToSpeech then
		return false
	end
	
	if string.find(msg, TTT_SAY) == 1 then
		msg = string.sub(msg, 17)
		local nameEnd = string.find(msg, "%s")
		local name = string.sub(msg, 0, nameEnd)
		msg = string.sub(msg, nameEnd + 1)
		WG.WrapperLoopback.TtsSay(name, msg)
		return true
	end
	
	if string.find(msg, TTS_VOLUME) == 1 then
		msg = string.sub(msg, 20)
		WG.WrapperLoopback.TtsVolume(tonumber(msg) or 0)
		return true
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Lobby Overlay

local function HandleLobbyOverlay(msg)
	local Chobby = WG.Chobby
	--Spring.Echo("HandleLobbyOverlay", msg)
	local interfaceRoot = Chobby and Chobby.interfaceRoot
	if interfaceRoot then
		if msg == REMOVE_BUTTON then 
			interfaceRoot.SetLobbyButtonEnabled(false)
			return true
		elseif msg == ENABLE_OVERLAY then 
			Spring.Echo("HandleLobbyOverlay SetMainInterfaceVisibley")
			interfaceRoot.SetMainInterfaceVisible(true)
			return true
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Callins

function widget:RecvLuaMsg(msg)
	if HandleLobbyOverlay(msg) then
		return
	end
	if HandleTextToSpeech(msg) then
		return
	end
end

function widget:ActivateMenu()
	local Chobby = WG.Chobby
	local interfaceRoot = Chobby and Chobby.interfaceRoot
	
	-- Another game might be started without the ability to display lobby button.
	if interfaceRoot then
		interfaceRoot.SetLobbyButtonEnabled(true)
	end
end

function widget:ActivateGame()
end

function widget:Initialize()
	WG.IngameInterface = externalFunctions
end
