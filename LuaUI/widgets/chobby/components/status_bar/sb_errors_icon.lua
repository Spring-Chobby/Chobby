SBErrorsIcon = SBItem:extends{}

function SBErrorsIcon:init()
    self:super('init')

    self.btnErrors = Button:New {
        x = self.imagePadding,
        width = self.iconSize + self.imagePadding,
        height = self.iconSize + self.imagePadding,
        y = (self.height - self.iconSize) / 2 - 4,
        caption = '',
        tooltip = i18n("error_log"),
        padding = {0, 0, 0, 0},
        itemPadding = {0, 0, 0, 0},
        borderThickness = 0,
        backgroundColor = {0, 0, 0, 0},
        focusColor      = {0.4, 0.4, 0.4, 1},
        children = {
            -- FIXME: make it work with pr errorer
--             Label:New {
--                 x = 3,
--                 y = 28,
--                 height = 10,
--                 font = { 
--                     size = 17, 
--                     outline = true,
--                     autoOutlineColor = false,
--                     outlineColor = { 1, 0, 0, 0.6 },
--                 },
--                 caption = "",
--             },
--             Label:New {
--                 x = 28,
--                 y = 3,
--                 height = 10,
--                 font = { 
--                     size = 14, 
--                     outline = true,
--                     autoOutlineColor = false,
--                     outlineColor = { 0, 1, 0, 0.6 },
--                 },
--                 caption = "",
--             },
            Image:New {
                x = 4,
                y = 4,
                width = self.iconSize,
                height = self.iconSize,
                margin = {0, 0, 0, 0},
                file = CHOBBY_IMG_DIR .. "warning_off.png",
            },
        },
    }
    self:AddControl(self.btnErrors)
end
