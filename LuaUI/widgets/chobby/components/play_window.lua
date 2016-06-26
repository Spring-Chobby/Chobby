PlayWindow = LCS.class{}

--local fontName = "libs/chiliui/chili/skins/Robocracy/fonts/n019003l.pfb"
local fontName = nil--"libs/chiliui/chili/skins/Robocracy/fonts/n019003l.pfb"
-- precompute font FIXME: it's ugly and not used directly
function getFont() 
	return {
		size = 16,
		outlineWidth = 6,
		outlineHeight = 6,
		outline = true,
		outlineColor = {0.54,0.72,1,0.3},
		autoOutlineColor = false,
		font = fontName
	}
end

function PlayWindow:init()
	-- Singleplayer
	self.lblPlaySingleplayer = Label:New {
		x = 20,
		width = 100,
		y = 0,
		height = 20,
		caption = i18n("singleplayer"),
		font = {
			size = 20,
		},
	}
	playButtonW = 160
	playButtonH = 70
	self.btnPlaySingleplayer = Button:New {
		x = 20,
		y = 40,
		height = playButtonH,
		width = playButtonW,
		caption = i18n("skirmish_caps"),
		tooltip = i18n("play_singleplayer_game"),
		font = {
			size = 16,
			outlineWidth = 5,
			outlineHeight = 5,
			outline = true,
		},
		OnClick = {
			function()
				self:HideWindows()
				self:SpawnSkirmishWindow()
			end
		},
	}

	self.line = Line:New {
		x = 0,
		y = 140,
		width = 250,
	}

	-- Multiplayer
	self.lblPlayMultiplayer = Label:New {
		x = 20,
		width = 100,
		y = 160,
		height = 20,
		caption = i18n("multiplayer"),
		font = {
			size = 20,
		},
	}

	self.btnPlayMultiplayerNormal = Button:New {
		x = 20,
		y = 200,
		height = playButtonH,
		width = playButtonW,
		caption = i18n("matchmaking_caps"),
		tooltip = i18n("play_normal_multiplayer_game"),
		font = {
			size = 16,
			outlineWidth = 5,
			outlineHeight = 5,
			outline = true,
		},
		OnClick = {
			function()
				self:HideWindows()
				self:SpawnQueueListWindow()
			end
		},
	}

	self.btnPlayMultiplayerCustom = Button:New {
		x = 20,
		y = 280,
		height = playButtonH,
		width = playButtonW,
		caption = i18n("custom_caps"),
		tooltip = i18n('play_custom_multiplayer_game'),
		font = {
			size = 16,
			outlineWidth = 5,
			outlineHeight = 5,
			outline = true,
		},
		OnClick = {
			function()
				self:HideWindows()
				self:SpawnBattleListWindow()
			end
		},
	}

	self.window = Window:New {
		x = 5,
		--width = "60%",
		width = "60%",
		y = 60,
		bottom = 0,
		minWidth = 700,
		parent = screen0,
		resizable = false,
		draggable = false,
		padding = {0, 20, 0, 0},
		children = {
			self.lblPlaySingleplayer,
			self.lblPlayMultiplayer,
			self.btnPlaySingleplayer,
			self.line,
			self.btnPlayMultiplayerNormal,
			self.btnPlayMultiplayerCustom,
		}
	}
	-- caching:
	self.skirmishWindow = SkirmishWindow(self.window)
	self.queueListWindow = QueueListWindow(self.window)
	self.battleListWindow = BattleListWindow(self.window)
	self:HideWindows()


-- 	lobby:AddListener("OnCommandReceived",
--         function(listner, command)
-- 			Spring.Echo("<" .. command)
--         end
--     )
	lobby:ListQueues()
end

function PlayWindow:HideWindows()
	if self.skirmishWindow.window.visible then
		self.skirmishWindow.window:Hide()
	end
	if self.queueListWindow.window.visible then
		self.queueListWindow.window:Hide()
	end
	if self.battleListWindow.window.visible then
		self.battleListWindow.window:Hide()
	end
end

function PlayWindow:SpawnSkirmishWindow()
	if not self.skirmishWindow then
		self.skirmishWindow = SkirmishWindow(self.window)
	end
	if not self.skirmishWindow.visible then
		self.skirmishWindow.window:Show()
	else
		return
	end
end

