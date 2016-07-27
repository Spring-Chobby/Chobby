ListWindow = Component:extends{}

function ListWindow:init(parent, title, noWindow, windowClassname)
	
	self.CancelFunc = function ()
		self:HideWindow()
	end
	
	self.lblTitle = Label:New {
		x = 20,
		right = 5,
		y = 16,
		height = 20,
		font = Configuration:GetFont(3),
		caption = title,
	}

	self.btnClose = Button:New {
		right = 7,
		y = 5,
		width = 80,
		height = 45,
		caption = i18n("close"),
		font = Configuration:GetFont(3),
		classname = "negative_button",
		OnClick = {
			function()
				self.CancelFunc()
			end
		},
	}

	self.listPanel = ScrollPanel:New {
		x = 5,
		right = 5,
		y = 55,
		bottom = 10,
		borderColor = {0,0,0,0},
		horizontalScrollbar = false,
		OnResize = {
			function()
				self:OnResize()
			end
		}
	}
	
	local ControlType = Window
	if noWindow then
		ControlType = Control
	end

	self.window = ControlType:New {
		x = 0,
		right = 0,
		y = 0,
		bottom = 0,
		parent = parent,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		classname = windowClassname,
		children = {
			self.lblTitle,
			self.btnClose,
			self.listPanel,
		},
		OnDispose = {
			function()
				self:RemoveListeners()
			end
		},
	}
	
	self.columns = 1
	self.itemHeight = 60
	self.itemPadding = 20
	self.itemNames = {}
	self.itemPanelMapping = {}
	self.orderPanelMapping = {}
end

function ListWindow:OnResize()
	if self.listPanel and self.listPanel.clientWidth and self.minItemWidth then
		local myWidth = self.listPanel.clientWidth
		local widthFactor = math.floor(myWidth/self.minItemWidth)
		local newColumns = math.max(1, widthFactor)
		if self.columns ~= newColumns then
			self.columns = newColumns
			for i = 1, #self.orderPanelMapping do
				self:RecalculatePosition(i)
			end
		end
	end
end

function ListWindow:SetMinItemWidth(newMinItemWidth)
	if newMinItemWidth then
		self.minItemWidth = newMinItemWidth
		self:OnResize()
	else
		self.minItemWidth = false
	end
end

function ListWindow:HideWindow()
	ChiliFX:AddFadeEffect({
		obj = self.window, 
		time = 0.15,
		endValue = 0,
		startValue = 1,
		after = function()
			self.window:Hide()
		end
	})
	--self.window:Hide() --Dispose()
end

function ListWindow:AddListeners()
end

function ListWindow:RemoveListeners()
end

function ListWindow:Clear()
	self.listPanel:ClearChildren()
end

function ListWindow:AddRow(items, id)
	if self.itemPanelMapping[id] then
		Spring.Echo("Tried to add duplicate list window item", id)
		return
	end
	local thisWidth = items[#items].x + items[#items].width
		
	local itemNames = {}
	for i = 1, #items do
		itemNames[items[i].name] = items[i]
	end
	
	self.itemNames[id] = itemNames
	
	local container = Control:New {
		name = "container",
		width = "100%",
		y = 0,
		height = self.itemHeight,
		padding = {0, 0, 0, 0},
		children = items,
	}
	local panel = LayoutPanel:New {
		x = 0,
		right = 0,
		height = self.itemHeight,
		padding = {0, 0, 0, 0},
		itemMargin = {0, 0, 0, 0},
		itemPadding = {0, 0, 0, 0},
		children = { container },
	}
	
	local index = #self.listPanel.children + 1
	local x,y,width,height = self:CalulatePosition(index)
	local w = Control:New {
		x = x,
		width = width,
		y = y,
		height = height,
		children = { panel },
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		id = id,
		index = index
	}
	self.listPanel:AddChild(w)
	self.itemPanelMapping[id] = w
	self.orderPanelMapping[index] = w

	self:RecalculateOrder(id)
end

function ListWindow:GetRowPosition(id)
	if id and self.itemPanelMapping[id] then
		return self.itemPanelMapping[id].y
	end
end

function ListWindow:GetRowItems(id)
	return self.itemNames[id]
end

function ListWindow:CalulatePosition(index)
	local xAcross = ((index - 1)%self.columns)/self.columns
	local row = math.floor((index - 1)/self.columns)
	
	local x = math.floor(1000*xAcross)/10 .. "%"
	local y = 10 + row * (self.itemHeight + self.itemPadding)
	local width = math.floor(1000/self.columns)/10 .. "%"
	local height = self.itemHeight
	return x,y,width,height
end

function ListWindow:RecalculatePosition(index)
	local x,y,width,height = self:CalulatePosition(index)
	
	local child = self.orderPanelMapping[index]
	
	child._relativeBounds.left = x
	child._relativeBounds.width = width
	child:SetPos(nil, y, nil, height)
	child:UpdateClientArea()
end

-- res >  0: id1 before id2
-- res == 0: equal
-- res <  0: id2 before id1
function ListWindow:CompareItems(id1, id2)
	return 0
end

function ListWindow:SwapPlaces(panel1, panel2)
	tmp = panel1.index
	
	local x1,y1,w1,h1 = panel1._relativeBounds.left, panel1.y, panel1._relativeBounds.width, panel1.height
	local x2,y2,w2,h2 = panel2._relativeBounds.left, panel2.y, panel2._relativeBounds.width, panel2.height
	
	panel1._relativeBounds.left = x2
	panel1._relativeBounds.width = w2
	panel1:SetPos(nil, y2, nil, h2)
	panel1:UpdateClientArea()

	panel2._relativeBounds.left = x1
	panel2._relativeBounds.width = w1
	panel2:SetPos(nil, y1, nil, h1)
	panel2:UpdateClientArea()
	
	-- Swap positions in table
	panel1.index = panel2.index
	self.orderPanelMapping[panel1.index] = panel1
	
	panel2.index = tmp
	self.orderPanelMapping[panel2.index] = panel2
end

function ListWindow:RecalculateOrder(id)
	local panel = self.itemPanelMapping[id]
	local index = panel.index

	-- move panel up if needed
	while panel.index > 1 do
		local panel2 = self.orderPanelMapping[panel.index - 1]
		if self:CompareItems(panel.id, panel2.id) > 0 then
			self:SwapPlaces(panel, panel2)
		else
			break
		end
	end
	-- move panel down if needed
	while panel.index < #self.listPanel.children - 1 do
		local panel2 = self.orderPanelMapping[panel.index + 1]
		if self:CompareItems(panel.id, panel2.id) < 0 then
			self:SwapPlaces(panel, panel2)
		else
			break
		end
	end
end

function ListWindow:RemoveRow(id)
	local panel = self.itemPanelMapping[id]
	if not panel then
		return
	end
	local index = panel.index
	
	-- move elements up
	while index < #self.listPanel.children do
		local panel1 = self.orderPanelMapping[index]
		local panel2 = self.orderPanelMapping[index + 1]
		self:SwapPlaces(panel1, panel2)
		index = index + 1
	end
	self.orderPanelMapping[index] = nil

	self.listPanel:RemoveChild(panel)
	self.itemNames[id] = nil
	self.itemPanelMapping[id] = nil
end
