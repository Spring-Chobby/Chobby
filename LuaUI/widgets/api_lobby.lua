--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
  return {
    name      = "LibLobby API",
    desc      = "LibLobby GUI Framework",
    author    = "gajop",
    date      = "WIP",
    license   = "GPLv2",
    version   = "2.0",
    layer     = 1000,
    enabled   = true,  --  loaded by default?
    handler   = true,
    api       = true,
    hidden    = true,
  }
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- LibLobby's location

LIB_LOBBY_DIRNAME = "libs/liblobby/lobby/"

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:Initialize()
  LCS = loadstring(VFS.LoadFile("libs/lcs/LCS.lua"))
  LCS = LCS()
  -- Lobby extends Observable so include Observable first
  VFS.Include(LIB_LOBBY_DIRNAME .. "observable.lua", nil, VFS.RAW_FIRST)
  Lobby = VFS.Include(LIB_LOBBY_DIRNAME .. "lobby.lua", nil, VFS.RAW_FIRST)
  Listener = VFS.Include(LIB_LOBBY_DIRNAME .. "listener.lua", nil, VFS.RAW_FIRST)

  lobby = Lobby()


  --// Export Widget Globals
  WG.LibLobby = {}
  WG.LibLobby = {
      lobby = lobby, -- instance (singleton)
      Listener = Listener
  }

end

function widget:Shutdown()
  WG.LibLobby = nil
end

function widget:Update()
  WG.LibLobby.lobby:Update()
end
