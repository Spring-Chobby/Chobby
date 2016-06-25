SkirmishWindow = LCS.class{}

function SkirmishWindow:init()
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

	self.btnStartBattle = Button:New {
		x = 10,
		y = 80,
		width = 110,
		height = 55,
		caption = "\255\66\138\201" .. i18n("start") ..  "\b",
		font = { size = 22 },
		OnClick = {
			function()
-- 				lobby:SayBattle("!start")
			end
		},
	}

	self.window = Window:New {
		x = 600,
		width = 600,
		y = 550,
		height = 450,
		parent = screen0,
		resizable = false,
		padding = {0, 20, 0, 0},
		children = {
			self.btnQuitBattle,
			self.btnStartBattle,
			self.line,
			chatPanel,
		},
	}
end

-- function SkirmishWindow:GenerateScriptTxt()
-- 	local battle = lobby:GetBattle(self.battleID)
-- 	local scriptTxt = 
-- [[
-- [GAME]
-- {
-- 	HostIP=__IP__;
-- 	HostPort=__PORT__;
-- 	IsHost=0;
-- 	MyPlayerName=__MY_PLAYER_NAME__;
-- 	MyPasswd=__MY_PASSWD__;
-- }
-- ]]
-- 
-- 	scriptTxt = scriptTxt:gsub("__IP__", battle.ip)
-- 						:gsub("__PORT__", battle.port)
-- 						:gsub("__MY_PLAYER_NAME__", lobby:GetMyUserName())
-- 						:gsub("__MY_PASSWD__", "12345")
-- 	return scriptTxt
-- end
