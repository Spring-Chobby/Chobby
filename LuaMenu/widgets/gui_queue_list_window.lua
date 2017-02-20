--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Queue List Window",
		desc      = "Handles matchMaking queue list display.",
		author    = "GoogleFrog",
		date      = "11 September 2016",
		license   = "GNU LGPL, v2.1 or later",
		layer     = -100000,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Variables

local DEBRIEFING_CHANNEL = "debriefing"

local requiredResources = {}
local requiredResourceCount = 0

local panelInterface

local function HaveRightEngineVersion()
	local configuration = WG.Chobby.Configuration
	if configuration.useWrongEngine then
		return true
	end
	local engineVersion = WG.LibLobby.lobby:GetSuggestedEngineVersion()
	return (not engineVersion) or configuration:IsValidEngineVersion(engineVersion)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Initialization

local function MakeQueueControl(parentControl, queueName, queueDescription, players, waiting, maxPartySize)
	local Configuration = WG.Chobby.Configuration
	local lobby = WG.LibLobby.lobby
	local btnLeave, btnJoin
	
	local currentPartySize = 1
	local inQueue = false
	
	btnJoin = Button:New {
		x = 0,
		y = 0,
		width = 80,
		bottom = 0,
		caption = i18n("join"),
		font = Configuration:GetFont(3),
		classname = "option_button",
		OnClick = {
			function(obj)
				if not HaveRightEngineVersion() then
					WG.Chobby.InformationPopup("Game engine update required, restart the menu to apply.")
					return
				end
				if requiredResourceCount ~= 0 then
					WG.Chobby.InformationPopup("All required maps and games must be downloaded before you can join matchmaking.")
					return
				end
			
				lobby:JoinMatchMaking(queueName)
				obj:SetVisibility(false)
				btnLeave:SetVisibility(true)
				WG.Analytics.SendOnetimeEvent("lobby:multiplayer:matchmaking:join_" .. queueName)
			end
		},
		parent = parentControl
	}
	
	btnLeave = Button:New {
		x = 0,
		y = 0,
		width = 80,
		bottom = 0,
		caption = i18n("leave"),
		font = Configuration:GetFont(3),
		classname = "action_button",
		OnClick = {
			function(obj)
				lobby:LeaveMatchMaking(queueName)
				obj:SetVisibility(false)
				btnJoin:SetVisibility(true)
			end
		},
		parent = parentControl
	}
	btnLeave:SetVisibility(false)
	
	local labelDisabled = TextBox:New {
		x = 0,
		y = 18,
		width = 120,
		height = 22,
		right = 5,
		align = "bottom",
		fontsize = Configuration:GetFont(1).size,
		text = "Party too large",
		parent = parentControl
	}
	labelDisabled:SetVisibility(false)
	
	local lblTitle = TextBox:New {
		x = 105,
		y = 15,
		width = 120,
		height = 33,
		fontsize = Configuration:GetFont(3).size,
		text = queueName,
		parent = parentControl
	}
	
	local lblDescription = TextBox:New {
		x = 180,
		y = 8,
		width = 120,
		height = 22,
		right = 5,
		align = "bottom",
		fontsize = Configuration:GetFont(1).size,
		text = queueDescription,
		parent = parentControl
	}
	
	local lblPlayers = TextBox:New {
		x = 180,
		y = 30,
		width = 120,
		height = 22,
		right = 5,
		align = "bottom",
		fontsize = Configuration:GetFont(1).size,
		text = "Playing: " .. players,
		parent = parentControl
	}
	
	local lblWaiting = TextBox:New {
		x = 280,
		y = 30,
		width = 120,
		height = 22,
		right = 5,
		align = "bottom",
		fontsize = Configuration:GetFont(1).size,
		text = "Waiting: " .. waiting,
		parent = parentControl
	}
	
	local function UpdateButton()
		if maxPartySize and (currentPartySize > maxPartySize) then
			btnJoin:SetVisibility(false)
			btnLeave:SetVisibility(false)
			labelDisabled:SetVisibility(true)
		else
			btnJoin:SetVisibility(not inQueue)
			btnLeave:SetVisibility(inQueue)
			labelDisabled:SetVisibility(false)
		end
	end
	
	local externalFunctions = {}
	
	function externalFunctions.SetInQueue(newInQueue)
		if newInQueue == inQueue then
			return
		end
		inQueue = newInQueue
		UpdateButton()
	end
	
	function externalFunctions.UpdateCurrentPartySize(newCurrentPartySize)
		if newCurrentPartySize == currentPartySize then
			return
		end
		currentPartySize = newCurrentPartySize
		UpdateButton()
	end
	
	function externalFunctions.UpdateQueueInformation(newName, newDescription, newPlayers, newWaiting, newMaxPartySize)
		if newName then
			lblTitle:SetText(newName)
		end
		if newDescription then
			lblDescription:SetText(newDescription)
		end
		if newPlayers then
			lblPlayers:SetText("Playing: " .. newPlayers)
		end
		if newWaiting then
			lblWaiting:SetText("Waiting: " .. newWaiting)
		end
	end
	
	return externalFunctions
