MapListWindow = ListWindow:extends{}

function MapListWindow:init(lobby, zoomToMap)

	self:super('init', screen0, "Select Map")
	self.window:SetPos(nil, nil, 500, 700)
	
	local zoomY
	
	for i, archive in pairs(VFS.GetAllArchives()) do
		local info = VFS.GetArchiveInfo(archive)
		if info and info.modtype == 3 then
			local pickMapButton = Button:New {
				x = 0,
				y = 0,
				width = "100%",
				height = "100%",
				caption = info.name,
				font = Configuration:GetFont(3),
				OnClick = {
					function()
						lobby:SelectMap(info.name)
						self:HideWindow()
					end
				},
			}
			self:AddRow({pickMapButton}, info.name)
			if info.name == zoomToMap then
				zoomY = self:GetRowPosition(info.name)
			end
		end
	end
	
	if zoomY then
		self.listPanel:SetScrollPos(0, zoomY, true, false)
	end
	
	self.popupHolder = PriorityPopup(self.window)
end