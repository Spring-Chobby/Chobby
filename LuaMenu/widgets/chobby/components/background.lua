Background = LCS.class{}

function Background:init()
	self:Enable()
	
	local function onConfigurationChange(listener, key, value)
		if key == "singleplayer_mode" then
			local file, focus = Configuration:GetBackgroundImage()
			self.backgroundFocus = focus
			self.backgroundImage.file = file
			local texInfo = gl.TextureInfo(file)
			self.width, self.height = texInfo.xsize, texInfo.ysize
			self.backgroundControl:Invalidate()
			self:Resize()
		end
	end
	Configuration:AddListener("OnConfigurationChange", onConfigurationChange)		
end

function Background:Resize(backgroundControl)
	backgroundControl = backgroundControl or self.backgroundControl
	if not self.backgroundImage then
		return
	end
	local width, height = self.width, self.height
	if not (width and height) then
		return
	end
	local xSize, ySize = Spring.GetWindowGeometry()
	
	local xFocus, yFocus = self.backgroundFocus[1], self.backgroundFocus[2]
	
	local p1, p2, p3, p4
	if ySize * width == xSize * height then
		p1 = 0
		p2 = 0
		p3 = 0
		p4 = 0
	elseif ySize * width > xSize * height then
		-- Screen is thinner than image.
		local padding = (xSize - width * ySize/height)
		p1 = xFocus * padding
		p2 = 0
		p3 = (1 - xFocus) * padding
		p4 = 0
	else
		-- Screen is wider than image.
		local padding = (ySize - height * xSize/width)
		p1 = 0
		p2 = yFocus * padding
		p3 = 0
		p4 = (1 - yFocus) * padding
	end
	self.backgroundImage:SetPos(p1, p2, xSize - p1 - p3, ySize - p2 - p4)
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
		local file, focus = Configuration:GetBackgroundImage()
		self.backgroundFocus = focus
		local texInfo = gl.TextureInfo(file)
		self.width, self.height = texInfo.xsize, texInfo.ysize	
		
		local eatInputSetFunction = {
			function ()
				return true
			end
		}
		
		self.backgroundImage = Image:New {
			x = 0,
			y = 0,
			right = 0,
			bottom = 0,
			keepAspect = false,
			file = file,
			
			-- Eat all the input so none of it reaches ingame when the menu is visible.
			OnMouseDown = eatInputSetFunction,
			OnKeyPress = eatInputSetFunction,
			OnMouseWheel = eatInputSetFunction,
		}

		
		self.backgroundControl = Control:New {
			name = "backgroundControl",
			x = 0,
			y = 0,
			right = 0,
			bottom = 0,
			padding = {0,0,0,0},
			margin = {0,0,0,0},
			parent = screen0,
			children = {
				self.backgroundImage
			},
			OnResize = {
				function (obj)
					self:Resize(obj)
				end
			},
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
