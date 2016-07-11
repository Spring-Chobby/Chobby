AiListWindow = ListWindow:extends{}

function AiListWindow:init(lobby, gameName, allyTeam)

	self:super('init', screen0, "Choose AI")
	self.window:SetPos(nil, nil, 500, 700)
	
	local ais = VFS.GetAvailableAIs(gameName)
	for i, ai in pairs(ais) do
		local addAIButton = Button:New {
			x = 0,
			y = 0,
			width = "100%",
			height = "100%",
			caption = "shortName: " .. ai.shortName .. ", version: " .. ai.version,
			font = { size = 22 },
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
	
	self.popupHolder = PriorityPopup(self.window)
end
