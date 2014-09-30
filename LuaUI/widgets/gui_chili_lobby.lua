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

    VFS.Include(CHILILOBBY_DIR .. "exports.lua")
    VFS.Include(CHILILOBBY_DIR .. "console.lua")
    VFS.Include(CHILILOBBY_DIR .. "login_window.lua")
    VFS.Include(CHILILOBBY_DIR .. "chat_windows.lua")
    VFS.Include(CHILILOBBY_DIR .. "play_window.lua")
    VFS.Include(CHILILOBBY_DIR .. "battle_list_window.lua")
	VFS.Include(CHILILOBBY_DIR .. "battle_room_window.lua")
    VFS.Include(CHILILOBBY_DIR .. "user_list_panel.lua")

    local loginWindow = LoginWindow()
end


