StatusBar = Component:extends{}

function StatusBar:init()
	self:super('init')
	self.panel = Window:New {
		x = 5,
		right = 5,
		y = 5,
		height = 50,
		minHeight = 50,
		border = 1,
		parent = screen0,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
	}

	-- configuration
	self.showConnectionStatus = true
	self.showServerStatus = true
	self.showPlayerWelcome = true

	self.items = {}

	self.leftPanel = LayoutPanel:New {
		x = 0,
		y = 0,
		width = "100%",
		height = self.panel.height,
		padding = {0, 0, 0, 0},
		itemMargin = {0, 0, 0, 0},
		itemPadding = {0, 0, 0, 0},
		parent = self.panel,
		centerItems = false,
	}
	self.centerPanel = LayoutPanel:New {
		x = 0,
		y = 0,
		width = "100%",
		height = self.panel.height,
		padding = {0, 0, 0, 0},
		itemMargin = {0, 0, 0, 0},
		itemPadding = {0, 0, 0, 0},
		parent = self.panel,
		centerItems = true,
	}
	-- Can't use LayoutPanel that would stick to the right
	self.rightPanel = Control:New {
		right = 0,
		y = 0,
		width = "30%",
		height = self.panel.height,
		padding = {0, 0, 0, 0},
		itemMargin = {0, 0, 0, 0},
		itemPadding = {0, 0, 0, 0},
		parent = self.panel,
	}

	if self.showConnectionStatus then self:AddConnectionStatus() end
	if self.showServerStatus then self:AddServerStatus() end
	if self.showPlayerWelcome then self:AddPlayerWelcome() end

	-- this order must be preserved for aligning
	self:AddMenuIcon()
	self:AddFriendsIcon()
	self:AddDownloadsIcon()
	self:AddErrorsIcon()
end

function StatusBar:AddItem(item, pos)
	local panel
	local ctrl = item:GetControl()
	if pos == "left" then
		panel = self.leftPanel
	elseif pos == "center" then
		panel = self.centerPanel
	elseif pos == "right" then
		-- hacks as usual (custom align)
		panel = self.rightPanel
		ctrl.right = panel._w or 5
		panel._w = ctrl.right + ctrl.width
		ctrl.x = nil
	else
		Spring.Log("chobby", LOG.ERROR, "Wrong orientation passed to status bar: " .. tostring(pos))
		return false
	end

	panel:AddChild(Control:New(ctrl) )

	table.insert(self.items, item)
end

-- left
function StatusBar:AddConnectionStatus()
	self:AddItem(SBConnectionStatus(), "left")
end
function StatusBar:AddServerStatus()
	self:AddItem(SBServerStatus(), "left")
end

-- center
function StatusBar:AddPlayerWelcome()
	self:AddItem(SBPlayerWelcome(), "center")
end

-- right
function StatusBar:AddMenuIcon()
	self:AddItem(SBMenuIcon(), "right")
end
function StatusBar:AddFriendsIcon()
self:AddItem(SBFriendsIcon(), "right")
end
function StatusBar:AddDownloadsIcon()
	self:AddItem(SBDownloadsIcon(), "right")
end
function StatusBar:AddErrorsIcon()
	self:AddItem(SBErrorsIcon(), "right")
end
