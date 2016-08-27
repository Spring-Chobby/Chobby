SBItem = Component:extends{}

function SBItem:init()
	-- self:super('init')
	Component.init(self) 
	-- hack because self:super isn't working with multiple levels of inheritence in current LCS

	-- aligning
	self.height = 50

	self.iconSize = 32
	self.imagePadding = 8
	self.itemPadding = 10

	self.children = {}
end

function SBItem:AddControl(control)
	table.insert(self.children, control)
	--self.container:AddChild(control)
end

function SBItem:GetControl()
	local w, h = 0, self.height
	for _, child in pairs(self.children) do
		w = math.max(w, child.x + child.width)
	end
	self.container = {
		x = 0,
		y = 0,
		width = w,
		height = h,
		padding = {0, 0, 0, 0},
		children = self.children,
	}
	
	return self.container
end