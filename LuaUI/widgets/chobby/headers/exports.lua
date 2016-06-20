--chili export
CHILI_LOBBY = {}
CHILI_LOBBY_IMG_DIR = CHILILOBBY_DIR .. "images/"

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
    StackPanel = Chili.StackPanel
    Grid = Chili.Grid
    TextBox = Chili.TextBox
    Image = Chili.Image
    TreeView = Chili.TreeView
    Trackbar = Chili.Trackbar
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
end

ChiliFX = WG.ChiliFX
Chotify = WG.Chotify

i18n.loadFile(CHILILOBBY_DIR .. "i18n/chililobby.lua")
i18n.setLocale('es')
i18n.setLocale('sr')
i18n.setLocale('jp')
i18n.setLocale('en')
