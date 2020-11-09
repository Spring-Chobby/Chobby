ModeListWindow = ListWindow:extends{}

function ModeListWindow:init(failFunction, sucessFunction, blacklist, titleOverride)

	self:super('init', WG.Chobby.lobbyInterfaceHolder, titleOverride or "Select Custom Mode", false, "main_window", nil, {6, 7, 7, 4})
	self.window:SetPos(nil, nil, 500, 700)
	
	local modeList, customModeMap = {}, false
	if WG.ModoptionsPanel and WG.ModoptionsPanel.GetCustomModes then
		modeList, customModeMap = WG.ModoptionsPanel.GetCustomModes(modeList)
	end
	
	if customModeMap then
		for i = 1, #modeList do
			local modeData = customModeMap[modeList[i]]
			local pickButton = Button:New {
				x = 0,
				y = 0,
				width = "100%",
				height = "100%",
				caption = modeData.name,
				font = Configuration:GetFont(3),
				OnClick = {
					function()
						sucessFunction(modeData)
						self:HideWindow()
					end
				},
			}
			self:AddRow({pickButton}, modeData.name)
		end
	end

	self.window.OnDispose = self.window.OnDispose or {}
	self.window.OnDispose[#self.window.OnDispose + 1] = failFunction or nil

	self.popupHolder = PriorityPopup(self.window, self.CancelFunc)
end
