BattleListWindow = ListWindow:extends{}

function BattleListWindow:init(parent)
	self:super("init", parent, i18n("custom_games"))
 
	local update = function() self:Update() end

	self.onBattleOpened = function(listener, battleID)
		self:AddBattle(lobby:GetBattle(battleID))
	end
	lobby:AddListener("OnBattleOpened", self.onBattleOpened)

	self.onBattleClosed = function(listener, battleID)
		self:RemoveRow(battleID)
	end
	lobby:AddListener("OnBattleClosed", self.onBattleClosed)

	self.onJoinedBattle = function(listener, battleID)
		self:JoinedBattle(battleID)
	end
	lobby:AddListener("OnJoinedBattle", self.onJoinedBattle)

	self.onLeftBattle = function(listener, battleID)
		self:LeftBattle(battleID)
	end
	lobby:AddListener("OnLeftBattle", self.onLeftBattle)

	self.onUpdateBattleInfo = function(listener, battleID)
		self:OnUpdateBattleInfo(battleID)
	end
	lobby:AddListener("OnUpdateBattleInfo", self.onUpdateBattleInfo)
	
	self.onBattleIngameUpdate = function(listener, battleID, isRunning)
		self:OnBattleIngameUpdate(battleID, isRunning)
	end
	lobby:AddListener("OnBattleIngameUpdate", self.onBattleIngameUpdate)
	update()
end

function BattleListWindow:RemoveListeners()
	lobby:RemoveListener("OnBattleOpened", self.onBattleOpened)
	lobby:RemoveListener("OnBattleClosed", self.onBattleClosed)
	lobby:RemoveListener("OnJoinedBattle", self.onJoinedBattle)
	lobby:RemoveListener("OnLeftBattle", self.onLeftBattle)
	lobby:RemoveListener("OnUpdateBattleInfo", self.onUpdateBattleInfo)
end

function BattleListWindow:Update()
	self.listPanel:ClearChildren()

	local battles = lobby:GetBattles()
	Spring.Echo("Number of battles: " .. lobby:GetBattleCount())
	local tmp = {}
	for _, battle in pairs(battles) do
		table.insert(tmp, battle)
	end
	battles = tmp
	table.sort(battles, 
		function(a, b)
			return #a.users > #b.users
		end
	)

	for _, battle in pairs(battles) do
		self:AddBattle(battle)
	end
end

