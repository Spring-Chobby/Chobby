--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "i18n",
		desc      = "Internationalization library for Spring",
		author    = "gajop",
		date      = "WIP",
		license   = "GPLv2",
		version   = "0.1",
		layer     = -1000,
		enabled   = true,  --  loaded by default?
		handler   = true,
		api       = true,
		hidden    = true,
	}
end

I18N_PATH = "i18nlib/i18n/"
function widget:Initialize()
	WG.i18n = VFS.Include(I18N_PATH .. "init.lua", nil, VFS.DEF_MODE)
end