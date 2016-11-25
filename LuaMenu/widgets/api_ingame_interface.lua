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
-- Callins

function widget:RecvLuaMsg(msg)
	local Chobby = WG.Chobby
	local interfaceRoot = Chobby and Chobby.interfaceRoot
	if interfaceRoot then
		if msg == "disableLobbyButton" then 
			interfaceRoot.SetLobbyButtonEnabled(false)
		elseif msg == "showLobby" then 
			interfaceRoot.SetMainInterfaceVisible(true)
		end
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
