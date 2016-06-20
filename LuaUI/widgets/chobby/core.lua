local includes = {
    -- order matters
    "headers/exports.lua",

    -- config
    "components/configuration.lua",

    -- basic components
    "components/component.lua",
    "components/list_window.lua",
    "components/console.lua",
    "components/user_list_panel.lua",

    -- misc
    "components/login_window.lua",
    "components/chat_windows.lua",
    "components/team_window.lua",
    "components/downloader.lua",
    "components/background.lua",

    -- play
    "components/play_window.lua",
    -- battle
    "components/battle/battle_list_window.lua",
    "components/battle/battle_room_window.lua",
    -- queue
    "components/queue/queue_list_window.lua",
    "components/queue/queue_window.lua",
    "components/queue/ready_check_window.lua",

    -- status bar
    "components/status_bar/status_bar.lua",
    "components/status_bar/sb_item.lua",
    "components/status_bar/sb_connection_status.lua",
    "components/status_bar/sb_downloads_icon.lua",
    "components/status_bar/sb_errors_icon.lua",
    "components/status_bar/sb_friends_icon.lua",
    "components/status_bar/sb_menu_icon.lua",
    "components/status_bar/sb_player_welcome.lua",
    "components/status_bar/sb_server_status.lua",
}

local ChiliLobby = widget

for _, file in ipairs(includes) do
    VFS.Include(CHILILOBBY_DIR .. file, ChiliLobby, VFS.RAW_FIRST)
end

function ChiliLobby:initialize()
    self:WrapCall(function()
        local loginWindow = LoginWindow()
        --self.downloader = Downloader()
        local statusBar = StatusBar()
        local background = Background()

        lobby:AddListener("OnJoinBattle", 
            function(listener, battleID)
                local battleRoom = BattleRoomWindow(battleID)
            end
        )
    end)
end

function ChiliLobby:DrawScreen()
    self:WrapCall(function()
    end)
end

function ChiliLobby:GetRegisteredComponents()
    return Component.registeredComponents
end

function ChiliLobby:DownloadStarted(id)
    self:WrapCall(function()
        for i, comp in pairs(self:GetRegisteredComponents()) do
            comp:DownloadStarted(id)
        end
    end)
end

function ChiliLobby:DownloadFinished(id)
    self:WrapCall(function()
        for i, comp in pairs(self:GetRegisteredComponents()) do
            comp:DownloadFinished(id)
        end
    end)
end

function ChiliLobby:DownloadFailed(id, errorId)
    self:WrapCall(function()
        for i, comp in pairs(self:GetRegisteredComponents()) do
            comp:DownloadFailed(id, errorId)
        end
    end)
end

function ChiliLobby:DownloadProgress(id, downloaded, total)
    self:WrapCall(function()
        for i, comp in pairs(self:GetRegisteredComponents()) do
            comp:DownloadProgress(id, downloaded, total)
        end
    end)
end

function ChiliLobby:DownloadQueued(id, archiveName, archiveType)
    self:WrapCall(function()
        for i, comp in pairs(self:GetRegisteredComponents()) do
            comp:DownloadQueued(id, archiveName, archiveType)
        end
    end)
end

function ChiliLobby:WrapCall(func)
    xpcall(function() func() end, 
        function(err) self:_PrintError(err) end )
end

function ChiliLobby:_PrintError(err)
    Spring.Log("chiliLobby", LOG.ERROR, err)
    Spring.Log("chiliLobby", LOG.ERROR, debug.traceback(err))
end

return ChiliLobby
