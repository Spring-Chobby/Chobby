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
-- Variables
local queueStatusHandler -- global for timer update
local queueStatusIngame
local readyCheckPopup 
local findingMatch = false

local instantStartQueuePriority = {
	["Teams"] = 2,
	["1v1"] = 1,
}

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

local function InitializeQueueStatusHandler(parentControl, ControlType)
	local lobby = WG.LibLobby.lobby

	ControlType = ControlType or Panel
	
	local queuePanel = ControlType:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		padding = {0,0,0,0},
		caption = "",
		resizable = false,
		draggable = false,
		parent = parentControl,
	}
	
	local button = Button:New {
		name = "cancel",
		x = "68%",
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
	
	local externalFunctions = {}
	
	function externalFunctions.ResetTimer()
		queueTimer = Spring.GetTimer()
	end
	
	function externalFunctions.UpdateTimer(forceUpdate)
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
		externalFunctions.UpdateTimer(true)
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
	
	function externalFunctions.Resize(xSize, ySize)
		queueStatusText._relativeBounds.right = rightBound
		queueStatusText._relativeBounds.bottom = bottomBound
		queueStatusText:UpdateClientArea()
		if ySize < 60 then
			queueStatusText:SetPos(6, 4)
			bigMode = false
		else
			queueStatusText:SetPos(8, 13)
			bigMode = true
		end
		UpdateQueueText()
	end
	
	function externalFunctions.SetVisibility(newVisibility)
		queuePanel:SetVisibility(newVisibility)
	end
	
	return externalFunctions
end

local function InitializeInstantQueueHandler(parentControl)
	local lobby = WG.LibLobby.lobby
	local queueName

	local queuePanel = Panel:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		padding = {0,0,0,0},
		caption = "",
		resizable = false,
		draggable = false,
		parent = parentControl,
	}
	
	local button = Button:New {
		name = "join",
		x = "50%",
		right = 4,
		y = 4,
		bottom = 4,
		padding = {0,0,0,0},
		caption = "Join",
		font = WG.Chobby.Configuration:GetFont(3),
		classname = "action_button",
		OnClick = {
			function()
				lobby:JoinMatchMaking(queueName)
			end
		},
		parent = queuePanel,
	}
	
	local rightBound = "50%"
	local bottomBound = 12
	local bigMode = true
	
	local queueStatusText = TextBox:New {
		x = 12,
		y = 18,
		right = rightBound,
		bottom = bottomBound,
		fontsize = WG.Chobby.Configuration:GetFont(3).size,
		text = "",
		parent = queuePanel
	}
	
	local externalFunctions = {}
	
	local function UpdateQueueText()
		if queueName then
			queueStatusText:SetText(queueName .. " Availible\nClick to Join")
		end
	end
	
	function externalFunctions.UpdateQueueName(newQueueName)
		queueName = newQueueName
		UpdateQueueText()
	end
	
	function externalFunctions.Resize(xSize, ySize)
		queueStatusText._relativeBounds.right = rightBound
		queueStatusText._relativeBounds.bottom = bottomBound
		queueStatusText:UpdateClientArea()
		if ySize < 60 then
			queueStatusText:SetPos(xSize/4 - 52, 4)
			queueStatusText.font.size = WG.Chobby.Configuration:GetFont(2).size
			queueStatusText:Invalidate()
			bigMode = false
		else
			queueStatusText:SetPos(xSize/4 - 62, 18)
			queueStatusText.font.size = WG.Chobby.Configuration:GetFont(3).size
			queueStatusText:Invalidate()
			bigMode = true
		end
		UpdateQueueText()
	end
	
	function externalFunctions.SetVisibility(newVisibility)
		queuePanel:SetVisibility(newVisibility)
	end
	
	function externalFunctions.ProcessInstantStartQueue(instantStartQueues)
		if instantStartQueues and #instantStartQueues > 0 then
			local instantQueueName
			local bestPriority = -1
			for i = 1, #instantStartQueues do
				local queueName = instantStartQueues[i]
				if (instantStartQueuePriority[queueName] or 0) > bestPriority then
					instantQueueName = queueName
					bestPriority = (instantStartQueuePriority[queueName] or 0)
				end
			end
			if instantQueueName then
				externalFunctions.UpdateQueueName(instantQueueName)
				return true
			end
		end
	end
	
	return externalFunctions
end

