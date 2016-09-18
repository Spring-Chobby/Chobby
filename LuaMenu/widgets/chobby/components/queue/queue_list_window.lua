QueueListWindow = ListWindow:extends{}

function QueueListWindow:init(parent)
	self:super("init", parent, i18n("queues"), true)

	self.onQueueOpened = function(listener, name, description, mapNames, maxPartySize, gameNames)
		self:AddQueue(name, description, mapNames, maxPartySize, gameNames)
	end
	self.onQueueClosed = function(listener, name)
		self:RemoveRow(name)
	end
	self.OnListQueues = function() self:Update() end
	lobby:AddListener("OnQueueOpened", self.onQueueOpened)
	lobby:AddListener("OnQueueClosed", self.onQueueClosed)
	lobby:AddListener("OnListQueues", self.OnListQueues)

	self:Update()
end

function QueueListWindow:RemoveListeners()
	lobby:RemoveListener("OnQueueOpened", self.onQueueOpened)
	lobby:RemoveListener("OnQueueClosed", self.onQueueClosed)
	lobby:RemoveListener("OnListQueues", self.OnListQueues)
end

function QueueListWindow:Update()
	self.listPanel:ClearChildren()

	local queues = lobby:GetQueues()
	for _, queue in pairs(queues) do
		self:AddQueue(queue.name, queue.description, queue.mapNames, queue.maxPartSize, queue.gameNames)
	end
end

function QueueListWindow:AddQueue(queueName, description, mapNames, maxPartySize, gameNames)
	local h = 60
	local children = {}

	local img = "spring.png"
	local detected = false
	for _, game in pairs(gameNames) do
		local notDetected = false
		if game:match("EvolutionRTS") then
			img = "evorts.png"
		elseif game:match("Cursed") then
			img = "cursed.png"
		elseif game:match("Balanced Annihilation") then
			img = "balogo.bmp"
		else
			notDetected = true
		end
		-- multiple gameNames
		if not notDetected and detected then
			img = "spring.png"
			break
		else
			detected = true
		end
	end
	local gameNamesStr = ""
	for i = 1, #gameNames do 
		local game = gameNames[i]
		gameNamesStr = gameNamesStr .. game
		if i ~= #gameNames then
			gameNamesStr = gameNamesStr .. ", "
		end
	end
	local imgGame = Image:New {
		x = 0,
		width = h - 10,
		y = 10,
		height = h - 20,
		file = CHOBBY_IMG_DIR .. "games/" .. img,
	}

	local lblTitle = Label:New {
		x = h + 10,
		width = 150,
		y = 0,
		height = h,
		caption = queueName:sub(1, 15),
		font = Configuration:GetFont(2),
		valign = 'center',
		tooltip = gameNamesStr, -- TODO: special (?) button for the tooltip
	}
--	if #queue.title > 15 then
--		lblTitle.tooltip = queue.title
--	end
	local missingMaps = {}
	local missingGames = {}
	for _, map in pairs(mapNames) do
		if not VFS.HasArchive(map) then
			table.insert(missingMaps, map)
		end
	end
	for _, game in pairs(gameNames) do
		if not VFS.HasArchive(game) then
			table.insert(missingGames, game)
		end
	end

	local btnJoin
	btnJoin = Button:New {
		x = lblTitle.x + lblTitle.width + 20,
		width = 120,
		y = 5,
		height = h - 10,
		caption = i18n("join"),
		font = Configuration:GetFont(2),
		OnMouseUp = {
			function()
				if btnJoin.state.pressed then
					return
				end
				btnJoin.state.pressed = true
				self:JoinQueue(queueName, btnJoin)
			end
		},
	}
	local btnDownload
	btnDownload = Button:New {
		x = lblTitle.x + lblTitle.width + 20,
		width = 120,
		y = 5,
		height = h - 10,
		caption = i18n("download"),
		font = Configuration:GetFont(2),
		OnMouseUp = {
			function()
				for _, game in pairs(missingGames) do
					Spring.Log("chobby", "notice", "Downloading game " .. game)
					VFS.DownloadArchive(game, "game")
				end
				for _, map in pairs(missingMaps) do
					Spring.Log("chobby", "notice", "Downloading map " .. map)
					VFS.DownloadArchive(map, "map")
				end
				-- download game
			end
		},
	}
	local btnQueue = btnDownload

	if #missingMaps + #missingGames == 0 then
		btnQueue = btnJoin
	else
--         Spring.Echo("[" .. queue.title .. "] " .. "Missing " .. tostring(#missingGames) .. " games and " .. tostring(#missingMaps) .. " mapNames.")
	end

	local items = {
		lblTitle,
		imgGame,
		btnQueue,
	}

	self:AddRow(items, queueName)
end

function QueueListWindow:JoinQueue(queueName, btnJoin)
	self.onJoinQueue = function(listener, _, joinedQueueList)
		if WG.Chobby.lobbyInterfaceHolder:GetChildByName("queue_" .. queueName) then
			return
		end
		for i = 1, #joinedQueueList do
			if queueName == joinedQueueList[i] then
				QueueWindow(queueName)
				lobby:RemoveListener("OnMatchMakerStatus", self.onJoinQueue)
				self:HideWindow() --Dispose()
				btnJoin.state.pressed = false
			end
		end
	end
	lobby:AddListener("OnMatchMakerStatus", self.onJoinQueue)
	lobby:JoinMatchMaking(queueName)
end
