UserListPanel = LCS.class{}

function UserListPanel:init(userUpdateFunction, spacing)
	self.userUpdateFunction = userUpdateFunction
	self.spacing = spacing

	self.userPanel = ScrollPanel:New {
		x = 0,
		right = 0,
		y = 0,
		bottom = 0,
		horizontalScrollbar = false,
	}

	self.panel = Control:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		padding      = {0, 0, 0, 0},
		itemPadding  = {0, 0, 0, 0},
		itemMargin   = {0, 0, 0, 0},
		children = {
			self.userPanel,
		},
	}
	self:Update()
end

function UserListPanel:OnJoined(userName)
	self:Update()
end

function UserListPanel:OnLeft(userName)
	self:Update()
end

function UserListPanel:GetUsers()
	local channel = self.userUpdateFunction()
	return (channel and channel.users) or {}
end

function UserListPanel:Update()
	self.userPanel:ClearChildren()

	for _, userName in pairs(self:GetUsers()) do
		self:AddUser(userName)
	end
end

function UserListPanel:AddUser(userName)
	local userData = lobby:GetUser(userName)
	if not userData then
		Spring.Echo("User data not found", userName)
		return
	end
	if userData.isBot and not Configuration.displayBots then 
		return 
	end
	
	local userControl = WG.UserHandler.GetChannelUser(userName)
	userControl:SetPos(nil, #(self.userPanel.children) * self.spacing)
	self.userPanel:AddChild(userControl)
end