function PlayWindow:SpawnQueueListWindow()
	if not self.queueListWindow then
		self.queueListWindow = QueueListWindow(self.window)
	end
	if not self.queueListWindow.visible then
		self.queueListWindow.window:Show()
	else
		return
	end

	local oldCaption = self.btnPlayMultiplayerNormal.caption	
	self.btnPlayMultiplayerNormal:SetCaption(Configuration:GetSelectedColor() .. oldCaption .. "\b")	
	oldFont = self.btnPlayMultiplayerNormal.font
	self.btnPlayMultiplayerNormal.font = Chili.Font:New(getFont())
	self.btnPlayMultiplayerNormal.font:SetParent(self.btnPlayMultiplayerNormal)
	self.btnPlayMultiplayerNormal.backgroundColor = Configuration:GetButtonSelectedColor()
	self.btnPlayMultiplayerNormal:Invalidate()

	local oldCaptionLbl = self.lblPlayMultiplayer.caption	
	self.lblPlayMultiplayer:SetCaption(Configuration:GetSelectedColor() .. oldCaptionLbl .. "\b")
	oldFontLbl = self.lblPlayMultiplayer.font
	self.lblPlayMultiplayer.font = Chili.Font:New({
			size = 20,
			font = fontName,
		}
	)
	self.lblPlayMultiplayer.font:SetParent(self.lblPlayMultiplayer)
	self.lblPlayMultiplayer:Invalidate()

	self.queueListWindow.window.OnHide = { 
		function() 
			--self.queueListWindow = nil

			self.btnPlayMultiplayerNormal.font = oldFont
			self.btnPlayMultiplayerNormal.font:SetParent(self.btnPlayMultiplayerNormal)
			self.btnPlayMultiplayerNormal:SetCaption(oldCaption)
			self.btnPlayMultiplayerNormal.backgroundColor = self.btnPlayMultiplayerCustom.backgroundColor
			self.btnPlayMultiplayerNormal:Invalidate()

			--self.lblPlayMultiplayer.font = oldFontLbl
			--self.lblPlayMultiplayer.font:SetParent(self.lblPlayMultiplayer)
			self.lblPlayMultiplayer:SetCaption(oldCaptionLbl)
			self.lblPlayMultiplayer:Invalidate()
		end 
	}
end

function PlayWindow:SpawnBattleListWindow()
	if not self.battleListWindow then
		self.battleListWindow = BattleListWindow(self.window)
	end
	if not self.battleListWindow.window.visible then
        self.battleListWindow.window:Show()
	else
		return
	end

	local oldCaption = self.btnPlayMultiplayerCustom.caption
	self.btnPlayMultiplayerCustom:SetCaption(Configuration:GetSelectedColor() .. oldCaption .. "\b")	
	oldFont = self.btnPlayMultiplayerCustom.font
	self.btnPlayMultiplayerCustom.font = Chili.Font:New(getFont())
	self.btnPlayMultiplayerCustom.font:SetParent(self.btnPlayMultiplayerCustom)
	self.btnPlayMultiplayerCustom.backgroundColor = Configuration:GetButtonSelectedColor()
	self.btnPlayMultiplayerCustom:Invalidate()

	local oldCaptionLbl = self.lblPlayMultiplayer.caption	
	self.lblPlayMultiplayer:SetCaption(Configuration:GetSelectedColor() .. oldCaptionLbl .. "\b")
	oldFontLbl = self.lblPlayMultiplayer.font
	self.lblPlayMultiplayer.font = Chili.Font:New({
			size = 20,
			font = fontName,
		}
	)
	self.lblPlayMultiplayer.font:SetParent(self.lblPlayMultiplayer)
	self.lblPlayMultiplayer:Invalidate()

	self.battleListWindow.window.OnHide = { 
		function() 
			--self.battleListWindow = nil

			self.btnPlayMultiplayerCustom.font = oldFont
			self.btnPlayMultiplayerCustom.font:SetParent(self.btnPlayMultiplayerCustom)
			self.btnPlayMultiplayerCustom:SetCaption(oldCaption)
			self.btnPlayMultiplayerCustom.backgroundColor = self.btnPlayMultiplayerNormal.backgroundColor
			self.btnPlayMultiplayerCustom:Invalidate()

			self.lblPlayMultiplayer.font = oldFontLbl
			self.lblPlayMultiplayer.font:SetParent(self.lblPlayMultiplayer)
			self.lblPlayMultiplayer:SetCaption(oldCaptionLbl)
			self.lblPlayMultiplayer:Invalidate()
		end 
	}
end

local cache = {
	Chili.Font:New(getFont()),
	Chili.Font:New({
		size = 20,
		font = fontName,
		--outlineWidth = 15,
		--outlineHeight = 15,
		--outline = true,
	})
}
