--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Integer Selector Window",
		desc      = "Displays an integer selector window popup.",
		author    = "Beherith",
		date      = "2020.11",
		license   = "GNU LGPL, v2.1 or later",
		layer     = 0,
		enabled   = true  --  loaded by default?
	}
end


local function CreateIntegerSelectorWindow(opts)
	opts = opts or {}

	local integerTrackBarValue = opts.defaultValue or 0
	local Configuration = WG.Chobby.Configuration

	local IntegerSelectorWindow = Window:New {
		caption = opts.caption or "",
		name = "IntegerSelectorWindow",
		parent = screen0,
		width = 280,
		height = 330,
		resizable = false,
		draggable = false,
		classname = "main_window",
	}

	local function ChangeAccepted()
		if opts.OnAccepted then
			opts.OnAccepted(integerTrackBarValue)
		end
	end

	local function CloseFunction()
		IntegerSelectorWindow:Dispose()
		IntegerSelectorWindow = nil
	end

	local lblTitle = TextBox:New {
		x = "5%",
		y = "10%",
		width = IntegerSelectorWindow.width - IntegerSelectorWindow.padding[1] - IntegerSelectorWindow.padding[3],
		height = 35,
		align = "center",
		font = Configuration:GetFont(2),
		text = opts.labelCaption or "",
		parent = IntegerSelectorWindow,
	}

	local btnOK = Button:New {
		x = "10%",
		width = "30%",
		bottom = 1,
		height = 40,
		caption = i18n("ok"),
		font = Configuration:GetFont(2),
		classname = "action_button",
		OnClick = { CloseFunction, ChangeAccepted },
		parent = IntegerSelectorWindow,
	}

	local btnCancel = Button:New {
		right = "10%",
		width = "30%",
		bottom = 1,
		height = 40,
		caption = i18n("cancel"),
		font = Configuration:GetFont(2),
		classname = "action_button",
		OnClick = { CloseFunction },
		parent = IntegerSelectorWindow,
	}


	local integerTrackBar = Trackbar:New {
		x = 0,
		width  = IntegerSelectorWindow.width * 0.90,
		height = 40,
		bottom = 45,
		value  = opts.defaultValue or 0,
		min    = opts.minValue or 0,
		max    = opts.maxValue or 100,
		step   = opts.step or 1,
		parent = IntegerSelectorWindow,
		OnChange = {
			function(obj, value)
				integerTrackBarValue = value
			end
		}
	}

	WG.Chobby.PriorityPopup(IntegerSelectorWindow, CloseFunction, CloseFunction, screen0)
end

function widget:Initialize()
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)

	WG.IntegerSelectorWindow = {
		CreateIntegerSelectorWindow = CreateIntegerSelectorWindow
	}
end