local function InitializeIngameStatus(parentControl)	
	local fakeQueuePanel = Control:New {
		right = 2,
		y = 52,
		height = 78,
		width = 300,
		padding = {0,0,0,0},
		caption = "",
		resizable = false,
		draggable = false,
		parent = parentControl,
	}
	
	return fakeQueuePanel, InitializeQueueStatusHandler(fakeQueuePanel, Window)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Ready Check Popup

local function CreateReadyCheckWindow(secondsRemaining, DestroyFunc)
	local Configuration = WG.Chobby.Configuration
	
	if Configuration.menuNotificationVolume ~= 0 then
		Spring.PlaySoundFile("sounds/matchFound.wav", Configuration.menuNotificationVolume or 1)
	end
	
	local readyCheckWindow = Window:New {
		caption = "",
		name = "readyCheckWindow",
		parent = screen0,
		width = 310,
		height = 310,
		resizable = false,
		draggable = false,
		classname = "overlay_window",
	}

	local title = Label:New {
		x = 40,
		right = 0,
		y = 15,
		height = 35,
		caption = i18n("match_found"),
		font = Configuration:GetFont(4),
		parent = readyCheckWindow,
	}

	local statusLabel = TextBox:New {
		x = 15,
		width = 250,
		y = 80,
		height = 35,
		text = "",
		fontsize = Configuration:GetFont(3).size,
		parent = readyCheckWindow,
	}

	local playersAcceptedLabel = Label:New {
		x = 15,
		width = 250,
		y = 130,
		height = 35,
		caption = "Players accepted: 0",
		font = Configuration:GetFont(3),
		parent = readyCheckWindow,
	}

	local acceptRegistered = false
	local rejectedMatch = false
	local displayTimer = true
	local startTimer = Spring.GetTimer()
	local timeRemaining = secondsRemaining
	
	local function DoDispose()
		if readyCheckWindow then
			readyCheckWindow:Dispose()
			readyCheckWindow = nil
			DestroyFunc()
		end
	end
	
	local function CancelFunc()
		lobby:RejectMatchMakingMatch()
		statusLabel:SetText(Configuration:GetErrorColor() .. "Rejected match")
		rejectedMatch = true
		displayTimer = false
		WG.Delay(DoDispose, 1)
	end

	local function AcceptFunc()
		lobby:AcceptMatchMakingMatch()
	end

	local buttonAccept = Button:New {
		right = 150,
		width = 135,
		bottom = 1,
		height = 70,
		caption = i18n("accept"),
		font = Configuration:GetFont(3),
		parent = readyCheckWindow,
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
		parent = readyCheckWindow,
		classname = "negative_button",
		OnClick = {
			function()
				CancelFunc()
			end
		},
	}

	local popupHolder = WG.Chobby.PriorityPopup(readyCheckWindow, CancelFunc, AcceptFunc, screen0)
	
	local externalFunctions = {}
	
	function externalFunctions.UpdateTimer()
		local newTimeRemaining = secondsRemaining - math.ceil(Spring.DiffTimers(Spring.GetTimer(), startTimer))
		if newTimeRemaining < 0 then
			DoDispose()
		end
		if not displayTimer then
			return
		end
		if timeRemaining == newTimeRemaining then
			return
		end
		timeRemaining = newTimeRemaining
		statusLabel:SetText(((acceptRegistered and "Waiting for players ") or "Accept in ") .. SecondsToMinutes(timeRemaining))
	end
	
	function externalFunctions.UpdatePlayerCount(readyPlayers)
		-- queueReadyCounts is not a useful number.
		playersAcceptedLabel:SetCaption("Players accepted: " .. readyPlayers)
	end
	
	function externalFunctions.AcceptRegistered()
		if acceptRegistered then
			return
		end
		acceptRegistered = true
		statusLabel:SetText("Waiting for players " .. (timeRemaining or "time error") .. "s")
		
		buttonAccept:Hide()
		
		buttonReject:SetPos(nil, nil, 90, 60)
		buttonReject._relativeBounds.right = 1
		buttonReject._relativeBounds.bottom = 1
		buttonReject:UpdateClientArea()
	end
	
	function externalFunctions.MatchMakingComplete(success)
		if success then
			statusLabel:SetText(Configuration:GetSuccessColor() .. "Battle starting")
		elseif (not rejectedMatch) then
			-- If we rejected the match then this message is not useful.
			statusLabel:SetText(Configuration:GetWarningColor() .. "Match rejected by another player")
		end
		Spring.Echo("MatchMakingComplete", success)
		displayTimer = false
		WG.Delay(DoDispose, 3)
	end
	
	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External functions

