SBConnectionStatus = SBItem:extends{}

function SBConnectionStatus:init()
	self:super('init')

	self.lblPing = Label:New {
		x = 10,
		y = 0,
		height = self.height - 3, -- hacks
		valign = "center",
		width = 100,
		caption = "\255\180\180\180" .. i18n("offline") .. "\b",
		font = Configuration:GetFont(3)
	}

	local updateStatus = function()
		local latency = lobby:GetLatency()
		local color
		latency = math.ceil(latency)
		if latency < 500 then
			color = Configuration:GetSuccessColor()
		elseif latency < 1000 then
			color = Configuration:GetWarningColor()
		else
			if latency > 9000 then
				latency = "9000+"
			end
			color = "\255\255\125\0"
		end
		self.lblPing:SetCaption(color .. latency .. "ms\b")
	end
	lobby:AddListener("OnPong", updateStatus)

	lobby:AddListener("OnAccepted",
		function(listener)
			lobby:Ping()
		end
	)

	lobby:AddListener("OnDisconnected", function()
		if lobby.status == "offline" then
			self.lblPing:SetCaption("\255\180\180\180" .. i18n("offline") .. "\b")
		else
			self.lblPing:SetCaption(Configuration:GetErrorColor() .. "D/C\b")
		end
	end)

	self:AddControl(self.lblPing)
end
