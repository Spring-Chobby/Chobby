AiListWindow = ListWindow:extends{}

function AiListWindow:init(gameName)

	self:super('init', WG.Chobby.lobbyInterfaceHolder, "Choose AI", false, "main_window", nil, {6, 7, 7, 4})
	self.window:SetPos(nil, nil, 500, 700)
	
	self.validAiNames = {}
	
	-- Disable game-specific AIs for now since it breaks /luaui reload
	local ais = VFS.GetAvailableAIs(gameName)
	
	local blackList = Configuration.gameConfig.aiBlacklist
	local oldAiVersions = (not Configuration.showOldAiVersions) and Configuration.gameConfig.oldAiVersions
	local isRunning64Bit = Configuration:GetIsRunning64Bit()
	
	for i, ai in pairs(ais) do
		self:AddAiToList(ai, blackList, oldAiVersions, isRunning64Bit)
	end
end

function AiListWindow:AddAiToList(ai, blackList, oldAiVersions, isRunning64Bit)
	local shortName = ai.shortName or "Unknown"
	
	if blackList and blackList[shortName] then
		return
	end
	
	if (isRunning64Bit and string.find(shortName, "32")) or ((not isRunning64Bit) and string.find(shortName, "64")) then
		return
	end
	
	
	local version = " v" .. ai.version
	if version == " v<not-versioned>" then
		version = ""
	end
	local fullName = shortName .. version
	
	if oldAiVersions then
		for i = 1, #oldAiVersions do
			if string.find(fullName, oldAiVersions[i]) then
				return
			end
		end
	end
	
	self.validAiNames[shortName] = true
	
	local addAIButton = Button:New {
		x = 0,
		y = 0,
		width = "100%",
		height = "100%",
		caption = fullName,
		font = Configuration:GetFont(3),
		OnClick = {
			function()
				self:AddAi(shortName)
				self:HideWindow()
			end
		},
	}
	self:AddRow({addAIButton}, fullName)
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