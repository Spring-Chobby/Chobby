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

CHILILOBBY_DIR = LIBS_DIR .. "chililobby/chililobby/"

function widget:Initialize()
    if not WG.LibLobby or not WG.Chili then
        widgetHandler:RemoveWidget(widget)
        return
    end

    ChiliLobby = VFS.Include(CHILILOBBY_DIR .. "core.lua", nil)

    WG.ChiliLobby = ChiliLobby
    WG.ChiliLobby:initialize()
end

function widget:Shutdown()
    WG.ChiliLobby = nil
end
