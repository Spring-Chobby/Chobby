InformationPopup = LCS.class{}

function InformationPopup:init(infoText, width, height)
	
	local mainWindow = Window:New {
		x = 700,
		y = 300,
		width = width or 320,
		height = height or 220,
		caption = "",
		resizable = false,
		draggable = false,
		parent = WG.Chobby.lobbyInterfaceHolder,
		classname = "overlay_window",
	}
	
	local function DoneFunc()
		mainWindow:Dispose()
	end
	
	local lblText = TextBox:New {
		x = 15,
		right = 15,
		y = 15,
		height = 35,
		font = Configuration:GetFont(3),
		text = infoText,
		parent = mainWindow,
	}
	
	local btnAccept = Button:New {
		x = "25%",
		right = "25%",
		bottom = 1,
		height = 70,
		caption = i18n("ok"),
		font = Configuration:GetFont(3),
		classname = "action_button",
		OnClick = {
			function()
				DoneFunc()
			end
		},
		parent = mainWindow,
	}
	
	local popupHolder = PriorityPopup(mainWindow, DoneFunc, DoneFunc)
end
