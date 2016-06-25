UserListPanel = LCS.class{}

function UserListPanel:init(source)
	if type(source) == "number" then
		self.battleId = source
	elseif type(source) == "string" then
		self.chanName = source
	else
		self.team = true
	end

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
		OnDispose = { 
			function()
				self:RemoveListeners()
			end
		},
	}
	self:AddListeners()
	
	self:Update()
end

function UserListPanel:AddListeners()
	if self.battleId ~= nil then
		self.onJoinedBattle = function(listener, battleId)
			if battleId == self.battleId then
				self:Update()
			end
		end
		lobby:AddListener("OnJoinedBattle", self.onJoinedBattle)

		self.onLeftBattle = function(listener, battleId)
			if battleId == self.battleId then
				self:Update()
			end
		end
		lobby:AddListener("OnLeftBattle", self.onLeftBattle)
	elseif self.chanName ~= nil then
		self.onClients = function(listener, chanName, clients)
			if chanName == self.chanName then
				self:Update()
			end
		end
		lobby:AddListener("OnClients", self.onClients)

		self.onJoined = function(listener, chanName)
			if chanName == self.chanName then
				self:Update()
			end
		end
		lobby:AddListener("OnJoined", self.onJoined)

		self.onLeft = function(listener, chanName)
			if chanName == self.chanName then
				self:Update()
			end
		end
		lobby:AddListener("OnLeft", self.onLeft)
	elseif self.team then
		self.onJoinedTeam = function(listner, ...)
			self:Update()
		end
		lobby:AddListener("OnJoinedTeam", self.onJoinedTeam)

		self.onLeftTeam = function(listner, ...)
			self:Update()
		end
		lobby:AddListener("OnLeftTeam", self.onLeftTeam)
	end
end

function UserListPanel:RemoveListeners()
	if self.battleId ~= nil then
		lobby:RemoveListener("OnJoinedBattle", self.onJoinedBattle)
		lobby:RemoveListener("OnLeftBattle", self.onLeftBattle)
	elseif self.chanName ~= nil then
		lobby:RemoveListener("OnClients", self.onClients)
		lobby:RemoveListener("OnJoined", self.onJoined)
		lobby:RemoveListener("OnLeft", self.onLeft)
	elseif self.team then
		lobby:RemoveListener("OnJoinedTeam", self.onJoinedTeam)
		lobby:RemoveListener("OnLeftTeam", self.onLeftTeam)
	end
end

function UserListPanel:GetUsers()
	local userNames
	if self.battleId ~= nil then
		local battle = lobby:GetBattle(self.battleId)
		if battle ~= nil then
			userNames = battle.users
		end
	elseif self.chanName ~= nil then
		local channel = lobby:GetChannel(self.chanName)
		if channel ~= nil then
			userNames = channel.users
		end
	elseif self.team then
		local team = lobby:GetTeam()
		if team ~= nil then
			userNames = team.users
		end
	end

	if userNames ~= nil then
		return userNames
	else
		return {}
	end
end

function UserListPanel:Update()
	self.userPanel:ClearChildren()

	for _, userName in pairs(self:GetUsers()) do
		self:AddUser(userName)
	end
end

function UserListPanel:AddUser(userName)
	local children = {}

	if self.team and lobby:GetTeam() ~= nil and lobby:GetTeam().leader == userName then
		userName = "♜" .. userName
	end
	local btnChat = Button:New {
		x = 0,
		width = 100,
		y = 0,
		height = 30,
		caption = userName, 
		OnClick = {
			function()
				CHOBBY.chatWindows:GetPrivateChatConsole(userName)
			end
		},
	}
	table.insert(children, btnChat)

	self.userPanel:AddChild(Control:New {
		x = 0,
		width = "100%",
		y = #(self.userPanel.children) * 42,
		height = 40,
		children = children,
	})
end
