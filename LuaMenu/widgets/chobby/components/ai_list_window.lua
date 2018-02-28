AiListWindow = ListWindow:extends{}

function AiListWindow:init(gameName)

	self:super('init', lobbyInterfaceHolder, "Choose AI", false, "main_window", nil, {6, 7, 7, 4})
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
function AiListWindow:CompareItems(id1, id2)
	local order = Configuration.simpleAiList and Configuration.gameConfig.simpleAiOrder
	if order then
		local pos1 = order[id1]
		local pos2 = order[id2]
		return pos1 and pos2 and pos1 < pos2
	end
	return true
end

function AiListWindow:AddAiToList(ai, blackList, oldAiVersions, isRunning64Bit)
	local shortName = ai.shortName or "Unknown"

	if blackList and blackList[shortName] then
		return
	end

	if (isRunning64Bit and string.find(shortName, "32")) or ((not isRunning64Bit) and string.find(shortName, "64")) then
		return
	end


	local version = " " .. ai.version
	if version == " <not-versioned>" then
		version = ""
	end
	local aiName = shortName .. version

	if oldAiVersions then
		for i = 1, #oldAiVersions do
			if string.find(aiName, oldAiVersions[i]) then
				return
			end
		end
	end

	local displayName = aiName
	if Configuration.simpleAiList and Configuration.gameConfig.GetAiSimpleName then
		displayName = Configuration.gameConfig.GetAiSimpleName(displayName)
		if not displayName then
			return
		end
	end

	self.validAiNames[shortName] = displayName

	local tooltip = nil
	if Configuration.gameConfig.aiTooltip then
		tooltip = Configuration.gameConfig.aiTooltip[displayName]
	end
	local addAIButton = Button:New {
		x = 0,
		y = 0,
		width = "100%",
		height = "100%",
		caption = displayName,
		font = Configuration:GetFont(3),
		tooltip = tooltip,
		OnClick = {
			function()
				self:AddAi(displayName, shortName, ai.version)
				self:HideWindow()
			end
		},
	}
	self:AddRow({addAIButton}, displayName)
end

function AiListWindow:AddAi(displayName, shortName, version)
	local aiName
	local counter = 1
	local found = true
	while found do
		found = false
		aiName = displayName .. " (" .. tostring(counter) .. ")"
		-- Ubserver AI names cannot include whitespace
		if WG.Server.protocol == "spring" then
			aiName = aiName:gsub(" ", "")
		end
		for _, userName in pairs(self.lobby.battleAis) do
			if aiName == userName then
				found = true
				break
			end
		end
		counter = counter + 1
	end
	self.lobby:AddAi(aiName, shortName, self.allyTeam, version)
	Configuration:SetConfigValue("lastAddedAiName", shortName)
end

function AiListWindow:QuickAdd(shortName)
	if self.validAiNames[shortName] then
		self:AddAi(self.validAiNames[shortName], shortName)
		return true
	end
end

function AiListWindow:SetLobbyAndAllyTeam(lobby, allyTeam)
	self.lobby = lobby or self.lobby
	self.allyTeam = allyTeam or self.allyTeam
end
