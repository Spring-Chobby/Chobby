--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function widget:GetInfo()
	return {
		name      = "Chili lobby",
		desc      = "Chili example lobby",
		author    = "gajop",
		date      = "in the future",
		license   = "GPL-v2",
		layer     = 1001,
		enabled   = true,
	}
end

include("keysym.h.lua")

LIBS_DIR = "libs/"
LCS = loadstring(VFS.LoadFile(LIBS_DIR .. "lcs/LCS.lua"))
LCS = LCS()

CHOBBY_DIR = LUA_DIRNAME .. "widgets/chobby/"

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Callins

local interfaceRoot

function widget:ViewResize(vsx, vsy, viewGeometry)
	if interfaceRoot then
		interfaceRoot.ViewResize(vsx, vsy)
	end
	--Spring.Utilities.TableEcho(viewGeometry, "viewGeometry")
	WG.Chobby:_ViewResize(vsx, vsy)
end

local oldName
function widget:GamePreload()
	local gameName = Spring.GetGameName()
	oldName = gameName
	interfaceRoot.SetIngame(gameName ~= "")
	lobby:SetIngameStatus(true)
end

function widget:ActivateMenu()
	interfaceRoot.SetIngame(false)
	lobby:SetIngameStatus(false)
end

function widget:Initialize()
	if not WG.LibLobby then
		Spring.Log("chobby", LOG.ERROR, "Missing liblobby.")
		widgetHandler:RemoveWidget(widget)
		return
	end
	if not WG.Chili then
		Spring.Log("chobby", LOG.ERROR, "Missing chiliui.")
		widgetHandler:RemoveWidget(widget)
		return
	end

	Spring.SetWMCaption("Ingame Lobby", "IngameLobby")

	Chobby = VFS.Include(CHOBBY_DIR .. "core.lua", nil)

	WG.Chobby = Chobby
	WG.Chobby:_Initialize()

	interfaceRoot = WG.Chobby.GetInterfaceRoot()

	lobbyInterfaceHolder = interfaceRoot.GetLobbyInterfaceHolder()
	Chobby.lobbyInterfaceHolder = lobbyInterfaceHolder
	Chobby.interfaceRoot = interfaceRoot
end

function widget:KeyPress(key, mods, isRepeat, label, unicode)
	if interfaceRoot then
		return interfaceRoot.KeyPressed(key, mods, isRepeat, label, unicode)
	end
end

function widget:Shutdown()
	WG.Chobby = nil
end

function widget:DrawScreen()
	WG.Chobby:_DrawScreen()
end

function widget:DownloadStarted(...)
	WG.Chobby:_DownloadStarted(...)
end

function widget:DownloadFinished(...)
	WG.Chobby:_DownloadFinished(...)
end

function widget:DownloadFailed(...)
	WG.Chobby:_DownloadFailed(...)
end

function widget:DownloadProgress(...)
	WG.Chobby:_DownloadProgress(...)
end

function widget:DownloadQueued(...)
	WG.Chobby:_DownloadQueued(...)
end

function widget:GetConfigData()
	return WG.Chobby:_GetConfigData()
end

function widget:SetConfigData(...)
	WG.Chobby:_SetConfigData(...)
end
