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

local function CreateReportWindow(parentHolder, userName, extraText, usePopupBackground)
	if parentHolder:GetChildByName("reportWindow") then
		return
	end
	
	local Configuration = WG.Chobby.Configuration

	local reportWindow = Window:New {
		caption = "",
		name = "reportWindow",
		parent = parentHolder,
		width = 540,
		height = 270,
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
		caption = "Reporting " .. userName,
		parent = reportWindow,
	}
	offset = offset + 44

	TextBox:New {
		x = 26,
		right = 24,
		y = offset,
		height = 35,
		text = "Reason:",
		fontsize = Configuration:GetFont(3).size,
		parent = reportWindow,
	}
	offset = offset + 38
	local titleBox = EditBox:New {
		x = 24,
		right = 24,
		y = offset - 9,
		height = 35,
		text = "",
		hint = "Enter report reason",
		font = Configuration:GetFont(3),
		parent = reportWindow,
	}
	offset = offset + 38
	Label:New {
		x = 26,
		right = 24,
		y = offset,
		height = 35,
		caption = extraText or "",
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
		caption = i18n("submit"),
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

	if usePopupBackground then
		WG.Chobby.PriorityPopup(reportWindow, CancelFunc, AcceptFunc, parentHolder)
	else
		local screenWidth, screenHeight = Spring.GetViewGeometry()
		reportWindow:SetPos(
			math.floor((screenWidth - reportWindow.width)/2),
			math.floor((screenHeight - reportWindow.height)/2)
		)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Interface

local ReportPanel = {}

function ReportPanel.OpenReportWindow(userName, extraText, isIngame)
	if isIngame then
		CreateReportWindow(WG.Chobby.interfaceRoot.GetIngameInterfaceHolder(), userName, extraText, false)
	else
		CreateReportWindow(WG.Chobby.lobbyInterfaceHolder, userName, extraText, true)
	end
end

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Initialization

function widget:Initialize()
	CHOBBY_DIR = LUA_DIRNAME .. "widgets/chobby/"
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)

	WG.ReportPanel = ReportPanel
end
