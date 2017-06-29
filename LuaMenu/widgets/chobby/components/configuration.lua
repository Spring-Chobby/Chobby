Configuration = LCS.class{}

VFS.Include("libs/liblobby/lobby/json.lua")

LIB_LOBBY_DIRNAME = "libs/liblobby/lobby/"


-- all configuration attribute changes should use the :Set*Attribute*() and :Get*Attribute*() methods in order to assure proper functionality
function Configuration:init()
	self.listeners = {}

	local fileConfig
	if VFS.FileExists(LUA_DIRNAME .. "configs/liblobby_configuration.lua") then
		fileConfig = VFS.Include(LUA_DIRNAME .. "configs/liblobby_configuration.lua", nil, VFS.RAW_FIRST)
	end
	if not fileConfig.game then
		Spring.Log("Chobby", LOG.WARNING, "Missing game in chobby_config.json file.")
		-- FIXME: This will be changed to "generic" in future versions.
		fileConfig.game = "zk"
	end

	--self.serverAddress = "localhost"
	self.serverAddress = WG.Server.address
	self.serverPort =  WG.Server.port

	self.userListWidth = 205 -- Main user list width. Possibly configurable in the future.
	self.chatMaxNameLength = 185 -- Pixels
	self.statusMaxNameLength = 185
	self.friendMaxNameLength = 230
	self.notificationMaxNameLength = 230

	self.userName = false
	self.suggestedNameFromSteam = false
	self.password = false
	self.autoLogin = true
	self.firstLoginEver = true
	self.canAuthenticateWithSteam = false
	self.wantAuthenticateWithSteam = true
	self.steamLinkComplete = false
	self.alreadySeenFactionPopup2 = false
	self.channels = {}
	
	self.manualBorderless = {
		game = {},
		lobby = {},
	}
	
	self.ignoreLevel = false

	self.errorColor = "\255\255\0\0"
	self.warningColor = "\255\255\255\0"
	self.normalColor = "\255\255\255\255"
	self.successColor = "\255\0\255\0"
	self.partialColor = "\255\190\210\50"
	self.selectedColor = "\255\99\184\255"
	self.highlightedColor = "\255\125\255\0"
	self.meColor = "\255\0\190\190"

	self.moderatorColor = {0.68, 0.78, 1, 1}
	self.founderColor = {0.7, 1, 0.65, 1}
	self.ignoredUserNameColor = {0.6, 0.6, 0.6, 1}
	self.userNameColor = {1, 1, 1, 1}

	self.buttonFocusColor = {0.54,0.72,1,0.3}
	self.buttonSelectedColor = {0.54,0.72,1,0.6}--{1.0, 1.0, 1.0, 1.0}

	self.loadLocalWidgets = false
	self.displayBots = false
	self.displayBadEngines = false
	self.doNotSetAnySpringSettings = false
	self.agressivelySetBorderlessWindowed = false

	self.useWrongEngine = false

	self.atiIntelCompat = self:GetIsNotRunningNvidia()
	Spring.Echo("ATI/intel/other non-nvidia compatibility state:", self.atiIntelCompat)

	self.myAccountID = false
	self.lastAddedAiName = false

	self.battleTypeToName = {
		[5] = "cooperative",
		[6] = "team",
		[3] = "oneVsOne",
		[4] = "freeForAll",
		[0] = "custom",
	}

	-- Do not ask again tests.
	self.confirmation_mainMenuFromBattle = false
	self.confirmation_battleFromBattle = false

	self.leaveMultiplayerOnMainMenu = false

	self.backConfirmation = {
		multiplayer = {
			self.leaveMultiplayerOnMainMenu and {
				doNotAskAgainKey = "confirmation_mainMenuFromBattle",
				question = "You are in a battle and will leave it if you return to the main menu. Are you sure you want to return to the main menu?",
				testFunction = function ()
					local battleID = lobby:GetMyBattleID()
					if not battleID then
						return false
					end
					if self.showMatchMakerBattles then
						return true
					end
					local battle = lobby:GetBattle(battleID)
					return (battle and not battle.isMatchMaker) or false
				end
			} or nil
		},
		singleplayer = {
		}
	}

	self.gameConfigName = fileConfig.game
	self.gameConfig = VFS.Include(LUA_DIRNAME .. "configs/gameConfig/" .. self.gameConfigName .. "/mainConfig.lua")

	self.campaignPath = "campaign/sample"
	self.campaignConfigName = "sample"
	self.campaignConfig = VFS.Include("campaign/sample/mainConfig.lua")
	self.campaignSaveFile = "Campaign1"

	-- TODO, generate this from directory structure
	local gameConfigOptions = {
		"zk",
		"generic",
		"zkdev",
		"evorts"
	}

	self.gameConfigOptions = {}
	self.gameConfigHumanNames = {}
	for i = 1, #gameConfigOptions do
		local fileName = LUA_DIRNAME .. "configs/gameConfig/" .. gameConfigOptions[i] .. "/mainConfig.lua"
		if VFS.FileExists(fileName) then
			local gameConfig = VFS.Include(fileName)
			if gameConfig.CheckAvailability() then
				self.gameConfigHumanNames[#self.gameConfigHumanNames + 1] = gameConfig.name
				self.gameConfigOptions[#self.gameConfigOptions + 1] = gameConfigOptions[i]
			end
		end
	end

	self.lastLoginChatLength = 25
	self.notifyForAllChat = true
	self.planetwarsNotifications = false -- Possibly too intrusive? See how it goes.
	self.simplifiedSkirmishSetup = true
	self.debugMode = false
	self.activeDebugConsole = false
	self.onlyShowFeaturedMaps = true
	self.useSpringRestart = false
	self.menuMusicVolume = 0.5
	self.menuNotificationVolume = 0.8
	self.menuBackgroundBrightness = 1
	self.gameOverlayOpacity = 0.5
	self.showMatchMakerBattles = false
	self.hideInterface = false
	self.enableTextToSpeech = true
	self.showOldAiVersions = false
	self.drawAtFullSpeed = false

	self.chatFontSize = 18

	self.font = {
		[0] = {size = 10, shadow = false},
		[1] = {size = 14, shadow = false},
		[2] = {size = 18, shadow = false},
		[3] = {size = 22, shadow = false},
		[4] = {size = 32, shadow = false},
		[5] = {size = 48, shadow = false},
	}

	self.configParamTypes = {}
	for _, param in pairs(Spring.GetConfigParams()) do
		self.configParamTypes[param.name] = param.type
	end
	
	self.AtiIntelSettingsOverride = nil
	self.fixedSettingsOverride = AtiIntelSettingsOverride

	self.countryShortnames = VFS.Include(LUA_DIRNAME .. "configs/countryShortname.lua")

	self.game_settings = VFS.Include(LUA_DIRNAME .. "configs/springsettings/springsettings.lua")

	self.settingsMenuValues = self.gameConfig.settingsDefault

	self.animate_lobby = gl.CreateShader ~= nil
	
	self:UpdateFixedSettings()
end

---------------------------------------------------------------------------------
-- Settings
---------------------------------------------------------------------------------

function Configuration:SetSpringsettingsValue(key, value, compatOverride)
	if self.doNotSetAnySpringSettings then
		return
	end
	
	if not compatOverride then
		local compatProfile = self.forcedCompatibilityProfile
		if compatProfile and compatProfile[key] then
			return
		end
	end
	
	value = (self.fixedSettingsOverride and self.fixedSettingsOverride[key]) or value
	
	local configType = self.configParamTypes[key]
	if configType == "int" then
		Spring.Echo("SetSettings Int", key, value)
		Spring.SetConfigInt(key, value)
	elseif configType == "bool" or configType == "float" then
		Spring.Echo("SetSettings Value", key, value)
		Spring.SetConfigString(key, value)
	elseif configType == nil then
		Spring.Log("Settings", LOG.WARNING, "No such key: " .. tostring(key) .. ", but setting it as string anyway.")
		Spring.SetConfigString(key, value)
	else
		Spring.Log("Settings", LOG.WARNING, "Unexpected key type: " .. configType .. ", but setting it as string anyway.")
		Spring.SetConfigString(key, value)
	end
end

function Configuration:UpdateFixedSettings(newOverride)
	local gameSettings = self.game_settings
	
	-- Reset old
	local oldOverride = self.fixedSettingsOverride
	self.fixedSettingsOverride = nil
	if oldOverride then
		for key, value in pairs(oldOverride) do
			if gameSettings[key] then
				self:SetSpringsettingsValue(key, gameSettings[key])
			end
		end
	end
	
	-- Apply new
	self.fixedSettingsOverride = newOverride
	if newOverride then
		for key, value in pairs(newOverride) do
			self:SetSpringsettingsValue(key, value)
		end
	end
end

function Configuration:SetSettingsConfigOption(name, newValue)
	local setting = self.gameConfig.settingsNames[name]
	if not setting then
		return false
	end
	
	self.settingsMenuValues[name] = newValue

	if setting.isNumberSetting then
		local applyFunction = setting.applyFunction
		if applyFunction then
			local applyData = applyFunction(newValue)
			if applyData then
				for applyName, value in pairs(applyData) do
					self.game_settings[applyName] = value
					self:SetSpringsettingsValue(applyName, value)
				end
			end
		else
			local springValue = setting.springConversion(newValue)
			self.game_settings[setting.applyName] = springValue
			self:SetSpringsettingsValue(setting.applyName, springValue)
		end
	else
		-- Selection from multiple options
		local selectedOption = setting.optionNames[newValue]
		if setting.fileTarget then
			self.settingsMenuValues[name .. "_file"] = selectedOption.file
			if setting.applyFunction then
				setting.applyFunction(selectedOption.file)
			else
				local sourceFile = VFS.LoadFile(selectedOption.file)
				local settingsFile = io.open(setting.fileTarget, "w")
				settingsFile:write(sourceFile)
				settingsFile:close()
			end
		else
			local applyData = selectedOption.apply or (selectedOption.applyFunction and selectedOption.applyFunction())
			if not applyData then
				return
			end
			for applyName, value in pairs(applyData) do
				self.game_settings[applyName] = value
				self:SetSpringsettingsValue(applyName, value)
			end
		end
	end
end

function Configuration:ApplySettingsConfigPreset(preset)
	for name, value in pairs(preset) do
		self:SetSettingsConfigOption(name, value)
	end
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

	-- Fix old channel memory.
	for key, value in pairs(self.channels) do
		if string.find(key, "debriefing") then
			self.channels[key] = nil
		end
	end
	
	self.game_settings.XResolutionWindowed = nil
	self.game_settings.YResolutionWindowed = nil
	self.game_settings.WindowPosX = nil
	self.game_settings.WindowPosY = nil
	self.game_settings.WindowBorderless = nil
	self.game_settings.Fullscreen = nil
	
	local newSpringsettings = VFS.Include(LUA_DIRNAME .. "configs/springsettings/springsettingsChanges.lua")
	for key, value in pairs(newSpringsettings) do
		self.game_settings[key] = value
	end
	
	self.forcedCompatibilityProfile = VFS.Include(LUA_DIRNAME .. "configs/springsettings/forcedCompatibilityProfile.lua")
	
	self.defaultSettingsPreset = data.defaultSettingsPreset
	if (not self.defaultSettingsPreset) and self.gameConfig.SettingsPresetFunc then
		self.defaultSettingsPreset = self.gameConfig.SettingsPresetFunc()
		if self.defaultSettingsPreset then
			self:ApplySettingsConfigPreset(self.defaultSettingsPreset)
		end
	end
end

function Configuration:GetConfigData()
	return {
		serverAddress = self.serverAddress,
		serverPort = self.serverPort,
		userName = self.userName,
		suggestedNameFromSteam = self.suggestedNameFromSteam,
		password = self.password,
		autoLogin = self.autoLogin,
		firstLoginEver = self.firstLoginEver,
		wantAuthenticateWithSteam = self.wantAuthenticateWithSteam,
		steamLinkComplete = self.steamLinkComplete,
		alreadySeenFactionPopup2 = self.alreadySeenFactionPopup2,
		channels = self.channels,
		gameConfigName = self.gameConfigName,
		game_fullscreen = self.game_fullscreen,
		panel_layout = self.panel_layout,
		lobby_fullscreen = self.lobby_fullscreen,
		manualBorderless = self.manualBorderless,
		animate_lobby = self.animate_lobby,
		game_settings = self.game_settings,
		defaultSettingsPreset = self.defaultSettingsPreset,
		notifyForAllChat = self.notifyForAllChat,
		planetwarsNotifications = self.planetwarsNotifications,
		simplifiedSkirmishSetup = self.simplifiedSkirmishSetup,
		debugMode = self.debugMode,
		confirmation_mainMenuFromBattle = self.confirmation_mainMenuFromBattle,
		confirmation_battleFromBattle = self.confirmation_battleFromBattle,
		drawAtFullSpeed = self.drawAtFullSpeed,
		loadLocalWidgets = self.loadLocalWidgets,
		activeDebugConsole = self.activeDebugConsole,
		onlyShowFeaturedMaps = self.onlyShowFeaturedMaps,
		useSpringRestart = self.useSpringRestart,
		displayBots = self.displayBots,
		displayBadEngines = self.displayBadEngines,
		doNotSetAnySpringSettings = self.doNotSetAnySpringSettings,
		agressivelySetBorderlessWindowed = self.agressivelySetBorderlessWindowed,
		atiIntelCompat = self.atiIntelCompat,
		settingsMenuValues = self.settingsMenuValues,
		menuMusicVolume = self.menuMusicVolume,
		menuNotificationVolume = self.menuNotificationVolume,
		menuBackgroundBrightness = self.menuBackgroundBrightness,
		gameOverlayOpacity = self.gameOverlayOpacity,
		showMatchMakerBattles = self.showMatchMakerBattles,
		enableTextToSpeech = self.enableTextToSpeech,
		showOldAiVersions = self.showOldAiVersions,
		chatFontSize = self.chatFontSize,
		myAccountID = self.myAccountID,
		lastAddedAiName = self.lastAddedAiName,
		window_WindowPosX = self.window_WindowPosX,
		window_WindowPosY = self.window_WindowPosY,
		window_XResolutionWindowed = self.window_XResolutionWindowed,
		window_YResolutionWindowed = self.window_YResolutionWindowed,
		campaignSaveFile = self.campaignSaveFile,
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
	if key == "gameConfigName" then
		self.gameConfig = VFS.Include(LUA_DIRNAME .. "configs/gameConfig/" .. value .. "/mainConfig.lua")
	end
	if key == "atiIntelCompat" then
		if value then
			self:UpdateFixedSettings(self.AtiIntelSettingsOverride)
		else
			self:UpdateFixedSettings()
		end
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

function Configuration:GetHighlightedColor()
	return self.highlightedColor
end

function Configuration:GetButtonFocusColor()
	return self.buttonFocusColor
end

function Configuration:GetModeratorColor()
	return self.moderatorColor
end

function Configuration:GetFounderColor()
	return self.founderColor
end

function Configuration:GetIgnoredUserNameColor()
	return self.ignoredUserNameColor
end

function Configuration:GetUserNameColor()
	return self.userNameColor
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

function Configuration:GetMinimapSmallImage(mapName)
	if not self.gameConfig.minimapThumbnailPath then
		return LUA_DIRNAME .. "images/minimapNotFound1.png"
	end
	mapName = string.gsub(mapName, " ", "_")
	local filePath = self.gameConfig.minimapThumbnailPath .. mapName .. ".png"
	if not VFS.FileExists(filePath) then
		Log.Warning("Missing minimap image for", mapName)
		return LUA_DIRNAME .. "images/minimapNotFound1.png"
	end
	return filePath
end

function Configuration:GetMinimapImage(mapName)
	if not self.gameConfig.minimapOverridePath then
		return LUA_DIRNAME .. "images/minimapNotFound1.png"
	end
	mapName = string.gsub(mapName, " ", "_")
	local filePath = self.gameConfig.minimapOverridePath .. mapName .. ".jpg"
	if not VFS.FileExists(filePath) then
		Log.Warning("Missing minimap image for", mapName)
		return LUA_DIRNAME .. "images/minimapNotFound1.png"
	end
	return filePath
end

function Configuration:GetCountryLongname(shortname)
	if shortname and self.countryShortnames[shortname] then
		return self.countryShortnames[shortname]
	end
	return shortname
end

function Configuration:GetHeadingImage(fullscreenMode, title)
	local subheadings = self.gameConfig.subheadings
	if fullscreenMode then
		return (subheadings and subheadings.large and subheadings.large[title]) or self.gameConfig.headingLarge
	else
		return (subheadings and subheadings.small and subheadings.small[title]) or self.gameConfig.headingSmall
	end
end

function Configuration:GetEngineVersion()
	if tonumber(Spring.Utilities.GetEngineVersion()) then
		-- Master releases lack the '.0' at the end. Who knows what other cases are wrong.
		-- Add as required.
		return (Spring.Utilities.GetEngineVersion() .. ".0")
	else
		return string.gsub(Spring.Utilities.GetEngineVersion(), " develop", "")
	end
end

function Configuration:IsValidEngineVersion(engineVersion)
	return engineVersion == self:GetEngineVersion()
end

function Configuration:GetDefaultGameName()
	if not self.gameConfig then
		return false
	end

	local rapidTag = self.gameConfig._defaultGameRapidTag
	if rapidTag and VFS.GetNameFromRapidTag then
		local rapidName = VFS.GetNameFromRapidTag(rapidTag)
		if rapidName then
			return rapidName
		end
	end

	return self.gameConfig._defaultGameArchiveName
end

function Configuration:GetIsRunning64Bit()
	if self.isRunning64Bit ~= nil then
		return self.isRunning64Bit
	end
	if Platform then
		-- osWordSize is not the same as spring bit version.
		--return Platform.osWordSize == 64
	end
	local infologFile, err = io.open("infolog.txt", "r")
	if not infologFile then
		Spring.Echo("Error opening infolog.txt", err)
		return false
	end
	local line = infologFile:read()
	while line do
		if string.find(line, "Physical CPU Cores") then
			break
		end
		if string.find(line, "Word Size") then
			if string.find(line, "64%-bit") then
				self.isRunning64Bit = true
				infologFile:close()
				return true
			else
				self.isRunning64Bit = false
				infologFile:close()
				return false
			end
		end
		line = infologFile:read()
	end
	infologFile:close()
	return false
end

function Configuration:GetIsNotRunningNvidia()
	if self.isNotRunningNvidia ~= nil then
		return self.isNotRunningNvidia
	end
	if Platform then
		return Platform.gpuVendor ~= "Nvidia"
	end
	local infologFile, err = io.open("infolog.txt", "r")
	if not infologFile then
		Spring.Echo("Error opening infolog.txt", err)
		return false
	end
	local line = infologFile:read()
	while line do
		if string.find(line, "PostInit") then
			-- We are past the part of the infolog where NVIDIA would appear
			infologFile:close()
			self.isNotRunningNvidia = true
			return true
		end
		if string.find(line, "NVIDIA") then
			infologFile:close()
			self.isNotRunningNvidia = false
			return false
		end
		line = infologFile:read()
	end
	infologFile:close()
	self.isNotRunningNvidia = true
	return true
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
		Log.Error("Event: " .. tostring(event) .. ", listener cannot be nil")
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
	local args = {...}
	local n = select("#", ...)
	for i = 1, #eventListeners do
		local listener = eventListeners[i]
		xpcall(function() listener(listener, unpack(args, 1, n)) end,
			function(err) self:_PrintError(err) end )
	end
	return true
end

function Configuration:_PrintError(err)
	-- FIXME: cleanup more
	Log.Error(err)
	Log.Error(debug.traceback(err))
end

---------------------------------------------------------------------------------
-- 'Initialization'
---------------------------------------------------------------------------------
-- shadow the Configuration class with a singleton
Configuration = Configuration()
