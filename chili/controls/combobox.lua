--//=============================================================================
ComboBox = Button:Inherit {
  classname = "combobox",
  caption = 'combobox',
  defaultWidth  = 70,
  defaultHeight = 20,
  items = { "items" },
  selected = 1,
  OnSelect = {},
}


local this = ComboBox
local inherited = this.inherited

function ComboBox:New(obj)
  if #obj.items > 0 then
    obj.caption = obj.items[1]
  end
  obj = inherited.New(self,obj)
  if obj.selected == nil then
    obj.selected = 1
  end
  if obj.selected > 0 then
    obj:Select(obj.selected)
  end
  return obj
end

function ComboBox:Select(itemIdx)
  if #self.items == 0 then
    return
  end
  if (type(itemIdx)=="number") then
    self.selected = itemIdx
    self.caption = self.items[itemIdx]
    self:CallListeners(self.OnSelect, itemIdx, true)
    self:Invalidate()
  end
end

function ComboBox:_CloseWindow()
  if self._dropDownWindow ~= nil then
    self._dropDownWindow:Dispose()
    self._dropDownWindow = nil
  end
  if (self.state.pressed) then
    self.state.pressed = false
    self:Invalidate()
    return self
  end
end

function ComboBox:FocusUpdate()
  if not self.state.focused then
    self:_CloseWindow()
  end
end

function ComboBox:MouseDown(...)
  self.state.pressed = true
  if self._dropDownWindow == nil then
    local screen0 = self
    --local sx, sy = self:LocalToScreen(self.x, self.y)
    -- TODO: this should work ^^, but it doesn't; the following gets the component's current absolute screen position
    local sx = self.x
    local sy = self.y
    while screen0.parent ~= nil do
      screen0 = screen0.parent
      if screen0.classname == "scrollpanel" then
        sx = sx - screen0.scrollPosX
        sy = sy - screen0.scrollPosY
      end
      sx = sx + screen0.x
      sy = sy + screen0.y	  
    end
    sy = sy + self.height + 10
    sx = sx + 10

    labels = {}
    largestStr = 0
    labelHeight = 20
    for i = 1, #self.items do
      largestStr = math.max(largestStr, #self.items[i])
      local newBtn = Button:New {
        caption = self.items[i],
        width = '100%',
        height = labelHeight,
        OnMouseUp = { function()
          self:Select(i)
          self:_CloseWindow()
        end }
      }
      if i == self.selected then
        newBtn.backgroundColor = self.focusColor
      end
      table.insert(labels, newBtn)
    end
    estimatedWidth = 20 + largestStr * 10
    estimatedWidth = math.min(estimatedWidth, 500)
    estimatedWidth = math.max(estimatedWidth, self.width)

    local height = math.min(200, labelHeight * #labels) + 10
    height = math.max(50, height)
    if sy + height > screen0.height then
      y = sy - height - 40
    else
      y = sy
    end
    dropDownWindow = Window:New {
      parent = screen0,
      clientWidth = estimatedWidth,
      clientHeight = height,
      resizable = false,
      draggable = false,
      x = sx,
      y = y,
      children = {
        ScrollPanel:New {
          width = "100%",
          height = "100%",
          horizontalScrollBar = false,
          children = {
            StackPanel:New {
              orientation = 'horizontal',
              width = '100%',
              height = labelHeight * #labels,
              resizeItems = false,
              padding = {0,0,0,0},
              itemPadding = {0,0,0,0},
              itemMargin = {0,0,0,0},
              children = labels,
              borderThickness = 0,
            },
          },
        }
      }
    }
    self._dropDownWindow = dropDownWindow
  else
    self:_CloseWindow()
  end

  self:Invalidate()
  return self
end

function ComboBox:MouseUp(...)
  self:Invalidate()
  return self
  -- this exists to override Button:MouseUp so it doesn't modify .state.pressed
end
