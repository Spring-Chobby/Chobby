
ButtonUtilities = ButtonUtilities or {}

local function GetFont(size)
	return {
		size = size + 2,
		outlineWidth = 6,
		outlineHeight = 6,
		outline = true,
		outlineColor = {0,0,0,0.8},
		autoOutlineColor = false,
		font = fontName
	}
end

function ButtonUtilities.SetButtonSelected(button)
	if button.selected then
		return
	end
	
	local Configuration = WG.Chobby.Configuration
	if not button.highlighted then
		button.oldCaption = button.oldCaption or button.caption
		button.oldBackgroundColor = button.oldBackgroundColor or button.backgroundColor
		button.oldFont = button.oldFont or button.font
	end
	
	button.selected = true
	button.highlighted = false
	
	button:SetCaption(Configuration:GetSelectedColor() .. button.oldCaption .. "\b")
	button.font = Chili.Font:New(GetFont(button.oldFont.size - 2))
	
	button.backgroundColor = Configuration:GetButtonSelectedColor()
	button:Invalidate()
end

function ButtonUtilities.SetButtonHighlighted(button)
	if button.highlighted then
		return
	end

	local Configuration = WG.Chobby.Configuration
	if not button.selected then
		button.oldCaption = button.oldCaption or button.caption
		button.oldBackgroundColor = button.oldBackgroundColor or button.backgroundColor
		button.oldFont = button.oldFont or button.font
	end
	
	button.selected = false
	button.highlighted = true
	
	button:SetCaption(Configuration:GetHighlightedColor() .. button.oldCaption .. "\b")
	button.font = Chili.Font:New(GetFont(button.oldFont.size - 2))
	
	--button.backgroundColor = Configuration:GetButtonSelectedColor()
	button:Invalidate()
end

function ButtonUtilities.SetButtonDeselected(button)
	if not button.selected then
		return
	end

	button.oldCaption = button.oldCaption or button.caption
	button.oldBackgroundColor = button.oldBackgroundColor or button.backgroundColor
	button.oldFont = button.oldFont or button.font
	
	button.selected = false
	button.selected = false
	
	button:SetCaption(button.oldCaption)
	button.font = button.oldFont
	button.backgroundColor = button.oldBackgroundColor
	button:Invalidate()
end

function ButtonUtilities.SetCaption(button, newCaption)
	button:SetCaption(newCaption)
	button.oldCaption = newCaption
	if button.selected then
		button.selected = false -- force redo
		ButtonUtilities.SetButtonSelected(button)
	end
	if button.highlighted then
		button.highlighted = false -- force redo
		ButtonUtilities.SetButtonHighlighted(button)
	end
end

function ButtonUtilities.SetFontSizeScale(button, sizeScale)
	button.font = Chili.Font:New(WG.Chobby.Configuration:GetFont(sizeScale))
	button:Invalidate()
	button.oldFont = button.font
	if button.selected then
		button.selected = false -- force redo
		ButtonUtilities.SetButtonSelected(button)
	end
	if button.highlighted then
		button.highlighted = false -- force redo
		ButtonUtilities.SetButtonHighlighted(button)
	end
end