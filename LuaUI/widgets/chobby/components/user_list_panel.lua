UserListPanel = LCS.class{}

function UserListPanel:init(chanName)
	self.chanName = chanName

	self.userPanel = ScrollPanel:New {
		x = 0,
		right = 0,
		y = 0,
		bottom = 0,
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
	local channel = lobby:GetChannel(self.chanName)
	return (channel and channel.users) or {}
end

function UserListPanel:Update()
	self.userPanel:ClearChildren()

	for _, userName in pairs(self:GetUsers()) do
		self:AddUser(userName)
	end
end

function UserListPanel:AddUser(userName)
	if lobby:GetUser(userName).isBot then return end
	
	if self.team and lobby:GetTeam() ~= nil and lobby:GetTeam().leader == userName then
		userName = "♜" .. userName
	end
	
	local userControl = WG.UserHandler.GetChannelUser(userName)
	userControl:SetPos(nil, #(self.userPanel.children) * 42)
	self.userPanel:AddChild(userControl)
end
