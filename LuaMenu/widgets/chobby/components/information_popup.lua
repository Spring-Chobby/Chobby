InformationPopup = LCS.class{}

function InformationPopup:init(infoText, width, height, heading, caption, buttonClass, closeFunc)
	
	width = width or 320
	height = height or 220
	self.closeFunc = closeFunc
	
	self.mainWindow = Window:New {
		x = 700,
		y = 300,
		width = width,
		height = height,
		caption = "",
		resizable = false,
		draggable = false,
		parent = WG.Chobby.lobbyInterfaceHolder,
		classname = "main_window_small",
	}
	
	local function DoneFunc()
		self:Close()
	end
	
	if heading then
		Label:New {
			x = 0,
			y = 15,
			width = width - self.mainWindow.padding[1] - self.mainWindow.padding[3],
			height = 35,
			align = "center",
			font = Configuration:GetFont(4),
			caption = heading,
			parent = self.mainWindow,
		}
	end
	
	local lblText = TextBox:New {
		x = 15,
		right = 15,
		y = (heading and 65) or 15,
		bottom = 75,
		font = Configuration:GetFont(3),
		text = infoText,
		parent = self.mainWindow,
	}
	
	local btnAccept = Button:New {
		x = "25%",
		right = "25%",
		bottom = 1,
		height = 70,
		caption = caption or i18n("ok"),
		font = Configuration:GetFont(3),
		classname = buttonClass or "action_button",
		OnClick = {
			function()
				DoneFunc()
			end
		},
		parent = self.mainWindow,
	}
	
	local popupHolder = PriorityPopup(self.mainWindow, DoneFunc, DoneFunc)
end

function InformationPopup:Close()
	if self.closeFunc then
		self.closeFunc()
	end
	self.mainWindow:Dispose()
end
