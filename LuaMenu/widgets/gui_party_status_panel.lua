--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Party status panel",
		desc      = "Displays party status.",
		author    = "GoogleFrog",
		date      = "18 January 2017",
		license   = "GNU LGPL, v2.1 or later",
		layer     = 0,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Variables

local partyPanel
local invitePopup

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Utilities

local function SecondsToMinutes(seconds)
	if seconds < 60 then
		return seconds .. "s"
	end
	local modSeconds = (seconds%60)
	return math.floor(seconds/60) .. ":" .. ((modSeconds < 10 and "0") or "") .. modSeconds
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Initialization

local function InitializePartyStatusHandler(name, ControlType, parent, pos)
	local lobby = WG.LibLobby.lobby

	ControlType = ControlType or Panel
	
	local queuePanel = ControlType:New {
		name = name,
		x = (pos and pos.x) or ((not pos) and 0),
		y = (pos and pos.y) or ((not pos) and 0),
		right = (pos and pos.right) or ((not pos) and 0),
		bottom = (pos and pos.bottom) or ((not pos) and 0),
		width = pos and pos.width,
		height = pos and pos.height,
		padding = {0,0,0,0},
		caption = "",
		resizable = false,
		draggable = false,
		parent = parent
	}
	
	local button = Button:New {
		name = "cancel",
		x = 4,
		right = "70%",
		y = 4,
		bottom = 4,
		padding = {0,0,0,0},
		caption = "Leave",
		font = WG.Chobby.Configuration:GetFont(3),
		classname = "negative_button",
		OnClick = {
			function()
				lobby:LeaveParty()
			end
		},
		parent = queuePanel,
	}
	
	local rightBound = "33%"
	local bottomBound = 12
	local queueText = nil
	local bigMode = true
	local queueTimer = Spring.GetTimer()
	
	local timeWaiting = 0
	local queueString = ""
	local playersString = ""
	
	local queueStatusText = TextBox:New {
		x = 8,
		y = 12,
		right = rightBound,
		bottom = bottomBound,
		fontsize = WG.Chobby.Configuration:GetFont(2).size,
		text = "",
		parent = queuePanel
	}
	
	local function UpdateTimer(forceUpdate)
		if not queueTimer then
			return
		end
		local newTimeWaiting = math.floor(Spring.DiffTimers(Spring.GetTimer(),queueTimer))
		if (not forceUpdate) and timeWaiting == newTimeWaiting then
			return
		end
		timeWaiting = newTimeWaiting
		queueStatusText:SetText(queueText .. ((bigMode and  "\nTime Waiting: ") or ", Wait: ") .. SecondsToMinutes(timeWaiting))
	end
		
	local function UpdateQueueText()
		queueText = ((bigMode and "Searching: ") or "Search: ") .. queueString .. ((bigMode and  "\nPlayers: ") or "\nPlay: ") .. playersString
		UpdateTimer(true)
	end
	
	local function Resize(obj, xSize, ySize)
		queueStatusText._relativeBounds.right = rightBound
		queueStatusText._relativeBounds.bottom = bottomBound
		queueStatusText:UpdateClientArea()
		if ySize < 60 then
			queueStatusText:SetPos(6, 2)
			bigMode = false
		else
			queueStatusText:SetPos(8, 13)
			bigMode = true
		end
		UpdateQueueText()
	end
	
	queuePanel.OnResize = {Resize}
	
	local externalFunctions = {}
	
	function externalFunctions.ResetTimer()
		queueTimer = Spring.GetTimer()
	end
	
	function externalFunctions.UpdateTimer(forceUpdate)
		UpdateTimer(forceUpdate)
	end
	
	function externalFunctions.UpdateMatches(joinedQueueList, queueCounts, currentEloWidth, joinedTime)
		local firstQueue = true
		playersString = ""
		queueString = ""
		for i = 1, #joinedQueueList do
			if not firstQueue then
				queueString = queueString .. ", "
				playersString = playersString .. ", "
			end
			playersString = playersString .. ((queueCounts and queueCounts[joinedQueueList[i]]) or 0)
			firstQueue = false
			queueString = queueString .. joinedQueueList[i] 
		end
		
		UpdateQueueText()
	end
	
	function externalFunctions.GetHolder()
		return queuePanel
	end
	
	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Ready Check Popup

