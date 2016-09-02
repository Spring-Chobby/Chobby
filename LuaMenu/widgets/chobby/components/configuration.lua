Configuration = LCS.class{}

VFS.Include("libs/liblobby/lobby/json.lua")

-- all configuration attribute changes should use the :Set*Attribute*() and :Get*Attribute*() methods in order to assure proper functionality
function Configuration:init()
	self.listeners = {}

--     self.serverAddress = "localhost"
	self.serverAddress = WG.Server.serverAddress or "springrts.com"
	self.serverPort = 8200

	self.chatMaxNameLength = 120 -- Pixels
	self.statusMaxNameLength = 180
	self.friendMaxNameLength = 180
	self.notificationMaxNameLength = 180

	self.userName = ""
	self.password = ""
	self.autoLogin = false
	self.channels = {}

	self.promptNewUsersToLogIn = false

	self.errorColor = "\255\255\0\0"
	self.warningColor = "\255\255\255\0"
	self.normalColor = "\255\255\255\255"
	self.successColor = "\255\0\255\0"
	self.partialColor = "\255\190\210\50"
	self.selectedColor = "\255\99\184\255"
	self.meColor = "\255\0\190\190"
	self.buttonFocusColor = {0.54,0.72,1,0.3}
	self.buttonSelectedColor = {0.54,0.72,1,0.6}--{1.0, 1.0, 1.0, 1.0}

	self.loadLocalWidgets = false
	self.displayBots = false
	self.displayBadEngines = false

	-- Do not ask again tests.
	self.confirmation_mainMenuFromBattle = false
	self.confirmation_battleFromBattle = false

	self.backConfirmation = {
		multiplayer = {
			{
				doNotAskAgainKey = "confirmation_mainMenuFromBattle",
				question = "You are in a battle and will leave it if you return to the main menu. Are you sure you want to return to the main menu?",
				testFunction = function ()
					return (lobby:GetMyBattleID() and true) or false
				end
			}
		},
		singleplayer = {
		}
	}

	self.userListWidth = 220 -- Main user list width. Possibly configurable in the future.

	self.shortnameMap = {
		"chobby",
		"zk",
	}
	self.singleplayer_mode = 2

	self.lastLoginChatLength = 25
	self.notifyForAllChat = true
	self.debugMode = false
	self.onlyShowFeaturedMaps = true
	self.useSpringRestart = false

	self.font = {
		[0] = {size = 10, shadow = false},
		[1] = {size = 14, shadow = false},
		[2] = {size = 18, shadow = false},
		[3] = {size = 22, shadow = false},
		[4] = {size = 32, shadow = false},
		[5] = {size = 48, shadow = false},
	}

	self.countryShortnames = VFS.Include(LUA_DIRNAME .. "configs/countryShortname.lua")

	self.game_settings = VFS.Include(LUA_DIRNAME .. "configs/springsettings/springsettings3.lua")
end

---------------------------------------------------------------------------------
-- Widget interface callins
---------------------------------------------------------------------------------

function Configuration:SetConfigData(data)
	if data ~= nil then
		for k, v in pairs(data) do
			self:SetConfigValue(k, v)
		end
	end
end

function Configuration:GetConfigData()
	return {
		userName = self.userName,
		password = self.password,
		autoLogin = self.autoLogin,
		channels = self.channels,
		singleplayer_mode = self.singleplayer_mode,
		game_fullscreen = self.game_fullscreen,
		panel_layout = self.panel_layout,
		lobby_fullscreen = self.lobby_fullscreen,
		game_settings = self.game_settings,
		notifyForAllChat = self.notifyForAllChat,
		debugMode = self.debugMode,
		confirmation_mainMenuFromBattle = self.confirmation_mainMenuFromBattle,
		confirmation_battleFromBattle = self.confirmation_battleFromBattle,
		loadLocalWidgets = self.loadLocalWidgets,
		onlyShowFeaturedMaps = self.onlyShowFeaturedMaps,
		useSpringRestart = self.useSpringRestart,
		displayBots = self.displayBots,
		displayBadEngines = self.displayBadEngines,
	}
end

---------------------------------------------------------------------------------
-- Setters
---------------------------------------------------------------------------------

function Configuration:SetConfigValue(key, value)
	if self[key] == value then
		return
	end
	self[key] = value
	if key == "useSpringRestart" then
		lobby.useSpringRestart = value
		localLobby.useSpringRestart = value
	end
	self:_CallListeners("OnConfigurationChange", key, value)
end

---------------------------------------------------------------------------------
-- Getters
---------------------------------------------------------------------------------

function Configuration:GetServerAddress()
	return self.serverAddress
end

function Configuration:GetServerPort()
	return self.serverPort
end

function Configuration:GetErrorColor()
	return self.errorColor
end

function Configuration:GetWarningColor()
	return self.warningColor
end

function Configuration:GetNormalColor()
	return self.normalColor
end

function Configuration:GetSuccessColor()
	return self.successColor
end

function Configuration:GetPartialColor()
	return self.partialColor
end

function Configuration:GetSelectedColor()
	return self.selectedColor
end

function Configuration:GetButtonFocusColor()
	return self.buttonFocusColor
end

