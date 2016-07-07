--chili export
CHOBBY_DIR = CHOBBY_DIR or "LuaUI/widgets/chobby/"
CHOBBY_IMG_DIR = CHOBBY_DIR .. "images/"

if WG and WG.Chili then
	-- setup Chili
	Chili = WG.Chili
	Checkbox = Chili.Checkbox
	Control = Chili.Control
	ComboBox = Chili.ComboBox
	Button = Chili.Button
	Label = Chili.Label
	Line = Chili.Line
	EditBox = Chili.EditBox
	Window = Chili.Window
	ScrollPanel = Chili.ScrollPanel
	LayoutPanel = Chili.LayoutPanel
	Panel = Chili.Panel
	StackPanel = Chili.StackPanel
	Grid = Chili.Grid
	TextBox = Chili.TextBox
	Image = Chili.Image
	TreeView = Chili.TreeView
	Trackbar = Chili.Trackbar
	DetachableTabPanel = Chili.DetachableTabPanel
	screen0 = Chili.Screen0
	Progressbar = Chili.Progressbar
end

--lobby export
if WG and WG.LibLobby then
	LibLobby = WG.LibLobby
	lobby = LibLobby.lobby
end

if WG and WG.i18n then
	i18n = WG.i18n
	if not i18n._loaded then
		i18n.loadFile(CHOBBY_DIR .. "i18n/chililobby.lua")
		i18n.setLocale('es')
		i18n.setLocale('sr')
		i18n.setLocale('jp')
		i18n.setLocale('en')
		i18n._loaded = true
	end
end

ChiliFX = WG.ChiliFX
Chotify = WG.Chotify
