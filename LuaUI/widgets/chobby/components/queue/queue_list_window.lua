QueueListWindow = ListWindow:extends{}

function QueueListWindow:init(parent)
    self:super("init", parent, i18n("queues"))

    self.onQueueOpened = function(listener, queue)
        self:AddQueue(queue)
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
        self:AddQueue(queue)
    end
end

function QueueListWindow:AddQueue(queue)
    local h = 60
    local children = {}

    local img = "spring.png"
    local detected = false
    for _, game in pairs(queue.gameNames) do
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
        -- multiple games
        if not notDetected and detected then
            img = "spring.png"
            break
        else
            detected = true
        end
    end
    local gameNamesStr = ""
    for i = 1, #queue.gameNames do 
        local game = queue.gameNames[i]
        gameNamesStr = gameNamesStr .. game
        if i ~= #queue.gameNames then
            gameNamesStr = gameNamesStr .. ", "
        end
    end
    local imgGame = Image:New {
        x = 0,
        width = h - 10,
        y = 10,
        height = h - 20,
        file = CHILI_LOBBY_IMG_DIR .. "games/" .. img,
    }

    local lblTitle = Label:New {
        x = h + 10,
        width = 150,
        y = 0,
        height = h,
        caption = queue.title:sub(1, 15),
        font = { size = 18 },
        valign = 'center',
        tooltip = gameNamesStr, -- TODO: special (?) button for the tooltip
    }
--     if #queue.title > 15 then
--         lblTitle.tooltip = queue.title
--     end
    local missingMaps = {}
    local missingGames = {}
    for _, map in pairs(queue.mapNames) do
        if not VFS.HasArchive(map) then
            table.insert(missingMaps, map)
        end
    end
    for _, game in pairs(queue.gameNames) do
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
        font = { size = 18 },
        OnMouseUp = {
            function()
                if btnJoin.state.pressed then
                    return
                end
                btnJoin.state.pressed = true
                self:JoinQueue(queue, btnJoin)
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
        font = { size = 18 },
        OnMouseUp = {
            function()
                for _, game in pairs(missingGames) do
                    Spring.Log("chililobby", "notice", "Downloading game " .. game)
                    VFS.DownloadArchive(game, "game")
                end
                for _, map in pairs(missingMaps) do
                    Spring.Log("chililobby", "notice", "Downloading map " .. map)
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
--         Spring.Echo("[" .. queue.title .. "] " .. "Missing " .. tostring(#missingGames) .. " games and " .. tostring(#missingMaps) .. " maps.")
    end

    local items = {
        lblTitle,
        imgGame,
        btnQueue,
    }

    self:AddRow(items, queue.name)
end

function QueueListWindow:JoinQueue(queue, btnJoin)
    self.onJoinQueue = function(listener)
        QueueWindow(queue)
        lobby:RemoveListener("OnJoinQueue", self.onJoinQueue)
        self:HideWindow() --Dispose()
        btnJoin.state.pressed = false
    end
    lobby:AddListener("OnJoinQueue", self.onJoinQueue)
    lobby:JoinQueue(queue.name)
end