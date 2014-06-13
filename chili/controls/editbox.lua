--//=============================================================================

--- EditBox module

--- EditBox fields.
-- Inherits from Control.
-- @see control.Control
-- @table EditBox
-- @tparam {r,g,b,a} cursorColor cursor color, (default {0,0,1,0.7})
-- @tparam {r,g,b,a} selectionColor selection color, (default {0,1,1,0.3})
-- @string[opt="left"] align alignment
-- @string[opt="linecenter"] valign vertical alignment
-- @string[opt=""] text text contained in the editbox
-- @string[opt=""] hint hint to be displayed when there is no text and the control isn't focused
-- @int[opt=1] cursor cursor position
-- @bool passwordInput specifies whether the text should be treated as a password
EditBox = Control:Inherit{
  classname= "editbox",

  defaultWidth = 70,
  defaultHeight = 20,

  padding = {3,3,3,3},

  cursorColor = {0,0,1,0.7},
  selectionColor = {0,1,1,0.3},

  align    = "left",
  valign   = "linecenter",
  
  hintFont = table.merge({ color = {1,1,1,0.7} }, Control.font),

  text   = "",
  hint   = "",
  cursor = 1,
  offset = 1,
  selStart = nil,
  selEnd = nil,

  allowUnicode = true,
  passwordInput = false,
}

local this = EditBox
local inherited = this.inherited

--//=============================================================================

function EditBox:New(obj)
	obj = inherited.New(self,obj)
	obj._interactedTime = Spring.GetTimer()
	  --// create font
	obj.hintFont = Font:New(obj.hintFont)
	obj.hintFont:SetParent(obj)
	obj:SetText(obj.text)
	obj:RequestUpdate()
	return obj
end

function EditBox:Dispose(...)	
	Control.Dispose(self)
	self.hintFont:SetParent()
end

function EditBox:HitTest(x,y)
	return self
end

--//=============================================================================

--- Sets the EditBox text
-- @string newtext text to be set
function EditBox:SetText(newtext)
	if (self.text == newtext) then return end
	self.text = newtext
	self.cursor = 1
	self.offset = 1
 	self.selStart = nil
 	self.selEnd = nil
	self:UpdateLayout()
	self:Invalidate()
end


function EditBox:UpdateLayout()
  local font = self.font

  --FIXME
  if (self.autosize) then
    local w = font:GetTextWidth(self.text);
    local h, d, numLines = font:GetTextHeight(self.text);

    if (self.autoObeyLineHeight) then
      h = math.ceil(numLines * font:GetLineHeight())
    else
      h = math.ceil(h-d)
    end

    local x = self.x
    local y = self.y

    if self.valign == "center" then
      y = math.round(y + (self.height - h) * 0.5)
    elseif self.valign == "bottom" then
      y = y + self.height - h
    elseif self.valign == "top" then
    else
    end

    if self.align == "left" then
    elseif self.align == "right" then
      x = x + self.width - w
    elseif self.align == "center" then
      x = math.round(x + (self.width - w) * 0.5)
    end

    w = w + self.padding[1] + self.padding[3]
    h = h + self.padding[2] + self.padding[4]

    self:_UpdateConstraints(x,y,w,h)
  end

end

--//=============================================================================

function EditBox:Update(...)
	--FIXME add special UpdateFocus event?

	--// redraw every few frames for blinking cursor
	inherited.Update(self, ...)

	if self.state.focused then
		self:RequestUpdate()
		if (os.clock() >= (self._nextCursorRedraw or -math.huge)) then
			self._nextCursorRedraw = os.clock() + 0.1 --10FPS
			self:Invalidate()
		end
	end
end


function EditBox:MouseDown(x, y, ...)
	local clientX = self.clientArea[1]
	self.cursor = #self.text + 1 -- at end of text
	for i = self.offset, #self.text do
		local tmp = self.text:sub(self.offset, i)
		if self.font:GetTextWidth(tmp) > (x - clientX) then
			self.cursor = i
			break
		end
	end
	self._interactedTime = Spring.GetTimer()
	inherited.MouseDown(self, x, y, ...)
	self:Invalidate()
	return self
