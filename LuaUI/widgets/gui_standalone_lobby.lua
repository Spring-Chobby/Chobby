function widget:GetInfo()
  return {
    name      = "Standalone lobby tools",
    desc      = "Standalone lobby tools",
    author    = "gajop",
    date      = "in the future",
    license   = "GPL-v2",
    layer     = 1001,
    enabled   = true,
  }
end

function widget:Initialize()
    Spring.SendCommands("ResBar 0", "ToolTip 0", "Console 0", "Clock 0", "Info 0")
    gl.SlaveMiniMap(true)
    gl.ConfigMiniMap(-1,-1,-1,-1)
end