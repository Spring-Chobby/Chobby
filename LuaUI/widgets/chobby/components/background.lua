Background = LCS.class{}

function Background:init(startEnabled)
	self:SetEnabled(startEnabled)
	
	local function onConfigurationChange(listener, key, value)
		if key == "singleplayer_mode" then
			self.backgroundImage.file = Configuration:GetBackgroundImage()
			self.backgroundImage:Invalidate()
		end
	end
	Configuration:AddListener("OnConfigurationChange", onConfigurationChange)		
end

function Background:SetEnabled(enable)
	if enable then
		self:Enable()
	else
		self:Disable()
	end
end

function Background:Enable()
	if not self.backgroundControl then
		self.backgroundControl = Control:New {
			x = 0,
			y = 0,
			right = 0,
			bottom = 0,
			padding = {0,0,0,0},
			margin = {0,0,0,0},
			parent = screen0
		}
		self.backgroundImage = Image:New {
			y = 0,
			x = 0,
			right = 0,
			bottom = 0,
			keepAspect = false,
			file = Configuration:GetBackgroundImage(),
			parent = self.backgroundControl
		}
	end
	if not self.backgroundImage.visible then
		self.backgroundImage:Show()
	end
end

function Background:Disable()
	if self.backgroundImage and self.backgroundImage.visible then
		self.backgroundImage:Hide()
	end
end
