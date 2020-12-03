function widget:GetInfo()
	return {
		name    = 'Report Panel',
		desc    = 'Implements the report panel.',
		author  = 'GoogleFrog',
		date    = '3 December 2020',
		license = 'GNU GPL v2',
		layer   = 0,
		enabled = true,
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Window Handler

local function CreateReportWindow(userName, extraText)
	local Configuration = WG.Chobby.Configuration

	local reportWindow = Window:New {
		caption = "",
		name = "reportWindow",
		parent = WG.Chobby.lobbyInterfaceHolder,
		width = 520,
		height = 282,
		resizable = false,
		draggable = false,
		classname = "main_window",
	}

	local offset = 12
	local title = Label:New {
		x = 0,
		y = offset,
		width = 520,
		height = 30,
		align = "center",
		font = Configuration:GetFont(3),
		caption = "Report " .. userName,
		parent = reportWindow,
	}
	offset = offset + 42

	TextBox:New {
		x = 26,
		right = 24,
		y = offset,
		height = 35,
		text ="Reason:",
		fontsize = Configuration:GetFont(3).size,
		parent = reportWindow,
	}
	offset = offset + 36
	local titleBox = EditBox:New {
		x = 24,
		right = 24,
		y = offset - 9,
		height = 35,
		text = "",
		font = Configuration:GetFont(3),
		parent = reportWindow,
	}
	offset = offset + 40
	Label:New {
		x = 26,
		right = 24,
		y = offset,
		height = 35,
		caption = (extraText and ("Metadata: " .. extraText)) or "",
		fontsize = Configuration:GetFont(3).size,
		parent = reportWindow,
	}

	local function CancelFunc()
		reportWindow:Dispose()
	end

	local function AcceptFunc()
		screen0:FocusControl(buttonAccept) -- Defocus the text entry
		if WG.LibLobby and WG.LibLobby.lobby then
			WG.LibLobby.lobby:ReportUser(userName, titleBox.text .. ((extraText and (" " .. extraText)) or ""))
		end
		reportWindow:Dispose()
	end

	buttonAccept = Button:New {
		right = 150,
		width = 135,
		bottom = 1,
		height = 70,
		caption = i18n("send"),
		font = WG.Chobby.Configuration:GetFont(3),
		parent = reportWindow,
		classname = "action_button",
		OnClick = {
			function()
				AcceptFunc()
			end
		},
	}

	local buttonCancel = Button:New {
		right = 6,
		width = 135,
		bottom = 1,
		height = 70,
		caption = i18n("cancel"),
		font = WG.Chobby.Configuration:GetFont(3),
		parent = reportWindow,
		classname = "negative_button",
		OnClick = {
			function()
				CancelFunc()
			end
		},
	}

	local popupHolder = WG.Chobby.PriorityPopup(reportWindow, CancelFunc, AcceptFunc)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Interface

local ReportPanel = {}

function ReportPanel.OpenReportWindow(userName, extraText)
	CreateReportWindow(userName, extraText)
end

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Initialization

function widget:Initialize()
	CHOBBY_DIR = LUA_DIRNAME .. "widgets/chobby/"
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)

	WG.ReportPanel = ReportPanel
end