function BattleListWindow:AddBattle(battle)
	local h = 60
	local children = {}

	local lblPlayers = Label:New {
		name = "players",
		x = 105,
		width = 50,
		y = 5,
		height = h - 10,
		valign = 'center',
		caption = (#battle.users - battle.spectatorCount) .. "/" .. battle.maxPlayers,
	}
	table.insert(children, lblPlayers)

	local lblTitle = Label:New {
		name = "title",
		x = 160,
		y = 0,
		width = 400,
		height = h - 10,
		valign = 'center',
		caption = battle.title:sub(1, 60),
		tooltip = battle.title, 
	}
	table.insert(children, lblTitle)

	local lblRunning = Label:New {
		name = "running",
		x = 520,
		y = 0,
		width = 100,
		height = h - 10,
		valign = 'center',
		caption = (battle.isRunning and "Running") or "", 
	}
	table.insert(children, lblRunning)
	
	if battle.passworded then
		local imgPassworded = Image:New {
			name = "password",
			file = CHOBBY_IMG_DIR .. "lock.png",
			y = 5,
			height = h - 10,
			width = 20,
			margin = {0, 0, 0, 0},
			x = lblTitle.x + lblTitle.font:GetTextWidth(lblTitle.caption) + 10,
		}
		table.insert(children, imgPassworded)
	end

	local lblGame = Label:New {
		name = "game",
		x = 180,
		width = 160,
		y = 20,
		height = h - 10,
		valign = 'center',
		caption = battle.gameName:sub(1, 22) .. (VFS.HasArchive(battle.gameName) and ' [' .. Configuration:GetSuccessColor() .. '✔\b]' or ' [' .. Configuration:GetErrorColor() .. '✘\b]'),
		tooltip = battle.gameName, 
	}
	table.insert(children, lblGame)

	local lblMap = Label:New {
		name = "map",
		x = 360,
		width = 200,
		y = 20,
		height = h - 10,
		valign = 'center',
		caption = battle.mapName:sub(1, 22) .. (VFS.HasArchive(battle.mapName) and ' [' .. Configuration:GetSuccessColor() .. '✔\b]' or ' [' .. Configuration:GetErrorColor() .. '✘\b]'),
		tooltip = battle.mapName, 
	}
	table.insert(children, lblMap)

	local btnJoin = Button:New {
		name = "join",
		x = 10,
		width = 90,
		y = 5,
		height = h - 10,
		caption = i18n("join"),
		OnClick = {
			function()
				self:JoinBattle(battle)
			end
		},
	}
	table.insert(children, btnJoin)

	self:AddRow(children, battle.battleID)
end

function BattleListWindow:CompareItems(id1, id2)
	local battle1, battle2 = lobby:GetBattle(id1), lobby:GetBattle(id2)
	return #battle1.users - #battle2.users
end

function BattleListWindow:JoinedBattle(battleID)
	local battle = lobby:GetBattle(battleID)
	local items = self:GetRowItems(battleID)
	items.players:SetCaption((#battle.users - battle.spectatorCount) .. "/" .. battle.maxPlayers)
	self:RecalculatePosition(battleID)
end

function BattleListWindow:LeftBattle(battleID)
	local battle = lobby:GetBattle(battleID)
	local items = self:GetRowItems(battleID)
	items.players:SetCaption(#battle.users .. "/" .. battle.maxPlayers)
	self:RecalculatePosition(battleID)
end

function BattleListWindow:OnUpdateBattleInfo(battleID)
	local battle = lobby:GetBattle(battleID)
	local items = self:GetRowItems(battleID)
	items.players:SetCaption((#battle.users - battle.spectatorCount) .. "/" .. battle.maxPlayers)
	items.map:SetCaption(battle.mapName:sub(1, 22) .. (VFS.HasArchive(battle.mapName) and ' [' .. Configuration:GetSuccessColor() .. '✔\b]' or ' [' .. Configuration:GetErrorColor() .. '✘\b]'))
	items.map.tooltip = battle.mapName
	self:RecalculatePosition(battleID)
end

function BattleListWindow:OnBattleIngameUpdate(battleID, isRunning)
	local battle = lobby:GetBattle(battleID)
	local items = self:GetRowItems(battleID)
	items.running:SetCaption((isRunning and "Running") or "")
	self:RecalculatePosition(battleID)
end

function BattleListWindow:JoinBattle(battle)
	if not battle.passworded then
		WG.BattleRoomWindow.LeaveBattle()
		lobby:JoinBattle(battle.battleID)
	else
		local tryJoin, passwordWindow

		local lblPassword = Label:New {
			x = 1,
			width = 100,
			y = 20,
			height = 20,
			caption = i18n("password") .. ": ",
		}
		local ebPassword = EditBox:New {
			x = 110,
			width = 120,
			y = 20,
			height = 20,
			text = "",
			hint = i18n("password"),
			passwordInput = true,
			OnKeyPress = {
				function(obj, key, mods, ...)
					if key == Spring.GetKeyCode("enter") or 
						key == Spring.GetKeyCode("numpad_enter") then
						tryJoin()
					end
				end
			},
		}
		local btnJoin = Button:New {
			x = 1,
			bottom = 1,
			width = 80,
			height = 40,
			caption = i18n("Join"),
			OnClick = {
				function()
					tryJoin()
				end
			},
		}
		local btnClose = Button:New {
			x = 110,
			bottom = 1,
			width = 80,
			height = 40,
			caption = i18n("close"),
			OnClick = {
				function()
					passwordWindow:Dispose()
				end
			},
		}

		local lblError = Label:New {
			x = 1,
			width = 100,
			y = 50,
			height = 80,
			caption = "",
			font = {
				color = { 1, 0, 0, 1 },
			},
		}


		local onJoinBattleFailed = function(listener, reason)
			lblError:SetCaption(reason)
		end
		lobby:AddListener("OnJoinBattleFailed", onJoinBattleFailed)
		local onJoinBattle = function(listener)
			passwordWindow:Dispose()
			self.window:Dispose()
		end
		lobby:AddListener("OnJoinBattle", onJoinBattle)

		passwordWindow = Window:New {
			x = 700,
			y = 300,
			width = 265,
			height = 160,
			caption = "Join passworded battle",
			resizable = false,
			parent = screen0,
			children = {
				lblPassword,
				ebPassword,
				lblError,
				btnJoin,
				btnClose,
			},
			OnDispose = { 
				function()
					lobby:RemoveListener("OnJoinBattleFailed", onJoinBattleFailed)
					lobby:RemoveListener("OnJoinBattle", onJoinBattle)
				end
			},
		}

		tryJoin = function()
			lblError:SetCaption("")
			lobby:JoinBattle(battle.battleID, ebPassword.text)
		end
	end
end