end

local function GetDebriefingChat(window, vertPos, channelName, RemoveFunction)
	local Configuration = WG.Chobby.Configuration
	local lobby = WG.LibLobby.lobby
	
	local function MessageListener(message)
		if message:starts("/me ") then
			lobby:SayEx(channelName, message:sub(5))
		else
			lobby:Say(channelName, message)
		end
	end
	local debriefingConsole = WG.Chobby.Console("Debriefing Chat", MessageListener, true)
	local userListPanel = WG.Chobby.UserListPanel(function() return lobby:GetChannel(channelName) end, 22, nil, WG.UserHandler.GetDebriefingUser)
	
	local chatPanel = Control:New {
		x = 0,
		y = vertPos,
		bottom = 0,
		right = "33%",
		padding = {12, 2, 2, 9},
		itemPadding = {0, 0, 0, 0},
		itemMargin = {0, 0, 0, 0},
		children = {
			debriefingConsole.panel
		},
		parent = window,
	}
	local spectatorPanel = Control:New {
		x = "67%",
		y = vertPos,
		right = 0,
		bottom = 0,
		-- Add 7 to line up with chat
		padding = {2, 2, 12, 16},
		parent = window,
		children = {
			userListPanel.panel
		},
	}
	
	local externalFunctions = {}
	
	local closeChannelButton = Button:New {
		width = 24, height = 24, y = 5, right = 12,
		caption = "x",
		OnClick = {
			function()
				lobby:Leave(channelName)
				RemoveFunction()
				externalFunctions.Delete()
			end
		},
		parent = chatPanel,
	}
	closeChannelButton:BringToFront()
	
	window:Invalidate()
	
	function externalFunctions.UpdateUsers()
		userListPanel:Update()
	end
	
	function externalFunctions.AddMessage(message, userName, msgDate, chatColour, thirdPerson)
		debriefingConsole:AddMessage(message, userName, msgDate, chatColour, thirdPerson)
	end
	
	function externalFunctions.SetTopic(message)
		debriefingConsole:SetTopic(message)
	end
	
	function externalFunctions.Delete()
		debriefingConsole:Delete()
		userListPanel:Delete()
		chatPanel:Dispose()
		spectatorPanel:Dispose()
	end
	
	return externalFunctions
end

local function SetupDebriefingTracker(window)
	local Configuration = WG.Chobby.Configuration
	local lobby = WG.LibLobby.lobby
	
	local debriefingChat
	local debriefingChannelName
	local ignoredChannels = {}
	local channelTopics = {}
	
	local function RemoveFunction()
		debriefingChannelName = nil
		debriefingChat = nil
	end
	
	local function OnJoin(listener, chanName)
		if (not string.find(chanName, DEBRIEFING_CHANNEL)) or ignoredChannels[chanName] or chanName == debriefingChannelName then
			return
		end
		if debriefingChannelName then
			lobby:Leave(debriefingChannelName)
			ignoredChannels[debriefingChannelName] = true
		end
		if debriefingChat then
			debriefingChat.Delete()
		end
		debriefingChannelName = chanName
		debriefingChat = GetDebriefingChat(window, 430, debriefingChannelName, RemoveFunction)
		WG.Chobby.interfaceRoot.OpenMultiplayerTabByName("matchmaking")
		
		if channelTopics[debriefingChannelName] then
			debriefingChat.SetTopic("Post game chat")
			debriefingChat.SetTopic(channelTopics[debriefingChannelName])
			channelTopics = {}
		end
	end
	lobby:AddListener("OnJoin", OnJoin)
	
	local function UpdateUsers(listener, chanName, userName)
		if not (chanName == debriefingChannelName and debriefingChat) then
			return
		end
		debriefingChat.UpdateUsers()
	end
	lobby:AddListener("OnJoined", UpdateUsers)
	lobby:AddListener("OnLeft", UpdateUsers)
	lobby:AddListener("OnClients", UpdateUsers)

	local CHAT_MENTION ="\255\255\0\0"

	-- channel chat
	local function OnSaid(listener, chanName, userName, message, msgDate)
		if not (chanName == debriefingChannelName and debriefingChat) then
			return
		end
		local iAmMentioned = (string.find(message, lobby:GetMyUserName()) and userName ~= lobby:GetMyUserName())
		debriefingChat.AddMessage(message, userName, msgDate, iAmMentioned and CHAT_MENTION)
	end
	lobby:AddListener("OnSaid", OnSaid)
	
	local function OnSaidEx(listener, chanName, userName, message, msgDate)
		if not (chanName == debriefingChannelName and debriefingChat) then
			return
		end
		local iAmMentioned = (string.find(message, lobby:GetMyUserName()) and userName ~= lobby:GetMyUserName())
		debriefingChat.AddMessage(message, userName, msgDate, (iAmMentioned and CHAT_MENTION) or Configuration.meColor, true)
	end
	lobby:AddListener("OnSaidEx", OnSaidEx)
	
	local function OnBattleDebriefing(listener, url, chanName, serverBattleID, userList)
		local debriefTopic = "Battle link: " .. (url or "not found")
		if debriefingChannelName == chanName and debriefingChat then
			debriefingChat.SetTopic("Post game chat") -- URL doesn't work on line one.
			debriefingChat.SetTopic(debriefTopic)
		elseif chanName and string.find(chanName, DEBRIEFING_CHANNEL) then
			channelTopics[debriefingChannelName] = debriefTopic
		end
	end
	lobby:AddListener("OnBattleDebriefing", OnBattleDebriefing)
