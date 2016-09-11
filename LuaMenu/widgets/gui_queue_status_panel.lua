--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Queue status panel",
		desc      = "Displays queue status.",
		author    = "GoogleFrog",
		date      = "11 September 2016",
		license   = "GNU LGPL, v2.1 or later",
		layer     = 0,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Initialization

local function InitializeQueueStatusHandler(parentControl)
	local lobby = WG.LibLobby.lobby

	local button = Button:New {
		name = "cancel",
		x = "65%",
		right = 4,
		y = 4,
		bottom = 4,
		padding = {0,0,0,0},
		caption = "Cancel",
		font = WG.Chobby.Configuration:GetFont(3),
		classname = "negative_button",
		OnClick = {
			function()
				lobby:LeaveMatchMakingAll()
			end
		},
		parent = parentControl,
	}
	
	local queueStatusText = TextBox:New {
		x = 12,
		y = 12,
		right = "37%",
		bottom = 12,
		fontsize = WG.Chobby.Configuration:GetFont(2).size,
		text = "",
		parent = parentControl
	}
	
	local externalFunctions = {}
	
	function externalFunctions.ResetTimer()
	end
	
	function externalFunctions.UpdateMatches(joinedQueueList, statusText)
		queueStatusText:SetText(statusText)
	end
	
	function externalFunctions.Resize(xSize, ySize)
	end
	
	return externalFunctions
end

local function PopupReadyCheckWindow(_, required, text)
	if not required then
		-- What is this for?
		return
	end

	local lobby = WG.LibLobby.lobby
	local readyWindow
	
	local function AcceptFunc()
		lobby:AcceptMatchMakingMatch()
		readyWindow:Dispose()
	end
	
	local function CancelFunc()
		lobby:RejectMatchMakingMatch()
		readyWindow:Dispose()
	end
	
	local text = TextBox:New {
		text = text,
		font = WG.Chobby.Configuration:GetFont(2),
	}
	
	readyWindow = Window:New {
		caption = "",
		name = "readyWindow",
		parent = WG.Chobby.lobbyInterfaceHolder,
		x = "45%",
		y = "45%",
		width = 320,
		height = 240,
		resizable = false,
		children = {
			StackPanel:New {
				x = 0, y = 0,
				right = 0, bottom = 0,
				children = {
					text,
					Button:New {
						caption = "Accept",
						OnClick = {AcceptFunc},
					},
					Button:New {
						caption = "Reject",
						OnClick = {CancelFunc},
					},
				},
			}
		}
	}
	
	local popupHolder = WG.Chobby.PriorityPopup(readyWindow, CancelFunc, AcceptFunc)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External functions

local QueueStatusPanel = {}

function QueueStatusPanel.GetControl()
	local lobby = WG.LibLobby.lobby
	local queueStatusHandler
	
	local queuePanel = Panel:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		padding = {0,0,0,0},
		caption = "",
		resizable = false,
		draggable = false,
		OnResize = {
			function (obj, xSize, ySize)
				if queueStatusHandler then
					queueStatusHandler.Resize(xSize, ySize)
				end
			end
		}
	}
	
	queueStatusHandler = InitializeQueueStatusHandler(queuePanel)
	
	lobby:AddListener("OnMatchMakerStatus", 
		function(listener, inMatchMaking, joinedQueueList, statusText)
			if inMatchMaking then
				if not queuePanel.visible then
					queueStatusHandler.ResetTimer()
				end
				queueStatusHandler.UpdateMatches(joinedQueueList, statusText)
			end
			queuePanel:SetVisibility(inMatchMaking)
		end
	)
	
	lobby:AddListener("OnMatchMakerReadyCheck", PopupReadyCheckWindow)
	return queuePanel
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

function widget:Initialize()
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)

	WG.QueueStatusPanel = QueueStatusPanel
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
