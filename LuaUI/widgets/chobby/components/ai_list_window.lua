AiListWindow = ListWindow:extends{}

function AiListWindow:init(lobby, gameName, allyTeam)

	self:super('init', screen0, "Choose AI")
	self.window:SetPos(nil, nil, 500, 700)
	
	-- Disable game-specific AIs for now since it breaks /luaui reload
-- 	local ais = VFS.GetAvailableAIs(gameName)
	local ais = VFS.GetAvailableAIs()
	--local ais = {{shortName = "CAI", version = 1}}
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
					lobby:AddAi(ai.shortName, ai.shortName, allyTeam)
					self:HideWindow()
				end
			},
		}
		self:AddRow({addAIButton} ,ai.shortName)
	end
	
	self.popupHolder = PriorityPopup(self.window)
end
