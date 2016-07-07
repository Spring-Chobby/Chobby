PriorityPopup = Component:extends{}

function PriorityPopup:init(mainWindow)
	local sentTime
	local startTime = os.clock()
	
	self.mainWindow = mainWindow
	
	self.background = Control:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		padding = {0,0,0,0},
		margin = {0,0,0,0},
		parent = screen0,
		Draw = function()
			if not sentTime then
				local diff = os.clock() - startTime
				diff = math.min(0.1, diff) / 0.1

				gl.PushMatrix()
				gl.Color(0.5, 0.5, 0.5, 0.7 * diff)

				gl.BeginEnd(GL.QUADS,
					function()
						local w, h = Spring.GetScreenGeometry()

						gl.TexCoord(0, 1)
						gl.Vertex(0, 0)

						gl.TexCoord(0, 0)
						gl.Vertex(0, h)

						gl.TexCoord(1, 0)
						gl.Vertex(w, h)

						gl.TexCoord(1, 1)
						gl.Vertex(w, 0)
					end
				)
				gl.PopMatrix()
			else
				local diff = os.clock() - sentTime
				diff = math.min(0.1, diff) / 0.1
				if diff == 1 then
					self.background:Dispose()
				end

				gl.PushMatrix()
				gl.Color(0.5, 0.5, 0.5, 0.7 * (1 - diff))

				gl.BeginEnd(GL.QUADS,
					function()
						local w, h = Spring.GetScreenGeometry()

						gl.TexCoord(0, 1)
						gl.Vertex(0, 0)

						gl.TexCoord(0, 0)
						gl.Vertex(0, h)

						gl.TexCoord(1, 0)
						gl.Vertex(w, h)

						gl.TexCoord(1, 1)
						gl.Vertex(w, 0)
					end
				)
				gl.PopMatrix()
			end
		end,
		OnMouseDown = {
			function ()
				return true -- Eat all the mouse clicks.
			end
		}
	}
	
	self.mainWindow.OnDispose = self.mainWindow.OnDispose or {}
	self.mainWindow.OnDispose[#self.mainWindow.OnDispose + 1] = function()
		self:unregister()
		self.background:Dispose()
	end
	
	local sw, sh = Spring.GetWindowGeometry()
	self:ViewResize(sw, sh)
	
	self:super('init')
end

function PriorityPopup:ViewResize(screenWidth, screenHeight)
	self.background:BringToFront()
	self.mainWindow:BringToFront()
	
	self.mainWindow:SetPos(
		(screenWidth - self.mainWindow.width)/2,
		(screenHeight - self.mainWindow.height)/2
	)
end

function PriorityPopup:GetWindow()
	return self.mainWindow
end

function PriorityPopup:ClosePopup()
	self.mainWindow:Dispose()
end