end

local function InitializeControls(window)
	local Configuration = WG.Chobby.Configuration
	local lobby = WG.LibLobby.lobby
	
	local banStart
	local banDuration
	
	local lblTitle = Label:New {
		x = 20,
		right = 5,
		y = 17,
		height = 20,
		font = Configuration:GetFont(3),
		caption = "Join matchmaking queues",
		parent = window
	}

	local btnClose = Button:New {
		right = 11,
		y = 7,
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
		height = 250,
		borderColor = {0,0,0,0},
		horizontalScrollbar = false,
		parent = window
	}
	
	local statusText = TextBox:New {
		x = 12,
		right = 5,
		y = 320,
		height = 200,
		fontsize = Configuration:GetFont(2).size,
		text = "",
		parent = window
	}
	
	local requirementText = TextBox:New {
		x = 12,
		right = 5,
		y = 400,
		height = 200,
		fontsize = Configuration:GetFont(2).size,
		text = "",
		parent = window
	}
	
	local queues = 0
	local queueHolders = {}
	local function AddQueue(_, queueName, queueDescription, mapNames, maxPartySize)
		local queueData = lobby:GetQueue(queueName) or {}
		if queueHolders[queueName] then
			queueHolders[queueName].UpdateQueueInformation(queueName, queueDescription, queueData.playersIngame or "?", queueData.playersWaiting or "?", maxPartySize)
			return
		end
	
		local queueHolder = Control:New {
			x = 10,
			y = queues*55 + 15,
			right = 0,
			height = 45,
			caption = "", -- Status Window
			parent = listPanel,
			resizable = false,
			draggable = false,
			padding = {0, 0, 0, 0},
		}
		queueHolders[queueName] = MakeQueueControl(queueHolder, queueName, queueDescription, queueData.playersIngame or "?", queueData.playersWaiting or "?", maxPartySize)
		queues = queues + 1
	end
	
	local possibleQueues = lobby:GetQueues()
	for name, data in pairs(possibleQueues) do
		AddQueue(_, data.name, data.description, data.mapNames, data.maxPartySize)
	end
	
	local function UpdateQueueStatus(listener, inMatchMaking, joinedQueueList, queueCounts, ingameCounts, _, _, _, bannedTime)
		local joinedQueueNames = {}
		if joinedQueueList then
			for i = 1, #joinedQueueList do
				local queueName = joinedQueueList[i]
				if queueHolders[queueName] then
					joinedQueueNames[queueName] = true
					queueHolders[queueName].SetInQueue(true)
				end
			end
		end
		
		if queueCounts then
			for queueName, waitingCount in pairs(queueCounts) do
				queueHolders[queueName].UpdateQueueInformation(nil, nil, ingameCounts and ingameCounts[queueName], waitingCount)
			end
		end
		
		for queueName, queueHolder in pairs(queueHolders) do
			if not joinedQueueNames[queueName] then
				queueHolder.SetInQueue(false)
			end
		end
		
		if bannedTime then
			statusText:SetText("You are banned from matchmaking for " .. bannedTime .. " seconds")
			banStart = Spring.GetTimer()
			banDuration = bannedTime
		end
	end
	
	local function OnPartyUpdate(listener, partyID, partyUsers)
		if lobby:GetMyPartyID() ~= partyID then
			return
		end
		for name, queueHolder in pairs(queueHolders) do
			queueHolder.UpdateCurrentPartySize(#partyUsers)
		end
	end
		
	local function OnPartyLeft(listener, partyID, partyUsers)
		for name, queueHolder in pairs(queueHolders) do
			queueHolder.UpdateCurrentPartySize(1)
		end
	end
	
	lobby:AddListener("OnQueueOpened", AddQueue)
	lobby:AddListener("OnMatchMakerStatus", UpdateQueueStatus)
	
	lobby:AddListener("OnPartyCreate", OnPartyUpdate)
	lobby:AddListener("OnPartyUpdate", OnPartyUpdate)
	lobby:AddListener("OnPartyDestroy", OnPartyUpdate)
	lobby:AddListener("OnPartyLeft", OnPartyLeft)
	
	-- Initialization
	if lobby.matchMakerBannedTime then
		statusText:SetText("You are banned from matchmaking for " .. lobby.matchMakerBannedTime .. " seconds")
		banStart = Spring.GetTimer()
		banDuration = lobby.matchMakerBannedTime
	end
	
	if lobby:GetMyPartyID() then
		OnPartyUpdate(_, lobby:GetMyPartyID(), lobby:GetMyParty())
	end
	
	SetupDebriefingTracker(window)
	
	-- External functions
	local externalFunctions = {}
		
	function externalFunctions.UpdateBanTimer()
		if not banStart then
			return
		end
		local timeRemaining = banDuration - math.ceil(Spring.DiffTimers(Spring.GetTimer(), banStart))
		if timeRemaining < 0 then
			banStart = false
			statusText:SetText("")
			return
		end
		statusText:SetText("You are banned from matchmaking for " .. timeRemaining .. " seconds")
	end
	
	function externalFunctions.UpdateRequirementText()
		local newText = ""
		local firstEntry = true
		for name,_ in pairs(requiredResources) do
			if firstEntry then
				newText = "Required resources: "
			else
				newText = newText .. ", "
			end
			firstEntry = false
			newText = newText .. name
		end
		
		if not HaveRightEngineVersion() then
			if firstEntry then
				newText = "Game engine update required, restart the menu to apply."
			else
				newText = "\nGame engine update required, restart the menu to apply."
			end
		end
		requirementText:SetText(newText)
	end
	
	externalFunctions.UpdateRequirementText()
	
	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Interface

local QueueListWindow = {}

function QueueListWindow.HaveMatchMakerResources()
	return requiredResourceCount == 0 and HaveRightEngineVersion()
end

local queueListWindowControl

function QueueListWindow.GetControl()

	queueListWindowControl = Control:New {
		x = "0%",
		y = "0%",
		width = "100%",
		height = "100%",
		padding = {0, 0, 0, 0},
		OnParent = {
			function(obj)
				if obj:IsEmpty() then
					panelInterface = InitializeControls(obj)
				end
			end
		},
	}
	
	return queueListWindowControl
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

function widget:ActivateGame()
	-- You can enter debriefing before you look at the queue list window.
	-- Need to create it if a game starts.
	if not (queueListWindowControl and queueListWindowControl:IsEmpty()) then
		return
	end
	
	panelInterface = InitializeControls(queueListWindowControl)
end

function widget:Update()
	if panelInterface then
		panelInterface.UpdateBanTimer()
	end
end

function widget:DownloadFinished()
	for resourceName,_ in pairs(requiredResources) do
		local haveResource = VFS.HasArchive(resourceName)
		if haveResource then
			requiredResources[resourceName] = nil
			requiredResourceCount = requiredResourceCount - 1
		end
	end
	
	if panelInterface then
		panelInterface.UpdateRequirementText()
	end
end

function widget:Initialize()
	CHOBBY_DIR = LUA_DIRNAME .. "widgets/chobby/"
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)

	local function AddQueue(_, queueName, queueDescription, mapNames, maxPartSize, gameNames)
		for i = 1, #mapNames do
			local mapName = mapNames[i]
			if not requiredResources[mapName] then
				local haveMap = VFS.HasArchive(mapName)
				if not haveMap then
					requiredResources[mapName] = true
					requiredResourceCount = requiredResourceCount + 1
					
					VFS.DownloadArchive(mapName, "map")
				end
			end
		end
		
		for i = 1, #gameNames do
			local gameName = gameNames[i]
			if not requiredResources[gameName] then
				local haveGame = VFS.HasArchive(gameName)
				if not haveGame then
					requiredResources[gameName] = true
					requiredResourceCount = requiredResourceCount + 1
					
					VFS.DownloadArchive(gameName, "game")
				end
			end
		end
		
		if panelInterface then
			panelInterface.UpdateRequirementText()
		end
	end
	
	WG.LibLobby.lobby:AddListener("OnQueueOpened", AddQueue)
	
	WG.QueueListWindow = QueueListWindow
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------