-------------------------
include("keysym.h.lua")

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

LIBS_DIR = "libs/"
LCS = loadstring(VFS.LoadFile(LIBS_DIR .. "lcs/LCS.lua"))
LCS = LCS()

CHOBBY_DIR = "LuaUI/widgets/chobby/"

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

	Chobby = VFS.Include(CHOBBY_DIR .. "core.lua", nil)
	
	WG.Chobby = Chobby
	WG.Chobby:_Initialize()
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
