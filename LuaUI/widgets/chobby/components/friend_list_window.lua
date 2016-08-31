FriendListWindow = ListWindow:extends{}

function FriendListWindow:init(parent)
	self:super("init", parent, i18n("friends"), true)
 
	self:SetMinItemWidth(240)
	self.columns = 3
	self.itemHeight = 80
	self.itemPadding = 1

	lobby:AddListener("OnAddUser",           function(listener, ...) self:OnAddUser(...) end)
	lobby:AddListener("OnRemoveUser",        function(listener, ...) self:OnRemoveUser(...) end)
	lobby:AddListener("OnFriend",            function(listener, ...) self:OnFriend(...) end)
	lobby:AddListener("OnUnfriend",          function(listener, ...) self:OnUnfriend(...) end)
	lobby:AddListener("OnFriendList",        function(listener, ...) self:OnFriendList(...) end)
	lobby:AddListener("OnFriendRequest",     function(listener, ...) self:OnFriendRequest(...) end)
	lobby:AddListener("OnFriendRequestList", function(listener, ...) self:OnFriendRequestList(...) end)
	lobby:AddListener("OnAccepted",          function(listener, ...) self:OnAccepted(...) end)
end

function FriendListWindow:OnAddUser(userName)
	local userInfo = lobby:GetUser(userName)
	if userInfo.isFriend then
		local userControl = WG.UserHandler.GetNotificationUser(userName)
		userControl:SetPos(20, 40, 250, 20)
		Chotify:Post({
			title = i18n("User got online"),
			body  = userControl,
		})
	end
end

function FriendListWindow:OnRemoveUser(userName)
	if not lobby.status == "connected" then
		return
	end
	local userInfo = lobby:GetUser(userName)
	if userInfo and userInfo.isFriend then
		local userControl = WG.UserHandler.GetNotificationUser(userName)
		userControl:SetPos(20, 40, 250, 20)
		Chotify:Post({
			title = i18n("User went offline"),
			body  = userControl,
		})
	end
end

function FriendListWindow:CompareItems(userName1, userName2)
	if userName1 > userName2 then
		return 1
	elseif userName1 == userName2 then
		return 0
	else
		return -1
	end
end

function FriendListWindow:AddFriendRequest(userName)
	userControl = WG.UserHandler.GetFriendRequestUser(userName)
	userControl:SetPos(0, 0, 250, 80)
	local lblFriendRequest = Label:New {
		x = 0,
		y = 0,
		width = 100,
		height = 30,
		caption = i18n("friend_request"),
		font = Configuration:GetFont(1),
	}
	lblFriendRequest.font.color = { 0.5, 0.5, 0.5, 1 }
	lblFriendRequest:Invalidate()
	local btnAccept = Button:New {
		x = 10,
		y = 50,
		width = 100,
		height = 30,
		caption = i18n("accept"),
		font = Configuration:GetFont(2),
		classname = "option_button",
		OnClick = {
			function()
				self:RemoveRow(userName)
				lobby:AcceptFriendRequest(userName)
			end
		},
	}
	local btnDecline = Button:New {
		x = 250 - 100 - 10,
		y = 50,
		width = 100,
		height = 30,
		caption = i18n("decline"),
		font = Configuration:GetFont(2),
		classname = "negative_button",
		OnClick = {
			function()
				self:RemoveRow(userName)
				lobby:DeclineFriendRequest(userName)
			end
		},
	}
	self:AddRow({lblFriendRequest, btnAccept, btnDecline, userControl}, userName)
end

function FriendListWindow:AddFriend(userName)
	userControl = WG.UserHandler.GetFriendUser(userName)
	userControl:SetPos(0, 0, 250, 80)
	self:AddRow({userControl}, userName)
end

function FriendListWindow:OnFriend(userName)
-- 	interfaceRoot.GetRightPanelHandler().SetActivity("friends", lobby:GetFriendRequestCount())
	self:AddFriend(userName)
end

function FriendListWindow:OnUnfriend(userName)
-- 	interfaceRoot.GetRightPanelHandler().SetActivity("friends", lobby:GetFriendRequestCount())
	self:RemoveRow(userName)
end

function FriendListWindow:OnFriendList(friends)
-- 	interfaceRoot.GetRightPanelHandler().SetActivity("friends", lobby:GetFriendRequestCount())
	for _, userName in pairs(friends) do
		self:AddFriend(userName)
	end
end

function FriendListWindow:OnFriendRequest(userName)
-- 	interfaceRoot.GetRightPanelHandler().SetActivity("friends", lobby:GetFriendRequestCount())
	local userControl = WG.UserHandler.GetNotificationUser(userName)
	userControl:SetPos(20, 40, 250, 20)
	Chotify:Post({
		title = i18n("New friend request"),
		body  = userControl,
	})
	self:AddFriendRequest(userName)
end

function FriendListWindow:OnFriendRequestList(friendRequests)
-- 	interfaceRoot.GetRightPanelHandler().SetActivity("friends", lobby:GetFriendRequestCount())
	for _, userName in pairs(friendRequests) do
		self:AddFriendRequest(userName)
	end
end

function FriendListWindow:OnAccepted(listener)
	self:Clear()
	lobby:FriendList()
	lobby:FriendRequestList()
end

function FriendListWindow:RemoveListeners()
	lobby:RemoveListener("OnFriend",            OnFriend)
	lobby:RemoveListener("OnFriendList",        OnFriendList)
	lobby:RemoveListener("OnFriendRequest",     OnFriendRequest)
	lobby:RemoveListener("OnFriendRequestList", OnFriendRequestList)
	lobby:RemoveListener("OnAccepted",          OnAccepted)
end
