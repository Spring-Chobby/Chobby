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
	Spring.SendCommands("ResBar 0", "ToolTip 0", "Clock 0", "Info 0") --  "Console 0",
	
	--Spring.SendCommands("cmdcolors mouseBoxLineWidth 0.0")
	--Spring.SendCommands("cmdcolors 'mouseBox 0.0 0.0 0.0 0.0'")
	
	local f = io.open('cmdcolors.tmp', 'w+')
	if (f) then
		f:write('mouseBoxLineWidth 0.0\nmouseBox 0.0 0.0 0.0 0.0')
		f:close()
		Spring.SendCommands({'cmdcolors cmdcolors.tmp'})
	end
	os.remove('cmdcolors.tmp')
	
	gl.SlaveMiniMap(true)
	gl.ConfigMiniMap(-1,-1,-1,-1)
end
