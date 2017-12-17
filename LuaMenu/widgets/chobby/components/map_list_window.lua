MapListWindow = ListWindow:extends{}

function MapListWindow:init(lobby, zoomToMap)

	self:super('init', WG.Chobby.lobbyInterfaceHolder, "Select Map", false, "main_window", nil, {6, 7, 7, 4})
	self.window:SetPos(nil, nil, 500, 700)

	if WG.BrowserHandler and Configuration.gameConfig.link_maps then
		self.btnOnlineMaps = Button:New {
			right = 95,
			y = 7,
			width = 180,
			height = 45,
			caption = i18n("download_maps"),
			font = Configuration:GetFont(3),
			classname = "option_button",
			parent = self.window,
			OnClick = {
				function ()
					WG.BrowserHandler.OpenUrl(Configuration.gameConfig.link_maps())
				end
			},
		}
	end

	local zoomY
	local whitelist
	if Configuration.onlyShowFeaturedMaps then
		whitelist = Configuration.gameConfig.mapWhitelist
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
				x = 3,
				y = 3,
				width = 52,
				height = 52,
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
				file = Configuration:GetMinimapSmallImage(info.name),
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
