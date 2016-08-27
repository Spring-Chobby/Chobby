MapListWindow = ListWindow:extends{}

function MapListWindow:init(lobby, gameName, zoomToMap)

	self:super('init', screen0, "Select Map", false, "overlay_window")
	self.window:SetPos(nil, nil, 500, 700)
	
	local zoomY
	local whitelist
	if Configuration.onlyShowFeaturedMaps then
		whitelist = Configuration:GetGameConfig(gameName, "mapWhitelist.lua")
	end
	
	for i, archive in pairs(VFS.GetAllArchives()) do
		local info = VFS.GetArchiveInfo(archive)
		if info and info.modtype == 3 and ((not whitelist) or whitelist[info.name]) then
			local pickMapButton = Button:New {
				x = 0,
				y = 0,
				width = "100%",
				height = "100%",
				caption = info.name:gsub("_", " "),
				font = Configuration:GetFont(3),
				padding = {1,1,1,1},
				OnClick = {
					function()
						lobby:SelectMap(info.name)
						self:HideWindow()
					end
				},
			}
			local minimap = Panel:New {
				name = "minimap",
				x = 1,
				y = 1,
				width = 64,
				height = 64,
				padding = {1,1,1,1},
				parent = pickMapButton,
			}
			local minimapImage = Image:New {
				name = "minimapImage",
				x = 0,
				y = 0,
				right = 0,
				bottom = 0,
				keepAspect = true,
				file = Configuration:GetMinimapSmallImage(info.name, gameName),
				parent = minimap,
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
	
	self.popupHolder = PriorityPopup(self.window, self.CancelFunc)
end
