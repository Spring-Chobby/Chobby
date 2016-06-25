Configuration = LCS.class{}

VFS.Include("libs/liblobby/lobby/json.lua")

-- all configuration attribute changes should use the :Set*Attribute*() and :Get*Attribute*() methods in order to assure proper functionality
function Configuration:init()
    self.scale = 1.2
    --self.serverAddress = "localhost"
    self.serverAddress = (ZEROK_SERVER and "zero-k.info") or "springrts.com"
    self.serverPort = 8200

    self.userName = ""
    self.password = ""
    self.autoLogin = false

    self.errorColor = "\255\255\0\0"
    self.warningColor = "\255\255\255\0"
    self.successColor = "\255\0\255\0"
    self.selectedColor = "\255\99\184\255"
    self.buttonFocusColor = {0.54,0.72,1,0.3}
    self.buttonSelectedColor = {0.54,0.72,1,0.6}--{1.0, 1.0, 1.0, 1.0}

    self.configFile = ".chobby/config.json"
    self:LoadConfig()
end

function Configuration:LoadConfig()
    if VFS.FileExists(self.configFile, VFS.RAW) then
        local config = json.decode(VFS.LoadFile(self.configFile))
        for k, v in pairs(config) do
            self[k] = v
        end
    end
end

function Configuration:SaveConfig()
    local out = {}
    out = {
        userName = self.userName,
        password = self.password,
        autoLogin = self.autoLogin,
    }
    Spring.CreateDir(".chobby")
    local f = io.open(self.configFile, "w")
    f:write(json.encode(out))
    f:close()
end

function Configuration:SetScale(scale)
    self.scale = scale
end

function Configuration:GetScale()
    return self.scale
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

-- shadow the Configuration class with a singleton
Configuration = Configuration()
