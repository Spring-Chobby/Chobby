AiListWindow = ListWindow:extends{}

function AiListWindow:init(lobby, gameName, allyTeam)

	self:super('init', screen0, "Choose AI", false, "overlay_window")
	self.window:SetPos(nil, nil, 500, 700)
	
	-- Disable game-specific AIs for now since it breaks /luaui reload
-- 	local ais = VFS.GetAvailableAIs(gameName)
	local ais = VFS.GetAvailableAIs()
	if Configuration.singleplayer_mode == 2 then
		ais[#ais + 1] = ais[1]
		ais[1] = {shortName = "CAI", version = 1}
	end
	
	local blackList = Configuration:GetGameConfig(gameName, "aiBlacklist.lua")
	
	for i, ai in pairs(ais) do
		if (not blackList) or (not blackList[ai.shortName]) then
			local addAIButton = Button:New {
				x = 0,
				y = 0,
				width = "100%",
				height = "100%",
				caption = ai.shortName .. " v" .. ai.version,
				font = Configuration:GetFont(3),
				OnClick = {
					function()
						local battle = lobby:GetBattle(lobby:GetMyBattleID())

						local aiName
						local counter = 1
						local found = true
						while found do
							found = false
							aiName = ai.shortName .. " (" .. tostring(counter) .. ")"
							for _, userName in pairs(battle.users) do
								if aiName == userName then
									found = true
									break
								end
							end
							counter = counter + 1
						end
						lobby:AddAi(aiName, ai.shortName, allyTeam)
						self:HideWindow()
					end
				},
			}
			self:AddRow({addAIButton} ,ai.shortName)
		end
	end
	
	self.popupHolder = PriorityPopup(self.window)
end
