--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
  return {
    name      = "ChiliInspector",
    desc      = "",
    author    = "",
    date      = "2013",
    license   = "GPLv2",
    layer     = 3,
    enabled   = false  --  loaded by default?
  }
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local window0
local tree0
local label0
local Chili

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function trace(children, node)
	if not node then return end
	for i=1,#children do
		local obj = children[i]
		if obj.name ~= "wnd_inspector" then
			local nodec = node:Add(obj.classname .. ": " .. obj.name)
			trace(obj.children, nodec)
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:Initialize()
	Chili = WG.Chili

	if (not Chili) then
		widgetHandler:RemoveWidget()
		return
	end

	window0 = Chili.Window:New{
		name = "wnd_inspector",
		caption = "Inspector",
		x = 1200,
		y = 250,
		width  = 400,
		height = 400,
		parent = Chili.Screen0,

		children = {
			Chili.Label:New{
				name = "lbl_inspector_memusage",
				x=0, right=0,
				y=0, bottom=-20,
				align = "right", valign = "bottom",
				caption = "Lua MemUsage: 60MB",
				
			},
			Chili.ScrollPanel:New{
				x=0, right=0,
				y=20, bottom=20,
				children = {
					Chili.TreeView:New{
						name = "tree_inspector";
						width="100%";
						height="100%";
					},
				},
			},
			Chili.Button:New{
				x=0, right=0,
				y=-20, bottom=0,
				caption="update",
				OnMouseUp = {function() tree0.root:ClearChildren(); trace(Chili.Screen0.children, tree0.root) end},
			},
		},
	}

	tree0 = window0:GetObjectByName("tree_inspector")
	label0 = window0:GetObjectByName("lbl_inspector_memusage")

	trace(Chili.Screen0.children, tree0.root)
end

function widget:Shutdown()
	window0:Dispose()
end

local next = -math.huge
function widget:Update()
	if (os.clock() <= next) then
		return
	end
	next = os.clock() + 3

	label0:SetCaption("Lua MemUsage: " .. Chili.math.round(gcinfo() / 1024, 2) .. "MB")
end
