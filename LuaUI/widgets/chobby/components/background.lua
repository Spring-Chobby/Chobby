Background = LCS.class{}

function Background:init()
	self.backgroundImage = "luaui/images/chobbyInABox.png"
	self.drawBackground = true
	self:SetEnabled(self.drawBackground)	
end

function Background:SetBackgroundImagePath(newImagePath)
	self.backgroundImage = newImagePath
end

function Background:SetEnabled(enable)
	if enable then
		self:Enable()
	else
		self:Disable()
	end
end

function Background:Enable()
	if self.background ~= nil then
		return
	end

	self.background = Control:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		padding = {0,0,0,0},
		margin = {0,0,0,0},
		parent = screen0
	}
	self.background:AddChild(Image:New {
		y = 0,
		x = 0,
		right = 0,
		bottom = 0,
		keepAspect = false,
		file = self.backgroundImage,
	})
	self.drawBackground = true
	self.background = nil
end

function Background:Disable()
	if self.background == nil then
		return
	end

	self.background:Dispose()
	self.drawBackground = false
	self.background = true
end