local function CreatePartyInviteWindow(partyID, partyUsers, secondsRemaining, DestroyFunc)
	local Configuration = WG.Chobby.Configuration
	
	-- testing
	--for i = 2, 11 do
	--	partyUsers[i] = partyUsers[1]
	--end
	
	local MAX_USERS = 10
	local USER_SPACE = 22
	local BASE_HEIGHT = 175
	local userHeight = math.max(60, USER_SPACE*math.min(#partyUsers, MAX_USERS))
	
	local partyInviteWindow = Window:New {
		caption = "",
		name = "partyInviteWindow",
		parent = screen0,
		width = 310,
		height = BASE_HEIGHT + userHeight,
		resizable = false,
		draggable = false,
		classname = "overlay_window",
	}
	
	local titleText = i18n("party_invite")
	local title = Label:New {
		x = 20,
		right = 0,
		y = 15,
		height = 35,
		caption = titleText,
		font = Configuration:GetFont(4),
		parent = partyInviteWindow,
	}

	local listPanel = ScrollPanel:New {
		x = 10,
		right = 10,
		y = 60,
		bottom = 80,
		borderColor = (#partyUsers <= MAX_USERS and {0,0,0,0}) or nil,
		horizontalScrollbar = false,
		parent = partyInviteWindow
	}
	
	for i = 1, #partyUsers do
		local userControl = WG.UserHandler.GetNotificationUser(partyUsers[i])
		listPanel:AddChild(userControl)
		userControl:SetPos(1, 1 + (i - 1)*USER_SPACE)
		userControl._relativeBounds.right = 1
		userControl:UpdateClientArea(false)
	end
	
	-- Status label is unused but might be useful later.
	local statusLabel = TextBox:New {
		x = 160,
		right = 0,
		y = 15,
		height = 35,
		text = "",
		fontsize = Configuration:GetFont(4).size,
		parent = partyInviteWindow,
	}

	local acceptRegistered = false
	local rejectedMatch = false
	local startTimer = Spring.GetTimer()
	local timeRemaining = secondsRemaining
	
	local function DoDispose()
		if partyInviteWindow then
			partyInviteWindow:Dispose()
			partyInviteWindow = nil
			DestroyFunc()
		end
	end
	
	local function CancelFunc()
		lobby:PartyInviteResponse(partyID, false)
		WG.Delay(DoDispose, 0.1)
	end

	local function AcceptFunc()
		lobby:PartyInviteResponse(partyID, true)
		WG.Delay(DoDispose, 0.1)
	end

	local buttonAccept = Button:New {
		right = 150,
		width = 135,
		bottom = 1,
		height = 70,
		caption = i18n("accept"),
		font = Configuration:GetFont(3),
		parent = partyInviteWindow,
		classname = "action_button",
		OnClick = {
			function()
				AcceptFunc()
			end
		},
	}

	local buttonReject = Button:New {
		right = 1,
		width = 135,
		bottom = 1,
		height = 70,
		caption = i18n("reject"),
		font = Configuration:GetFont(3),
		parent = partyInviteWindow,
		classname = "negative_button",
		OnClick = {
			function()
				CancelFunc()
			end
		},
	}

	local popupHolder = WG.Chobby.PriorityPopup(partyInviteWindow, CancelFunc, AcceptFunc, screen0)
	
	local externalFunctions = {}
	
	function externalFunctions.UpdateTimer()
		local newTimeRemaining = secondsRemaining - math.ceil(Spring.DiffTimers(Spring.GetTimer(), startTimer))
		if newTimeRemaining < 0 then
			DoDispose()
		end
		if timeRemaining == newTimeRemaining then
			return
		end
		timeRemaining = newTimeRemaining
		title:SetCaption(titleText .. " (" .. SecondsToMinutes(timeRemaining) .. ")")
	end
	
	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Disable matchmaker while loading
local savedQueues

local function SaveQueues()
	local lobby = WG.LibLobby.lobby
	savedQueues = lobby:GetJoinedQueues()
	lobby:LeaveMatchMakingAll()
end

function widget:ActivateGame()
	if not savedQueues then
		return
	end
	
	for queueName, _ in pairs(savedQueues) do
		WG.LibLobby.lobby:JoinMatchMaking(queueName)
	end
	
	savedQueues = nil
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External functions

local PartyStatusPanel = {}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

function DelayedInitialize()
	local lobby = WG.LibLobby.lobby

	local statusAndInvitesPanel = WG.Chobby.interfaceRoot.GetStatusAndInvitesPanel()
	partyPanel = InitializePartyStatusHandler("partyPanel")
	
	local displayingParty = false
	
	local function OnPartyJoined(_, _, partyUsers)
		if not displayingParty then
			statusAndInvitesPanel.AddControl(partyPanel.GetHolder(), 4)
		end
		displayingParty = true
		partyPanel.UpdateParty(partyUsers)
	end
	
	local function OnPartyLeft(_, _, partyUsers)
		if displayingParty then
			statusAndInvitesPanel.RemoveControl(partyPanel.GetHolder().name)
		end
		displayingParty = false
	end
	
	local function OnPartyUpdate(_, partyID, partyUsers)
		if partyID == lobby:GetMyPartyID() then
			OnPartyJoined(partyID, partyUsers)
		end
	end
	
	local function DestroyInvitePopup()
		invitePopup = nil
	end
	
	local function OnPartyInviteRecieved(_, partyID, partyUsers, secondsRemaining)
		if not invitePopup then
			invitePopup = CreatePartyInviteWindow(partyID, partyUsers, secondsRemaining, DestroyInvitePopup)
		end
	end
	
	lobby:AddListener("OnPartyInviteRecieved", OnPartyInviteRecieved)
	lobby:AddListener("OnPartyJoined", OnPartyJoined)
	lobby:AddListener("OnPartyLeft", OnPartyLeft)
	lobby:AddListener("OnPartyUpdate", OnPartyUpdate)
end

function widget:Update(dt)
	if invitePopup then
		invitePopup.UpdateTimer()
	end
end

function widget:Initialize()
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)

	WG.PartyStatusPanel = PartyStatusPanel
	WG.Delay(DelayedInitialize, 1)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
