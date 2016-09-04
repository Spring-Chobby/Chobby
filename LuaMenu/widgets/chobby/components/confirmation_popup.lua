ConfirmationPopup = LCS.class{}

function ConfirmationPopup:init(successFunction, question, doNotAskAgainKey, width, height)
	
	local mainWindow = Window:New {
		x = 700,
		y = 300,
		width = width or 400,
		height = height or 280,
		caption = "",
		resizable = false,
		draggable = false,
		parent = WG.Chobby.lobbyInterfaceHolder,
		classname = "overlay_window",
	}
	
	local function CancelFunc()
		mainWindow:Dispose()
	end
	
	local function AcceptFunc()
		if successFunction then
			successFunction()
		end
		mainWindow:Dispose()
	end
	
	local lblText = TextBox:New {
		x = 15,
		right = 15,
		y = 15,
		height = 35,
		font = Configuration:GetFont(3),
		text = question,
		parent = mainWindow,
	}
	
	local btnAccept = Button:New {
		x = 1,
		width = 135,
		bottom = 1,
		height = 70,
		caption = i18n("yes"),
		font = Configuration:GetFont(3),
		classname = "action_button",
		OnClick = {
			function()
				AcceptFunc()
			end
		},
		parent = mainWindow,
	}
	local btnClose = Button:New {
		right = 1,
		width = 135,
		bottom = 1,
		height = 70,
		caption = i18n("cancel"),
		font = Configuration:GetFont(3),
		classname = "negative_button",
		OnClick = {
			function()
				CancelFunc()
			end
		},
		parent = mainWindow,
	}

	if doNotAskAgainKey then
		local doNotAskAgain = Checkbox:New {
			x = 15,
			width = 130,
			bottom = 75,
			height = 35,
			boxalign = "right",
			boxsize = 15,
			caption = i18n("do_not_ask_again"),
			checked = Configuration[doNotAskAgainKey] or false,
			font = Configuration:GetFont(1),
			parent = mainWindow,
			OnClick = {
				function (obj)
					Configuration:SetConfigValue(doNotAskAgainKey, obj.checked)
				end
			},
		}
	end
	
	local popupHolder = PriorityPopup(mainWindow, CancelFunc, AcceptFunc)
end
