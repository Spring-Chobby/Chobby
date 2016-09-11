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

local function InitializeControls(parentControl)
	local tabPanel = WG.Chobby.interfaceRoot.GetBattleStatusWindowHandler()
	local lobby = WG.LibLobby.lobby

	local queueButtonHolder = Control:New {
		name = "findingMatch",
		x = 4,
		right = "51%",
		y = 4,
		bottom = 4,
		caption = "", -- Battle and MM Status Window
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		parent = parentControl,
	}
	
	
	local queueProgressWrapper = Control:New {
		x = 0,
		y = 0,
		width = "100%",
		height = "100%",
		resizable = false,
		padding = {0, 0, 0, 0},

		--OnParent = {
		--	function(obj)
		--		if obj:IsEmpty() then
		--			wrapperControl = obj
        --
		--			local battleWindow = InitializeControls(battleID, battleLobby, 55)
		--			if battleWindow then
		--				obj:AddChild(battleWindow)
		--			end
		--		end
		--	end
		--},
		OnHide = {
			function(obj)
				--tabPanel.RemoveTab("myBattle", true)
			end
		}
	}
	
	local queueButton = WG.Chobby.GetTabPanelHandler("queueButton", queueButtonHolder, WG.Chobby.interfaceRoot.GetContentPlace(), {{name = "finding_match", control = queueProgressWrapper}})
	
	local button = Button:New {
		name = "cancel",
		x = "51%",
		right = 4,
		y = 4,
		bottom = 4,
		padding = {0,0,0,0},
		caption = "Cancel",
		font = WG.Chobby.Configuration:GetFont(3),
		classname = "negative_button",
		OnClick = {
			function()
				lobby:LeaveMatchmaking()
			end
		},
		parent = parentControl,
	}
	
	local function onMatchMakerStatus(listener, inMatchmaking, joinedQueues, statusText)
		parentControl.tooltip = "queue_tooltip"
	end
	lobby:AddListener("OnMatchMakerStatus", onMatchMakerStatus)
end

local function PopupReadyCheckWindow(_, required, text)
	local lobby = WG.LibLobby.lobby
	
	local function AcceptFunc()
		lobby:AcceptMatchmakingMatch()
		readyWindow:Dispose()
	end
	
	local function CancelFunc()
		lobby:RejectMatchmakingMatch()
		readyWindow:Dispose()
	end
	
	local text = TextBox:New {
		text = text,
		font = WG.Chobby.Configuration:GetFont(2),
	}
	
	local readyWindow = Window:New {
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
	
	local popupHolder = PriorityPopup(readyWindow, CancelFunc, AcceptFunc)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External functions

local QueueStatusPanel = {}

function QueueStatusPanel.GetTabControl()
	local button = Panel:New {
		x = 0,
		y = 0,
		width = 340,
		bottom = 0,
		padding = {0,0,0,0},
		caption = "",
		resizable = false,
		draggable = false,
		OnParent = {
			function(obj)
				if obj:IsEmpty() then
					InitializeControls(obj)
				end
			end
		},
	}
	return button
end

function QueueStatusPanel.ShowQueueWindow()
	local tabPanel = WG.Chobby.interfaceRoot.GetBattleStatusWindowHandler()
	local lobby = WG.LibLobby.lobby
	
	if not tabPanel.GetTabByName("myQueue") then
		tabPanel.AddTab("myQueue", "Queue", nil, false, 3)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

local function DelayedInitialize()
	local lobby = WG.LibLobby.lobby
	
	lobby:AddListener("OnMatchMakerStatus", 
		function(listener, inMatchmaking)
			if inMatchmaking then
				WG.QueueStatusPanel.ShowQueueWindow()
			else
				local tabPanel = WG.Chobby.interfaceRoot.GetBattleStatusWindowHandler()
				tabPanel.RemoveTab("myQueue")
			end
		end
	)
	
	lobby:AddListener("OnMatchMakerReadyCheck", PopupReadyCheckWindow)
end

function widget:Initialize()
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)

	WG.QueueStatusPanel = QueueStatusPanel
	WG.Delay(DelayedInitialize, 1)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
