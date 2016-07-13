Configuration = LCS.class{}

VFS.Include("libs/liblobby/lobby/json.lua")

-- all configuration attribute changes should use the :Set*Attribute*() and :Get*Attribute*() methods in order to assure proper functionality
function Configuration:init()
--     self.serverAddress = "localhost"
	self.serverAddress = WG.Server.serverAddress or "springrts.com"
	self.serverPort = 8200

	self.userName = ""
	self.password = ""
	self.autoLogin = false
	self.channels = {}
	
	self.promptNewUsersToLogIn = false

	self.errorColor = "\255\255\0\0"
	self.warningColor = "\255\255\255\0"
	self.successColor = "\255\0\255\0"
	self.partialColor = "\255\190\210\50"
	self.selectedColor = "\255\99\184\255"
	self.buttonFocusColor = {0.54,0.72,1,0.3}
	self.buttonSelectedColor = {0.54,0.72,1,0.6}--{1.0, 1.0, 1.0, 1.0}
	
	self.userListWidth = 200 -- Main user list width. Possibly configurable in the future.
	
	self.singleplayer_mode = 2
	
	self.font = {
		{size = 14, shadow = false},
		{size = 18, shadow = false},
		{size = 22, shadow = false},
		{size = 32, shadow = false},
		{size = 48, shadow = false},
	}
	
	self.game_settings = VFS.Include("luaui/configs/springsettings/springsettings3.lua")
end

function Configuration:GetFont(sizeScale)
	return {
		size = self.font[sizeScale].size,
		shadow = self.font[sizeScale].shadow,
	}
end

function Configuration:SetConfigData(data)
	if data ~= nil then
		for k, v in pairs(data) do
			self[k] = v
		end
	end
end

function Configuration:GetConfigData()
	return {
		userName = self.userName,
		password = self.password,
		autoLogin = self.autoLogin,
		channels = lobby:GetMyChannels(),	
		singleplayer_mode = self.singleplayer_mode,
		game_fullscreen = self.game_fullscreen,
		panel_layout = self.panel_layout,
		lobby_fullscreen = self.lobby_fullscreen,
		game_settings = self.game_settings,
	}
end

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
-- shadow the Configuration class with a singleton
Configuration = Configuration()
