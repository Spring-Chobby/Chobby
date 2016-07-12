GameListWindow = ListWindow:extends{}

function GameListWindow:init(lobby)

	self:super('init', screen0, "Select Game")
	self.window:SetPos(nil, nil, 500, 700)
	
	for i, archive in pairs(VFS.GetAllArchives()) do
		local info = VFS.GetArchiveInfo(archive)
		if info and info.modtype == 1 then
			local pickGameButton = Button:New {
				x = 0,
				y = 0,
				width = "100%",
				height = "100%",
				caption = info.name,
				font = { size = 22 },
				OnClick = {
					function()
						lobby:SelectGame(info.name)
						self:HideWindow()
					end
				},
			}
			self:AddRow({pickGameButton}, info.name)
		end
	end
	
	self.popupHolder = PriorityPopup(self.window)
end
