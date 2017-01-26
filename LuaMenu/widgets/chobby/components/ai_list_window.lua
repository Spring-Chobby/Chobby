AiListWindow = ListWindow:extends{}

function AiListWindow:init(gameName)

	self:super('init', WG.Chobby.lobbyInterfaceHolder, "Choose AI", false, "main_window", nil, {6, 7, 9, 4})
	self.window:SetPos(nil, nil, 500, 700)
	
	self.validAiNames = {}
	
	-- Disable game-specific AIs for now since it breaks /luaui reload
	local ais
	if gameName == "zk:stable" then
		ais = {
			[1] = {
				version = "<not-versioned>",
				shortName = "CAI",
			},
			[2] = {
				version = "<not-versioned>",
				shortName = "Chicken: Very Easy",
			},
			[3] = {
				version = "<not-versioned>",
				shortName = "Chicken: Easy",
			},
			[4] = {
				version = "<not-versioned>",
				shortName = "Chicken: Normal",
			},
			[5] = {
				version = "<not-versioned>",
				shortName = "Chicken: Hard",
			},
			[6] = {
				version = "<not-versioned>",
				shortName = "Chicken: Suicidal",
			},
			[7] = {
				version = "<not-versioned>",
				shortName = "Chicken: Custom",
			},
			[8] = {
				version = "<not-versioned>",
				shortName = "Null AI",
			},
		}
		local otherAis = VFS.GetAvailableAIs(gameName)
		for i = 1, #otherAis do
			ais[#ais + 1] = otherAis[i]
		end
	else
		ais = VFS.GetAvailableAIs(gameName)
	end
	
	local blackList = Configuration.gameConfig.aiBlacklist
	
	for i, ai in pairs(ais) do
		if (not blackList) or (not blackList[ai.shortName]) then
			local version = " v" .. ai.version
			if version == " v<not-versioned>" then
				version = ""
			end
			
			self.validAiNames[ai.shortName] = true
			
			local addAIButton = Button:New {
				x = 0,
				y = 0,
				width = "100%",
				height = "100%",
				caption = ai.shortName .. version,
				font = Configuration:GetFont(3),
				OnClick = {
					function()
						self:AddAi(ai.shortName)
						self:HideWindow()
					end
				},
			}
			self:AddRow({addAIButton}, ai.shortName)
		end
	end
end

function AiListWindow:AddAi(shortName)
	local aiName
	local counter = 1
	local found = true
	while found do
		found = false
		aiName = shortName .. " (" .. tostring(counter) .. ")"
		for _, userName in pairs(self.lobby.battleAis) do
			if aiName == userName then
				found = true
				break
			end
		end
		counter = counter + 1
	end
	self.lobby:AddAi(aiName, shortName, self.allyTeam)
	WG.Chobby.Configuration:SetConfigValue("lastAddedAiName", shortName)
end

function AiListWindow:QuickAdd(shortName)
	if self.validAiNames[shortName] then
		self:AddAi(shortName)
		return true
	end
end

function AiListWindow:SetLobbyAndAllyTeam(lobby, allyTeam)
	self.lobby = lobby or self.lobby
	self.allyTeam = allyTeam or self.allyTeam
end