local QueueStatusPanel = {}

function QueueStatusPanel.GetControl()
	local lobby = WG.LibLobby.lobby
	local queueStatusIngamePanel
	
	local fakeQueuePanel = Control:New {
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
					instantQueueHandler.Resize(xSize, ySize)
				end
			end
		}
	}
	
	queueStatusHandler = InitializeQueueStatusHandler(fakeQueuePanel)
	instantQueueHandler = InitializeInstantQueueHandler(fakeQueuePanel)
	
	queueStatusHandler.SetVisibility(false)
	instantQueueHandler.SetVisibility(false)
	
	local previouslyInMatchMaking = false
	
	lobby:AddListener("OnMatchMakerStatus", 
		function(listener, inMatchMaking, joinedQueueList, queueCounts, ingameCounts, instantStartQueues, currentEloWidth, joinedTime, bannedTime)
			findingMatch = inMatchMaking
			
			if not queueStatusIngame then
				queueStatusIngamePanel, queueStatusIngame = InitializeIngameStatus(WG.Chobby.interfaceRoot.GetIngameInterfaceHolder())
			end
			
			Spring.Utilities.TableEcho(instantStartQueues, "instantStartQueues")
			if inMatchMaking then
				if not previouslyInMatchMaking then
					queueStatusHandler.ResetTimer()
					queueStatusIngame.ResetTimer()
				end
				queueStatusHandler.UpdateMatches(joinedQueueList, queueCounts, currentEloWidth, joinedTime)
				queueStatusIngame.UpdateMatches(joinedQueueList, queueCounts, currentEloWidth, joinedTime)
				
				instantQueueHandler.SetVisibility(false)
			else
				if (not bannedTime) and WG.QueueListWindow.HaveRequiredMapsAndGame() and instantQueueHandler.ProcessInstantStartQueue(instantStartQueues) then
					instantQueueHandler.SetVisibility(true)
				else
					instantQueueHandler.SetVisibility(false)
				end
			end
			
			previouslyInMatchMaking = inMatchMaking
			
			queueStatusHandler.SetVisibility(inMatchMaking)
			queueStatusIngamePanel:SetVisibility(inMatchMaking)
		end
	)
	
	local function DestroyReadyCheckPopup()
		readyCheckPopup = nil
	end
	
	local function OnMatchMakerReadyCheck(_, secondsRemaining)
		if not readyCheckPopup then
			readyCheckPopup = CreateReadyCheckWindow(secondsRemaining, DestroyReadyCheckPopup)
		end
	end
	
	local function OnMatchMakerReadyUpdate(_, readyAccepted, likelyToPlay, queueReadyCounts, battleSize, readyPlayers)
		if not readyCheckPopup then
			return
		end
		if readyAccepted then
			readyCheckPopup.AcceptRegistered()
		end
		if readyPlayers then
			readyCheckPopup.UpdatePlayerCount(readyPlayers)
		end
	end
	
	local function OnMatchMakerReadyResult(_, isBattleStarting, areYouBanned)
		Spring.Echo("OnMatchMakerReadyResult", isBattleStarting, areYouBanned)
		if not readyCheckPopup then
			return
		end
		readyCheckPopup.MatchMakingComplete(isBattleStarting)
	end
	
	local function OnBattleAboutToStart()
		-- If the battle is starting while popup is active then assume success.
		if not readyCheckPopup then
			return
		end
		readyCheckPopup.MatchMakingComplete(true)
	end
	
	lobby:AddListener("OnMatchMakerReadyCheck", OnMatchMakerReadyCheck)
	lobby:AddListener("OnMatchMakerReadyUpdate", OnMatchMakerReadyUpdate)
	lobby:AddListener("OnMatchMakerReadyResult", OnMatchMakerReadyResult)
	lobby:AddListener("OnBattleAboutToStart", OnBattleAboutToStart)
	
	return fakeQueuePanel
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

function widget:Update(dt)
	if findingMatch then
		if queueStatusHandler then
			queueStatusHandler.UpdateTimer()
		end
		if queueStatusIngame then
			queueStatusIngame.UpdateTimer()
		end
	end
	if readyCheckPopup then
		readyCheckPopup.UpdateTimer()
	end
end

function widget:Initialize()
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)

	WG.QueueStatusPanel = QueueStatusPanel
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
