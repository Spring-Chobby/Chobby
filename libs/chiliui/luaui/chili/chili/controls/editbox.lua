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
  classname = "editbox",

  defaultWidth = 70,
  defaultHeight = 20,

  padding = {3,3,3,3},

  cursorColor = {0,0,1,0.7},
  selectionColor = {0,1,1,0.3},

  align    = "left",
  valign   = "linecenter",

  hintFont = table.merge({ color = {1,1,1,0.7} }, Control.font),

  text   = "", -- Do NOT use directly.
  hint   = "",
  cursor = 1,
  offset = 1,
  selStart = nil,
  selEnd = nil,

  editable = true,
  selectable = true,
  multiline = false,

  passwordInput = false,
  lines = {},
  cursorX = 1,
  cursorY = 1,
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
	local text = obj.text
	obj.text = nil
	obj:SetText(text)
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
	self.selStartY = nil
	self.selEnd = nil
	self.selEndY = nil
	self.lines = {}
	-- TODO: Should first split into multiple lines by "\n" and add each separately
	self:AddLine(self.text)
	self:UpdateLayout()
	self:Invalidate()
end

local function explode(div,str) -- credit: http://richard.warburton.it
  if (div=='') then return false end
  local pos,arr = 0,{}
  -- for each divider found
  for st,sp in function() return string.find(str,div,pos,true) end do
    table.insert(arr,string.sub(str,pos,st-1)) -- Attach chars left of current divider
    pos = sp + 1 -- Jump past current divider
  end
  table.insert(arr,string.sub(str,pos)) -- Attach chars right of last divider
  return arr
end

