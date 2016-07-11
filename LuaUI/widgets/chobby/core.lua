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
	-- skirmish
	"components/skirmish/skirmish_window.lua",
	-- battle
	"components/battle/battle_list_window.lua",
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
	
	-- new stuff
	"components/interface_root.lua",
	"components/tab_panel_handler.lua",
	"components/submenu_handler.lua",
	"components/priority_popup.lua",
	"components/ai_list_window.lua",
	"components/map_list_window.lua",
	"components/game_list_window.lua",
}

Chobby = widget

for _, file in ipairs(includes) do
	VFS.Include(CHOBBY_DIR .. file, Chobby, VFS.RAW_FIRST)
end

function Chobby:_Initialize()
	self:WrapCall(function()
		WG.Delay(function()
			--self.downloader = Downloader()
			--local statusBar = StatusBar()
			--local background = Background()

			lobby:AddListener("OnJoinBattle", 
				function(listener, battleID)
					WG.BattleRoomWindow.ShowMultiplayerBattleRoom(battleID)
				end
			)
		end, 0.001)
	end)
end

function Chobby:GetRegisteredComponents()
	return Component.registeredComponents
end

function Chobby:_DrawScreen()
	self:WrapCall(function()
	end)
end

function Chobby:_ViewResize(sw, sh)
	self:WrapCall(function()
		for i, comp in pairs(self:GetRegisteredComponents()) do
			comp:ViewResize(sw, sh)
		end
	end)
end

function Chobby:_DownloadStarted(id)
	self:WrapCall(function()
		for i, comp in pairs(self:GetRegisteredComponents()) do
			comp:DownloadStarted(id)
		end
	end)
end

function Chobby:_DownloadFinished(id)
	self:WrapCall(function()
		for i, comp in pairs(self:GetRegisteredComponents()) do
			comp:DownloadFinished(id)
		end
	end)
end

function Chobby:_DownloadFailed(id, errorId)
	self:WrapCall(function()
		for i, comp in pairs(self:GetRegisteredComponents()) do
			comp:DownloadFailed(id, errorId)
		end
	end)
end

function Chobby:_DownloadProgress(id, downloaded, total)
	self:WrapCall(function()
		for i, comp in pairs(self:GetRegisteredComponents()) do
			comp:DownloadProgress(id, downloaded, total)
		end
	end)
end

function Chobby:_DownloadQueued(id, archiveName, archiveType)
	self:WrapCall(function()
		for i, comp in pairs(self:GetRegisteredComponents()) do
			comp:DownloadQueued(id, archiveName, archiveType)
		end
	end)
end

function Chobby:WrapCall(func)
	xpcall(function() func() end, 
		function(err) self:_PrintError(err) end )
end

function Chobby:_PrintError(err)
	Spring.Log("Chobby", LOG.ERROR, err)
	Spring.Log("Chobby", LOG.ERROR, debug.traceback(err))
end

function Chobby:_GetConfigData()
	return Configuration:GetConfigData()
end

function Chobby:_SetConfigData(data)
	Configuration:SetConfigData(data)
end

return Chobby
