SBServerStatus = SBItem:extends{}

function SBServerStatus:init()
	self:super('init')

	-- users
	self.lblUsersOnline = Label:New {
		x = 0,
		width = 80,
		y = 0,
		height = self.height - 10, -- hacks
		valign = "center",
		caption = "",
		font = {
			size = 16,
		},
	}
	local updateUserCount = function() 
		local userCount = lobby:GetUserCount()
		if userCount >= 10000000 then -- yeah
			userCount = math.floor((userCount / 1000000)) .. "M"
		elseif userCount >= 10000 then
			userCount = math.floor((userCount / 1000)) .. "k"
		end
		self.lblUsersOnline:SetCaption(i18n("users") .. ": " .. userCount)
	end
	--updateUserCount()
	lobby:AddListener("OnAddUser", updateUserCount)
	lobby:AddListener("OnRemoveUser", updateUserCount)

	self:AddControl(self.lblUsersOnline)

	-- battles
	self.lblBattlesOpen = Label:New {
		x = self.lblUsersOnline.x + self.lblUsersOnline.width + self.itemPadding,
		width = 90,
		y = 0,
		height = self.height - 10, -- hacks
		valign = "center",
		caption = "",
		font = {
			size = 16,
		},
	}
	local updateBattleCount = function() 
		local battleCount = lobby:GetBattleCount()
		if battleCount >= 10000000 then -- yeah
			battleCount = math.floor((battleCount / 1000000)) .. "M"
		elseif battleCount >= 10000 then
			battleCount = math.floor((battleCount / 1000)) .. "k"
		end
		self.lblBattlesOpen:SetCaption(i18n("battles") .. ": " .. battleCount)
	end
	lobby:AddListener("OnAccepted", 
		function(listener)
			updateBattleCount()
			lobby:RemoveListener("OnAccepted", listener)
		end
	)
	lobby:AddListener("OnBattleOpened", updateBattleCount)
	lobby:AddListener("OnBattleClosed", updateBattleCount)

	self:AddControl(self.lblBattlesOpen)

	-- queues 
	self.lblQueuesOpen = Label:New {
		x = self.lblBattlesOpen.x + self.lblBattlesOpen.width + self.itemPadding,
		width = 90,
		y = 0,
		height = self.height - 10, -- hacks
		valign = "center",
		caption = "",
		font = {
			size = 16,
		},
	}
	local updateQueueCount = function() 
		local queueCount = lobby:GetQueueCount()
		if queueCount >= 10000000 then -- yeah
			queueCount = math.floor((queueCount / 1000000)) .. "M"
		elseif queueCount >= 10000 then
			queueCount = math.floor((queueCount / 1000)) .. "k"
		end
		self.lblQueuesOpen:SetCaption(i18n("queues") .. ": " .. queueCount)
	end
	lobby:AddListener("OnAccepted", 
		function(listener)
			updateQueueCount()
			lobby:RemoveListener("OnAccepted", listener)
		end
	)
	lobby:AddListener("OnQueueOpened", updateQueueCount)
	lobby:AddListener("OnQueueClosed", updateQueueCount)
	lobby:AddListener("OnListQueues",  updateQueueCount)

	self:AddControl(self.lblQueuesOpen)
end