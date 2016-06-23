
if addon.InGetInfo then
	return {
		name      = "UserWidgetBlocker";
		desc      = "";
		version   = 1.0;
		author    = "jK";
		date      = "2011";
		license   = "GNU GPL, v2 or later";

		layer     = math.huge;
		hidden    = true; -- don't show in the widget selector
		api       = true; -- load before all others?
		before    = {"all"}; -- make it loaded before ALL other widgets (-> it must be the first widget that gets loaded!)

		enabled   = true; -- loaded by default?
	}
end


function addon.Initialize()
	--// how to handle local widgets
	local localWidgetsFirst = false or true
	local localWidgets = false or true
	do
		handler:LoadConfigData()
		if handler.configData["handler"] then
			localWidgetsFirst = handler.configData["handler"].localWidgetsFirst
			localWidgets      = handler.configData["handler"].localWidgets
		end
	end

	--// VFS Mode
	local VFSMODE = nil
	VFSMODE = localWidgetsFirst and VFS.RAW_FIRST
	VFSMODE = VFSMODE or localWidgets and VFS.ZIP_FIRST
	VFSMODE = VFSMODE or VFS.ZIP

	handler:SetVFSMode(VFSMODE)
end


function addon.BlockAddon(name, knownInfo)
	if (knownInfo.name == "WidgetSelector") then
		return
	end

	--if not knownInfo.fromZip and  then
	--	--return true --// block
	--end

	if (not knownInfo.fromZip)and(knownInfo.enabled) then
		knownInfo.enabled = false
        return true
    end
end