-- will separate into multiple lines if too long
function EditBox:AddLine(text)
	local font = self.font
	local padding = self.padding
	local width  = self.width - padding[1] - padding[3]
	local height = self.height - padding[2] - padding[4]
	if self.autoHeight then
		height = 1e9
	end
	local wrappedText = font:WrapText(text, width, height)

	local y = 0
	local fontLineHeight = font:GetLineHeight()
	if self.lines[#self.lines] ~= nil then
		y = self.lines[#self.lines].y + fontLineHeight
	end
	for _, line in pairs(explode("\n", wrappedText)) do
	  local th, td = font:GetTextHeight(line)
	  table.insert(self.lines, {
		  text = line,
		  th   = th,
		  td   = td,
		  lh   = fontLineHeight,
		  tw   = font:GetTextWidth(line),
		  y    = y,
	  })
	  y = y + fontLineHeight
    end
	if self.autoHeight then
		local totalHeight = #self.lines * fontLineHeight
		self:Resize(nil, totalHeight, true, true)
	end
	--   if self.autoHeight then
--     local textHeight,textDescender,numLines = font:GetTextHeight(self._wrappedText)
--     textHeight = textHeight-textDescender
-- 
--     if (self.autoObeyLineHeight) then
--       if (numLines>1) then
--         textHeight = numLines * font:GetLineHeight()
--       else
--         --// AscenderHeight = LineHeight w/o such deep chars as 'g','p',...
--         textHeight = math.min( math.max(textHeight, font:GetAscenderHeight()), font:GetLineHeight())
--       end
--     end
-- 
--     self:Resize(nil, textHeight, true, true)
--   end
	self:RequestUpdate()
	self:Invalidate()
end


function EditBox:UpdateLayout()
--   if self.multiline then
-- 	local lines = {}
-- 	for i = 1, #self.lines do
-- 		table.insert(lines, self.lines[i].text)
-- 	end
-- 	local txt = table.concat(lines, "\n")
-- 
-- 	self:SetText(txt)
--   end
  local font = self.font

	if self.autoHeight then
		local fontLineHeight = font:GetLineHeight()
		local totalHeight = #self.lines * fontLineHeight
		self:Resize(nil, totalHeight, true, true)
	end
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

	if self.state.focused and self.editable then
		self:RequestUpdate()
		if (os.clock() >= (self._nextCursorRedraw or -math.huge)) then
			self._nextCursorRedraw = os.clock() + 0.1 --10FPS
			self:Invalidate()
		end
	end
end

function EditBox:_SetCursorByMousePos(x, y)
	local clientX, clientY = self.clientArea[1], self.clientArea[2]
	if x - clientX < 0 then
		self.offset = self.offset - 1
		self.offset = math.max(0, self.offset)
		self.cursor = self.offset + 1
	else
		local text = self.text
		-- properly accounts for passworded text where characters are represented as "*"
		-- TODO: what if the passworded text is displayed differently? this is using assumptions about the skin
		if #text > 0 and self.passwordInput then 
			text = string.rep("*", #text)
		end
		self.cursorY = #self.lines
		for i, line in pairs(self.lines) do
			if line.y > y - clientY then
				self.cursorY = math.max(1, i-1)
				break
			end
		end
		local selLine = self.lines[self.cursorY]
		if not selLine then return end
		selLine = selLine.text
		self.cursor = #selLine + 1
		for i = 1, #selLine do
			local tmp = selLine:sub(1, i)
			if self.font:GetTextWidth(tmp) > (x - clientX) then
				self.cursor = i
				break
			end
		end
--         for i = self.offset, #text do
--            local tmp = text:sub(self.offset, i)
--            local h, d = self.font:GetTextHeight(tmp)
--            if h-d > (y - clientY) then
-- 				self.cursor = i
-- 				break
-- 			end
--         end
--         Spring.Echo(self.cursor, #text)
-- 		for i = self.cursor, #text do
-- 			local tmp = text:sub(self.offset, i)
-- 			if self.font:GetTextWidth(tmp) > (x - clientX) then
-- 				self.cursor = i
-- 				break
-- 			end
-- 		end
	end
end

function EditBox:MouseDown(x, y, ...)
	if not self.selectable then
		return false
	end
	local _, _, _, shift = Spring.GetModKeyState()
	local cp, cpy = self.cursor, self.cursorY
	self:_SetCursorByMousePos(x, y)
	if shift then
		if not self.selStart then
			self.selStart = cp
			self.selStartY = cpy
		end
		self.selEnd = self.cursor
		self.selEndY = self.cursorY
	elseif self.selStart then
		self.selStart = nil
		self.selStartY = nil
		self.selEnd = nil
		self.selEndY = nil
	end
	
	self._interactedTime = Spring.GetTimer()
	inherited.MouseDown(self, x, y, ...)
	self:Invalidate()
	return self
end

function EditBox:MouseMove(x, y, dx, dy, button)
	if button ~= 1 then
		return inherited.MouseMove(self, x, y, dx, dy, button)
	end

	local _, _, _, shift = Spring.GetModKeyState()
	local cp, cpy = self.cursor, self.cursorY
	self:_SetCursorByMousePos(x, y)
	if not self.selStart then
		self.selStart = cp
		self.selStartY = cpy
	end
	self.selEnd = self.cursor
	self.selEndY = self.cursorY

	self._interactedTime = Spring.GetTimer()
	inherited.MouseMove(self, x, y, dx, dy, button)
	self:Invalidate()
	return self
end

function EditBox:MouseUp(...)
	inherited.MouseUp(self, ...)
	self:Invalidate()
	return self
end

function EditBox:Select(startIndex, endIndex)
	self.selStart = startIndex
	self.selEnd = endIndex
	self:Invalidate()
end

function EditBox:ClearSelected()
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
	self:Invalidate()
end


function EditBox:KeyPress(key, mods, isRepeat, label, unicode, ...)
	local cp = self.cursor
	local txt = self.text

	-- enter & return
	if (key == Spring.GetKeyCode("esc") or key == Spring.GetKeyCode("enter") or key == Spring.GetKeyCode("numpad_enter")) and self.editable then
		return inherited.KeyPress(self, key, mods, isRepeat, label, unicode, ...)

	-- deletions
	elseif key == Spring.GetKeyCode("backspace") and self.editable then
		if self.selStart == nil then
			if mods.ctrl then
				repeat
					self.text, self.cursor = Utf8BackspaceAt(self.text, self.cursor)
				until self.cursor == 1 or (self.text:sub(self.cursor-2, self.cursor-2) ~= " " and self.text:sub(self.cursor-1, self.cursor-1) == " ")
			else
				self.text, self.cursor = Utf8BackspaceAt(self.text, self.cursor)
			end
		else
			self:ClearSelected()
		end
	elseif key == Spring.GetKeyCode("delete") and self.editable then
		if self.selStart == nil then
			if mods.ctrl then
				repeat
					self.text = Utf8DeleteAt(self.text, self.cursor)
				until self.cursor >= #self.text-1 or (self.text:sub(self.cursor, self.cursor) == " " and self.text:sub(self.cursor+1, self.cursor+1) ~= " ")
			else
			self.text = Utf8DeleteAt(txt, cp)
			end
		else
			self:ClearSelected()
		end

	-- cursor movement
	elseif key == Spring.GetKeyCode("left") then
		if mods.ctrl then
			repeat
				self.cursor = Utf8PrevChar(txt, self.cursor)
			until self.cursor == 1 or (txt:sub(self.cursor-1, self.cursor-1) ~= " " and txt:sub(self.cursor, self.cursor) == " ")
		else
		self.cursor = Utf8PrevChar(txt, cp)
		end
	elseif key == Spring.GetKeyCode("right") then
		if mods.ctrl then
			repeat
				self.cursor = Utf8NextChar(txt, self.cursor)
			until self.cursor >= #txt-1 or (txt:sub(self.cursor-1, self.cursor-1) == " " and txt:sub(self.cursor, self.cursor) ~= " ")
		else
		self.cursor = Utf8NextChar(txt, cp)
		end
	elseif key == Spring.GetKeyCode("home") then
		self.cursor = 1
	elseif key == Spring.GetKeyCode("end") then
		self.cursor = #txt + 1

	-- copy & paste
	elseif mods.ctrl and (key == Spring.GetKeyCode("c") or (key == Spring.GetKeyCode("x") and self.editable)) then
		local sy = self.selStartY
		local ey = self.selEndY
		local s = self.selStart
		local e = self.selEnd
		if s and e then
			if self.multiline and sy > ey then
				sy, ey = sy, ey
				s, e = e, s
			elseif sy == ey and s > e then
				s, e = e, s
			end
			if self.multiline then
				txt = self.lines[sy].text
			end
			if not self.multiline or sy == ey then
				txt = txt:sub(s, e - 1)
			else
				local lines = {}
				local topText = self.lines[sy].text
				local bottomText = self.lines[ey].text
				table.insert(lines, topText:sub(s))
				for i = sy+1, ey-1 do
					table.insert(lines, self.lines[i].text)
				end
				table.insert(lines, bottomText:sub(1, e))
				txt = table.concat(lines, "\n")
			end
			Spring.SetClipboard(txt)
-- 			Spring.SetClipboard()
		end
		if key == Spring.GetKeyCode("x") and self.selStart ~= nil then
			self:ClearSelected()
		end
	elseif mods.ctrl and key == Spring.GetKeyCode("v") and self.editable then
		self:TextInput(Spring.GetClipboard())

	-- select all
	elseif mods.ctrl and key == Spring.GetKeyCode("a") then
		self.selStart = 1
		if not self.multiline then
			self.selEnd = #txt + 1
		else
			self.selStartY = 1
			self.selEndY = #self.lines
			self.selEnd = #self.lines[self.selEndY].text + 1
		end
	elseif not self.editable then
		return false
	end
	
	-- text selection handling
	if key == Spring.GetKeyCode("left") or key == Spring.GetKeyCode("right") or key == Spring.GetKeyCode("home") or key == Spring.GetKeyCode("end") then
		if mods.shift then
			if not self.selStart then
				self.selStart = cp
			end
			self.selEnd = self.cursor
		elseif self.selStart then
			self.selStart = nil
			self.selEnd = nil
		end
	end
	
	self._interactedTime = Spring.GetTimer()
	inherited.KeyPress(self, key, mods, isRepeat, label, unicode, ...)
	self:UpdateLayout()
	self:Invalidate()
	return self
end


function EditBox:TextInput(utf8char, ...)
	if not self.editable then
		return false
	end
	local unicode = utf8char

	if unicode then
		local cp  = self.cursor
		local txt = self.text
		if self.selStart ~= nil then
			self:ClearSelected()
			txt = self.text
			cp = self.cursor
		end
		self.text = txt:sub(1, cp - 1) .. unicode .. txt:sub(cp, #txt)
		self.cursor = cp + unicode:len()
	end

	self._interactedTime = Spring.GetTimer()
	inherited.TextInput(self, utf8char, ...)
	self:UpdateLayout()
	self:Invalidate()
	return self
end

--//=============================================================================
