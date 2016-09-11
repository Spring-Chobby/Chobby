--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Queue List Window",
		desc      = "Handles matchmaking queue list display.",
		author    = "GoogleFrog",
		date      = "11 September 2016",
		license   = "GNU LGPL, v2.1 or later",
		layer     = -100000,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Initialization

local function InitializeControls(window)
	local Configuration = WG.Chobby.Configuration
	local lobby = WG.LibLobby.lobby
	
	local lblTitle = Label:New {
		x = 20,
		right = 5,
		y = 16,
		height = 20,
		font = Configuration:GetFont(3),
		caption = "Queues",
		parent = window
	}

	local btnClose = Button:New {
		right = 7,
		y = 5,
		width = 80,
		height = 45,
		caption = i18n("close"),
		font = Configuration:GetFont(3),
		classname = "negative_button",
		OnClick = {
			function()
				window:Hide()
			end
		},
		parent = window
	}

	local listPanel = ScrollPanel:New {
		x = 5,
		right = 5,
		y = 55,
		bottom = 250,
		borderColor = {0,0,0,0},
		horizontalScrollbar = false,
		parent = window
	}
		
	local queues = 0
	local tickedQueues = {}
	local function AddQueue(_, queueName, queueDescription)
		if listPanel:GetChildByName(queueName) then
			return
		end
	
		local newQueue = Checkbox:New {
			name = queueName,
			x = 60,
			width = 220,
			y = queues*35 + 10,
			height = 40,
			boxalign = "right",
			boxsize = 20,
			caption = queueName,
			tooltip = queueDescription,
			checked = false,
			font = WG.Chobby.Configuration:GetFont(2),
			OnChange = {function (obj, newState)
				tickedQueues[queueName] = newState or nil
			end},
			parent = listPanel,
		}
		queues = queues + 1
	end
	
	local possibleQueues = lobby:GetQueues()
	for name, data in pairs(possibleQueues) do
		AddQueue(_, data.name, data.description)
	end
	
	lobby:AddListener("OnQueueOpened", AddQueue)
		
	local function SendMatchmakingRequest()
		local tickedQueueList = {}
		for name, _ in pairs(tickedQueues) do
			tickedQueueList[#tickedQueueList + 1] = name
		end
		if #tickedQueueList == 0 then
			return
		end
		WG.LibLobby.lobby:JoinMatchmaking(tickedQueueList)
	end
	
	local btnStartSearch = Button:New {
		x = 7,
		bottom = 200,
		width = 80,
		height = 45,
		caption = i18n("start"),
		font = Configuration:GetFont(3),
		classname = "negative_button",
		OnClick = {
			function()
				SendMatchmakingRequest()
			end
		},
		parent = window
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Interface

local QueueListWindow = {}

function QueueListWindow.GetControl()

	local window = Control:New {
		x = "0%",
		y = "0%",
		width = "100%",
		height = "100%",
		padding = {0, 0, 0, 0},
		OnParent = {
			function(obj)
				if obj:IsEmpty() then
					InitializeControls(obj)
				end
			end
		},
	}
	return window
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

function widget:Initialize()
	CHOBBY_DIR = LUA_DIRNAME .. "widgets/chobby/"
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)

	WG.QueueListWindow = QueueListWindow
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------