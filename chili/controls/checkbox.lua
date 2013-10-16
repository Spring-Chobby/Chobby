--//=============================================================================

--- Checkbox module

--- Checkbox fields.
-- Inherits from Control.
-- @see control.Control:New
-- @function Checkbox:New
-- @bool checked checkbox checked state, default: true
-- @string caption caption to appear in the checkbox, default: "text"
-- @string textalign text alignment, default: "left"
-- @string boxalign box alignment, default: "right"
-- @int boxsize box size, default: 10
-- @param textColor text color table {r,g,b,a}, default: {0,0,0,1}
-- @param OnChange listener functions for checked state changes
Checkbox = Control:Inherit{
  classname = "checkbox",
  checked   = true,
  caption   = "text",
  textalign = "left",
  boxalign  = "right",
  boxsize   = 10,

  textColor = {0,0,0,1},

  defaultWidth     = 70,
  defaultHeight    = 18,

  OnChange = {}
}

local this = Checkbox
local inherited = this.inherited

--//=============================================================================

function Checkbox:New(obj)
	obj = inherited.New(self,obj)
	obj.state.checked = obj.checked
	return obj
end

--//=============================================================================

--- Toggles the checked state
function Checkbox:Toggle()
  self:CallListeners(self.OnChange,not self.checked)
  self.checked = not self.checked
  self.state.checked = self.checked
  self:Invalidate()
end

--//=============================================================================

function Checkbox:DrawControl()
  --// gets overriden by the skin/theme
end

--//=============================================================================

function Checkbox:HitTest()
  return self
end

function Checkbox:MouseDown()
  self:Toggle()
  return self
end

--//=============================================================================
