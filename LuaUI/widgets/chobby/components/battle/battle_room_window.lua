BattleRoomWindow = LCS.class{}

function BattleRoomWindow:init(battleID)
	self.battleID = battleID
	local battle = lobby:GetBattle(battleID)

	self.lblBattleTitle = Label:New {
		x = 15,
		y = 5,
		width = 200,
		height = 30,
		font = { size = 20 },
		caption = i18n("battle") .. ": " .. tostring(battle.title),
	}

	self.lblNumberOfPlayers = Label:New {
		x = 15,
		y = 35,
		width = 200,
		height = 30,
		caption = "",
	}

	self.line = Line:New {
		x = 0,
		y = 55,
		width = 300,
	}

	self.btnQuitBattle = Button:New {
		right = 10,
		y = 0,
		width = 60,
		height = 35,
		caption = Configuration:GetErrorColor() .. i18n("quit") .. "\b",
		OnClick = {
			function()
				lobby:LeaveBattle()
			end
		},
	}

	self.lblHaveGame = Label:New {
		right = 10,
		y = 45,
		width = 60,
		height = 35,
		caption = i18n("dont_have_game") .. " [" .. Configuration:GetErrorColor() .. "✘\b]",
	}
	if VFS.HasArchive(battle.gameName) then
		self.lblHaveGame.caption = i18n("have_game") .. " [" .. Configuration:GetSuccessColor() .. "✔\b]"
	end

	self.lblHaveMap = Label:New {
		right = 10,
		y = 85,
		width = 60,
		height = 35,
		caption = i18n("dont_have_map") .. " [" .. Configuration:GetErrorColor() .. "✘\b]",
	}
	if VFS.HasArchive(battle.map) then
		self.lblHaveMap.caption = i18n("have_map") .. " [" .. Configuration:GetSuccessColor() .. "✔\b]"
	end

	self.btnStartBattle = Button:New {
		x = 10,
		y = 80,
		width = 110,
		height = 55,
		caption = "\255\66\138\201" .. i18n("start") ..  "\b",
		font = { size = 22 },
		OnClick = {
			function()
				lobby:SayBattle("!start")
			end
		},
	}

	self.battleRoomConsole = Console()
	self.battleRoomConsole.listener = function(message)
		lobby:SayBattle(message)
	end
	self.userListPanel = UserListPanel(self.battleID)
	local chatPanel = Control:New {
		x = 5,
		y = 140,
		bottom = 5,
		right = 5,
		padding = {0, 0, 0, 0},
		itemPadding = {0, 0, 0, 0},
		itemMargin = {0, 0, 0, 0},
		children = {
			Control:New {
				x = 0, y = 0, right = 145, bottom = 0,
				padding={0,0,0,0}, itemPadding={0,0,0,0}, itemMargin={0,0,0,0},
				children = { self.battleRoomConsole.panel, },
			},
			Control:New {
				width = 144, y = 0, right = 0, bottom = 0,
				padding={0,0,0,0}, itemPadding={0,0,0,0}, itemMargin={0,0,0,0},
				children = { self.userListPanel.panel, },
			},
		}
	}

	local onSaidBattle = function(listener, userName, message)
		self.battleRoomConsole:AddMessage(userName .. ": " .. message)
	end
	lobby:AddListener("OnSaidBattle", onSaidBattle)

	local onSaidBattleEx = function(listener, userName, message)
		self.battleRoomConsole:AddMessage("\255\0\139\139" .. userName .. " " .. message .. "\b")		
	end
	lobby:AddListener("OnSaidBattleEx", onSaidBattleEx)

	local onBattleClosed = function(listener, closedBattleID, ... )
		if battleID == closedBattleID then
			self.window:Dispose()
		end
	end
	lobby:AddListener("OnBattleClosed", onBattleClosed)

	local onLeftBattle = function(listener, leftBattleID, userName)
		if battleID ~= leftBattleID then
			return
		end
		if lobby:GetMyUserName() == userName then
			self.window:Dispose()
		else
			self:UpdatePlayers()
		end
	end
	lobby:AddListener("OnLeftBattle", onLeftBattle)

	local onJoinedBattle = function(listener, joinedBattleId, userName)
		if battleID ~= joinedBattleId then
			return
		end
		self:UpdatePlayers()
	end
	lobby:AddListener("OnJoinedBattle", onJoinedBattle)

	-- TODO: implement this as a part of the lobby protocol
	local onClientStatus = function(listener, userName, status)
		-- game started
		if userName == battle.founder and math.bit_and(1, status) then
			Spring.Echo("Game starts!")
			local battle = lobby:GetBattle(self.battleID)
			local springURL = "spring://" .. lobby:GetMyUserName() .. ":" .. lobby:GetScriptPassword() .. "@" .. battle.ip .. ":" .. battle.port
			Spring.Echo(springURL)
			Spring.Restart(springURL, "")
			--[[local scriptFileName = "scriptFile.txt"
			local scriptFile = io.open(scriptFileName, "w")
			local scriptTxt = self:GenerateScriptTxt()
			Spring.Echo(scriptTxt)
			scriptFile:write(scriptTxt)
			scriptFile:close()
			Spring.Restart(scriptFileName, "")
			--Spring.Restart("", scriptTxt)
			--]]
		end
	end
	lobby:AddListener("OnClientStatus", onClientStatus)

	self:UpdatePlayers()
	self.window = Window:New {
		x = 600,
		width = 600,
		y = 550,
		height = 450,
		parent = screen0,
		resizable = false,
		padding = {0, 20, 0, 0},
		children = {
			self.lblBattleTitle,
			self.lblNumberOfPlayers,
			self.btnQuitBattle,
			self.lblHaveGame,
			self.lblHaveMap,
			self.btnStartBattle,
			self.line,
			chatPanel,
		},
		OnDispose = { 
			function()
				lobby:RemoveListener("OnBattleClosed", onBattleClosed)
				lobby:RemoveListener("OnLeftBattle", onLeftBattle)
				lobby:RemoveListener("OnJoinedBattle", onJoinedBattle)
				lobby:RemoveListener("OnSaidBattle", onSaidBattle)
				lobby:RemoveListener("OnSaidBattleEx", onSaidBattleEx)
				lobby:RemoveListener("OnClientStatus", onClientStatus)
			end
		},
	}

	lobby:MyBattleStatus(true, 0, 0, true, nil, true, side, nil)
end

function BattleRoomWindow:UpdatePlayers()
	local battle = lobby:GetBattle(self.battleID)
	self.lblNumberOfPlayers:SetCaption(i18n("players") .. ": " .. tostring(#battle.users) .. "/" .. tostring(battle.maxPlayers))
end

function BattleRoomWindow:GenerateScriptTxt()
	local battle = lobby:GetBattle(self.battleID)
	local scriptTxt = 
[[
[GAME]
{
	HostIP=__IP__;
	HostPort=__PORT__;
	IsHost=0;
	MyPlayerName=__MY_PLAYER_NAME__;
	MyPasswd=__MY_PASSWD__;
}
]]

	scriptTxt = scriptTxt:gsub("__IP__", battle.ip)
						:gsub("__PORT__", battle.port)
						:gsub("__MY_PLAYER_NAME__", lobby:GetMyUserName())
						:gsub("__MY_PASSWD__", lobby:GetScriptPassword())
	return scriptTxt
end
