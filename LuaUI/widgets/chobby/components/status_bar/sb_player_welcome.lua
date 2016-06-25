SBPlayerWelcome = SBItem:extends{}

function SBPlayerWelcome:init()
	self:super('init')

	self.lblPlayerIcon = Label:New {
		x = 0,
		width = 150,
		y = 0,
		height = self.height - 10, -- hacks
		valign = "center",
		caption = "",
		font = {
			size = 16,
		},
	}

	lobby:AddListener("OnAccepted", 
		function(listener)
			self.lblPlayerIcon:SetCaption(i18n("welcome") .. " " ..  lobby:GetMyUserName())
		end
	)

	self:AddControl(self.lblPlayerIcon)
end