-- NOTE: this one is in opengl range [0,1]
function Configuration:GetButtonSelectedColor()
	return self.buttonSelectedColor
end

function Configuration:GetChannels()
	return self.channels
end

function Configuration:GetCross()
	return self:GetErrorColor() .. "X"
end

function Configuration:GetTick()
	return self:GetSuccessColor() .. "O"
end

function Configuration:GetFont(sizeScale)
	return {
		size = self.font[sizeScale].size,
		shadow = self.font[sizeScale].shadow,
	}
end

function Configuration:GetMinimapSmallImage(mapName, gameName)
	mapName = string.gsub(mapName, " ", "_")
	local minimapImage = self:GetGameConfigFilePath(gameName, "minimapThumbnail/" .. mapName .. ".png", "zk")
	if minimapImage then
		return minimapImage
	end
	Spring.Log("Chobby", LOG.WARNING, "Missing minimap image for", mapName)
	return LUA_DIRNAME .. "images/minimapNotFound1.png"
end

function Configuration:GetMinimapImage(mapName, gameName)
	mapName = string.gsub(mapName, " ", "_")
	local minimapImage = self:GetGameConfigFilePath(gameName, "minimapOverride/" .. mapName .. ".jpg", "zk")
	if minimapImage then
		return minimapImage
	end
	Spring.Log("Chobby", LOG.WARNING, "Missing minimap image for", mapName)
	return LUA_DIRNAME .. "images/minimapNotFound1.png"
end

function Configuration:GetGameConfigFilePath(gameName, fileName, shortnameFallback)
	local gameInfo = gameName and VFS.GetArchiveInfo(gameName)
	local shortname = (gameInfo and gameInfo.shortname and string.lower(gameInfo.shortname)) or shortnameFallback
	if shortname then
		local filePath = LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/" .. fileName
		if VFS.FileExists(filePath) then
			return filePath
		end
	end
	return false
end

function Configuration:GetGameConfig(gameName, fileName, shortnameFallback)
	local filePath = self:GetGameConfigFilePath(gameName, fileName, shortnameFallback)
	if filePath then
		return VFS.Include(filePath)
	end
	return false
end

function Configuration:GetCountryLongname(shortname)
	if shortname and self.countryShortnames[shortname] then
		return self.countryShortnames[shortname]
	end
	return shortname
end

function Configuration:GetHeadingImage(fullscreenMode)
	if fullscreenMode then
		return self:GetGameConfigFilePath(false, "skinning/headingLarge.png", self.shortnameMap[self.singleplayer_mode])
	else
		return self:GetGameConfigFilePath(false, "skinning/headingSmall.png", self.shortnameMap[self.singleplayer_mode])
	end
end

function Configuration:GetBackgroundImage()
	local shortname = self.shortnameMap[self.singleplayer_mode]

	local skinConfig = self:GetGameConfig(false, "skinning/skinConfig.lua", shortname)
	local backgroundFocus
	if skinConfig then
		backgroundFocus = skinConfig.backgroundFocus
	end

	local pngImage = self:GetGameConfigFilePath(false, "skinning/background.png", shortname)
	if pngImage then
		return pngImage, backgroundFocus
	end
	return self:GetGameConfigFilePath(false, "skinning/background.jpg", shortname), backgroundFocus
end

function Configuration:IsValidEngineVersion(engineVersion)
	if self.displayBadEngines then
		return true
	end
	Spring.Echo("Checking engineVersion", engineVersion, "against", Game.version, "numbers", tonumber(Game.version), string.gsub(Game.version, " develop", ""))
	if tonumber(Game.version) then
		-- Master releases lack the '.0' at the end. Who knows what other cases are wrong.
		-- Add as required.
		return engineVersion == (Game.version .. ".0")
	else
		return string.gsub(Game.version, " develop", "") == engineVersion
	end
end

---------------------------------------------------------------------------------
-- Listener handler
---------------------------------------------------------------------------------
local function ShallowCopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in pairs(orig) do
			copy[orig_key] = orig_value
		end
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

function Configuration:AddListener(event, listener)
	if listener == nil then
		Spring.Log(LOG_SECTION, LOG.ERROR, "Event: " .. tostring(event) .. ", listener cannot be nil")
		return
	end
	local eventListeners = self.listeners[event]
	if eventListeners == nil then
		eventListeners = {}
		self.listeners[event] = eventListeners
	end
	table.insert(eventListeners, listener)
end

function Configuration:RemoveListener(event, listener)
	if self.listeners[event] then
		for k, v in pairs(self.listeners[event]) do
			if v == listener then
				table.remove(self.listeners[event], k)
				if #self.listeners[event] == 0 then
					self.listeners[event] = nil
				end
				break
			end
		end
	end
end

function Configuration:_CallListeners(event, ...)
	if self.listeners[event] == nil then
		return nil -- no event listeners
	end
	local eventListeners = ShallowCopy(self.listeners[event])
	for i = 1, #eventListeners do
		local listener = eventListeners[i]
		args = {...}
		xpcall(function() listener(listener, unpack(args)) end,
			function(err) self:_PrintError(err) end )
	end
	return true
end

---------------------------------------------------------------------------------
-- 'Initialization'
---------------------------------------------------------------------------------
-- shadow the Configuration class with a singleton
Configuration = Configuration()
