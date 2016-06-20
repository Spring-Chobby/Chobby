SBFriendsIcon = SBItem:extends{}

function SBFriendsIcon:init()
    self:super('init')

    self.btnFriends = Button:New {
        x = self.imagePadding,
        width = self.iconSize + self.imagePadding,
        height = self.iconSize + self.imagePadding,
        y = (self.height - self.iconSize) / 2 - 4,
        caption = '',
        tooltip = i18n("friend_list"),
        padding = {0, 0, 0, 0},
        itemPadding = {0, 0, 0, 0},
        borderThickness = 0,
        backgroundColor = {0, 0, 0, 0},
        focusColor      = {0.4, 0.4, 0.4, 1},
        children = {
            Label:New {
                x = 3,
                y = 28,
                height = 10,
                font = { 
                    size = 17, 
                    outline = true,
                    autoOutlineColor = false,
                    outlineColor = { 1, 0, 0, 0.6 },
                },
                caption = "",
            },
            Label:New {
                x = 28,
                y = 3,
                height = 10,
                font = { 
                    size = 14, 
                    outline = true,
                    autoOutlineColor = false,
                    outlineColor = { 0, 1, 0, 0.6 },
                },
                caption = "",
            },
            Image:New {
                x = 4,
                y = 4,
                width = self.iconSize,
                height = self.iconSize,
                margin = {0, 0, 0, 0},
                file = CHILI_LOBBY_IMG_DIR .. "friends_off.png",
            },
        },
    }
    self.onFriend = function(listener)
        local onlineFriends = {}
        for key, friend in pairs(lobby:GetFriends()) do
            if lobby:GetUser(friend) ~= nil then
                table.insert(onlineFriends, friend)
            end
        end
        if #onlineFriends > 0 then
            self.btnFriends.children[1]:SetCaption("\255\0\200\0" .. tostring(#onlineFriends) .. "\b")
            self.btnFriends.children[3].file = CHILI_LOBBY_IMG_DIR .. "friends.png"
        end
    end
    lobby:AddListener("OnFriendListEnd", self.onFriend)

    self.onAccepted = function()
        lobby:FriendList()
    end
    lobby:AddListener("OnAccepted", self.onAccepted)
    self:AddControl(self.btnFriends)
end
