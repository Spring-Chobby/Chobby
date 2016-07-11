--//=============================================================================

--- DetachableTabPanel module (based on TabPanel)

--- DetachableTabPanel fields.
-- Inherits from LayoutPanel.
-- @see layoutpanel.LayoutPanel
-- @table DetachableTabPanel
-- @tparam {tab1,tab2,...} tabs contained in the tab panel, each tab has a .name (string) and a .children field (table of Controls)(default {})
-- @tparam chili.Control currentTab currently visible tab
DetachableTabPanel = LayoutPanel:Inherit{
  classname     = "detachabletabpanel",
  orientation   = "vertical",
  resizeItems   = false,
  itemPadding   = {0, 0, 0, 0},
  itemMargin    = {0, 0, 0, 0},
  tabs          = {},
  currentTab    = {},
  OnTabChange   = {},
  OnTabClick    = {},
}

local this = DetachableTabPanel
local inherited = this.inherited

--//=============================================================================

function DetachableTabPanel:New(obj)
	obj = inherited.New(self,obj)
	
	obj.tabBar = TabBar:New {
		tabs = obj.tabs,
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
	}
  
	obj.currentTab = Control:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		padding = {0, 0, 0, 0},
	}
	obj:AddChild(obj.currentTab)
	obj.tabIndexMapping = {}
	for i=1, #obj.tabs do
		local tabName = obj.tabs[i].name	
		local tabFrame = Control:New {
			padding = {0, 0, 0, 0},
			x = 0,
			y = 0,
			right = 0,
			bottom = 0,
			children = obj.tabs[i].children
		}
		obj.tabIndexMapping[tabName] = tabFrame
		obj.currentTab:AddChild(tabFrame)
		if i == 1 then
			obj.currentFrame = tabFrame
		else
			tabFrame:SetVisibility(false)
		end
	end
	obj.tabBar.OnChange = { function(tabbar, tabname) obj:ChangeTab(tabname) end }
	return obj
end

function DetachableTabPanel:AddTab(tab)
    local tabbar = self.tabBar
	Spring.Echo("tab.name", tab.name)
    tabbar:AddChild(
        TabBarItem:New{name = tab.name, caption = tab.caption or tab.name, defaultWidth = tabbar.minItemWidth, defaultHeight = tabbar.minItemHeight} --FIXME: implement an "Add Tab in TabBar too"
    )
    local tabFrame = Control:New {
        padding = {0, 0, 0, 0},
        x = 0,
        y = 0,
        right = 0,
        bottom = 0,
        children = tab.children
    }
    self.tabIndexMapping[tab.name] = tabFrame
    self.currentTab:AddChild(tabFrame)
    tabFrame:SetVisibility(false)
end

function DetachableTabPanel:RemoveTab(name)
    self.tabBar:Remove(name)
    self.currentTab:RemoveChild(self.tabIndexMapping[name])
    self.tabIndexMapping[name] = nil
end

--//=============================================================================

function DetachableTabPanel:ChangeTab(tabname)
	self:CallListeners(self.OnTabClick, tabname)
	if not tabname or not self.tabIndexMapping[tabname] then
		return
	end
	if self.currentFrame == self.tabIndexMapping[tabname] then
		return
	end
	self.currentFrame:SetVisibility(false)
	self.currentFrame = self.tabIndexMapping[tabname]
	self.currentFrame:SetVisibility(true)
	self:CallListeners(self.OnTabChange, tabname)
end

--//=============================================================================