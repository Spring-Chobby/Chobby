SBMenuIcon = SBItem:extends{}

function SBMenuIcon:init()
    self:super('init')

    self.btnSettings = Button:New {
        width = 100, height = 40,
        caption = i18n("settings"),
    }
    self.btnLogout = Button:New {
        width = 100, height = 40,
        caption = "\255\150\150\150" .. i18n("logout") .. "\b",
        state = { enabled = false },
    }
    self.btnQuit = Button:New {
        width = 100, height = 40,
        caption = i18n("quit"),
    }
    self.btnMenu = ComboBox:New {
        x = self.imagePadding,
        width = self.iconSize + self.imagePadding,
        height = self.iconSize + self.imagePadding,
        y = (self.height - self.iconSize) / 2 - 4,
        caption = '',
        tooltip = i18n("menu"),
        padding = {0, 0, 0, 0},
        itemPadding = {0, 0, 0, 0},
        borderThickness = 0,
        backgroundColor = {0, 0, 0, 0},
        focusColor      = {0.4, 0.4, 0.4, 1},
        children = {
            Image:New {
                x = 4,
                y = 4,
                width = self.iconSize,
                height = self.iconSize,
                margin = {0, 0, 0, 0},
                file = CHILI_LOBBY_IMG_DIR .. "menu.png",
            },
        },
        items = {
            self.btnSettings,
            Line:New {
                width = 100,
            },
            self.btnLogout,
            self.btnQuit,
        },
    }
    self.btnMenu.OnSelect = {
        function(obj, itemIdx, selected)
            if selected then
                if itemIdx == 1 then
                    Spring.Echo("Settings")
                    local sw, sh = Spring.GetWindowGeometry()
                    local w, h = 400, 200
                    local window
                    window = Window:New {
                        caption = i18n("settings"),
                        x = math.floor((sw - w) / 2),
                        y = math.floor(math.max(0, (sh) / 2 - h)),
                        width = w,
                        height = h,
                        parent = screen0,
                        draggable = false,
                        resizable = false,
                        children = {
                            Label:New {
                                x = 10,
                                width = 100,
                                height = 40,
                                y = 40,
                                valign = "center",
                                caption = i18n("language") .. ":",
                            },
                            ComboBox:New {
                                x = 110,
                                width = 150,
                                height = 40,
                                y = 40,
                                items = { "English", "Japanese", "Serbian", "Spanish" },
                                OnSelect = {function(obj, indx, changed) 
                                    if changed then
                                        local locales = { "en", "jp", "sr", "es" }
                                        i18n.setLocale(locales[indx])
                                    end
                                end},
                            },
                            Checkbox:New { 
                                x = 10,
                                width = 300,
                                y = 100,
                                caption = i18n("Enable GLSL animations (experimental)"),
                                checked = ChiliFX:IsEnabled(),
                                OnChange = {function(obj, val) 
                                    if val then
                                        ChiliFX:Enable()
                                        Chotify:Post({
                                            title = "GLSL is ON!",
                                            body = "wohoooooo!!",
                                        })
                                    else
                                        ChiliFX:Disable()
                                    end
                                end},
                            },
                            Button:New {
                                right = 10,
                                width = 70,
                                y = 130,
                                height = 40,
                                caption = i18n("close"),
                                OnClick = { function()
                                    window:Dispose()
                                end}
                            },
                        }
                    }
                elseif itemIdx == 3 then
                    Spring.Echo("Logout")
                elseif itemIdx == 4 then
                    Spring.Echo("Quitting...")
                    Spring.SendCommands("quitforce")
                end
            end
        end
    }

    self:AddControl(self.btnMenu)
end