end

function EditBox:MouseUp(...)
	inherited.MouseUp(self, ...)
	self:Invalidate()
	return self
end

function EditBox:_ClearSelected()
    local left = self.selStart
    local right = self.selEnd
    if left > right then
        left, right = right, left
    end
    self.cursor = right
    local i = 0
    while self.cursor ~= left do
        self.text, self.cursor = Utf8BackspaceAt(self.text, self.cursor)
        i = i + 1
        if i > 100 then
            break
        end
    end
    self.selStart = nil
    self.selEnd = nil
end

function EditBox:KeyPress(key, mods, isRepeat, label, unicode, ...)
	local cp = self.cursor
	local txt = self.text
	if key == Spring.GetKeyCode("backspace") then
        if self.selStart == nil then
            self.text, self.cursor = Utf8BackspaceAt(txt, cp)
        else
            self:_ClearSelected()
        end
	elseif key == Spring.GetKeyCode("delete") then
        if self.selStart == nil then
		    self.text = Utf8DeleteAt(txt, cp)
        else
            self:_ClearSelected()
        end
	elseif key == Spring.GetKeyCode("left") then
		self.cursor = Utf8PrevChar(txt, cp)
	elseif key == Spring.GetKeyCode("right") then
		self.cursor = Utf8NextChar(txt, cp)
	elseif key == Spring.GetKeyCode("home") then
		self.cursor = 1
	elseif key == Spring.GetKeyCode("end") then
		self.cursor = #txt + 1
	elseif key ~= Spring.GetKeyCode("enter") and key ~= Spring.GetKeyCode("numpad_enter") then
		local utf8char = UnicodeToUtf8(unicode)
		if (not self.allowUnicode) then
			local success
			success, utf8char = pcall(string.char, unicode)
			if success then
				success = not utf8char:find("%c")
			end
			if (not success) then
				utf8char = nil
			end
		end

		if utf8char then
            if self.selStart ~= nil then
                self:_ClearSelected()
                txt = self.text
                cp = self.cursor
            end
			self.text = txt:sub(1, cp - 1) .. utf8char .. txt:sub(cp, #txt)
			self.cursor = cp + utf8char:len()
		else
			return false
		end
	end
    if mods.shift and 
        (key == Spring.GetKeyCode("left") or key == Spring.GetKeyCode("right") or key == Spring.GetKeyCode("home") or key == Spring.GetKeyCode("end")) then
        if not self.selStart then
            self.selStart = cp
        end
        self.selEnd = self.cursor
    end
    if not mods.shift and self.selStart then
        self.selStart = nil
        self.selEnd = nil
    end
	self._interactedTime = Spring.GetTimer()
	inherited.KeyPress(self, key, mods, isRepeat, label, unicode, ...)
	self:UpdateLayout()
	self:Invalidate()
	return self
end


function EditBox:TextInput(utf8char, ...)
	local unicode = utf8char
	if (not self.allowUnicode) then
		local success
		success, unicode = pcall(string.char, utf8char)
		if success then
			success = not unicode:find("%c")
		end
		if (not success) then
			unicode = nil
		end
	end

	if unicode then
		local cp  = self.cursor
		local txt = self.text
		if self.selStart ~= nil then
            self:_ClearSelected()
            txt = self.text
            cp = self.cursor
        end
		self.text = txt:sub(1, cp - 1) .. unicode .. txt:sub(cp, #txt)
		self.cursor = cp + unicode:len()
	--else
	--	return false
	end

	self._interactedTime = Spring.GetTimer()
	inherited.TextInput(self, utf8char, ...)
	self:UpdateLayout()
	self:Invalidate()
	return self
end

--//=============================================================================
