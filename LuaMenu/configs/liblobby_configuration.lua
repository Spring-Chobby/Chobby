local CONFIG_FILE = "chobby_config.json"

local function LoadConfig(filePath)
	if not json then
		VFS.Include(LIB_LOBBY_DIRNAME .. "json.lua")
	end
	if not VFS.FileExists(CONFIG_FILE) then
		Spring.Log("liblobby", LOG.WARNING, "Missing chobby_config.json file.")
	end
	local config
	xpcall(function()
		config = json.decode(VFS.LoadFile(filePath))
	end, function(err)
		Spring.Log("liblobby", LOG.ERROR, err)
		Spring.Log("liblobby", LOG.ERROR, debug.traceback(err))
	end)
	return config
end

local function GetFallback()
return {
		-- FIXME: Temporary until ZK's wrapper implements the above config file
	server = {
			address = "zero-k.info",
			port = 8200,
			serverName = "Zero-K",
			protocol = "zks"
	}
		-- Will be replaced with these lines
		-- server = {
		-- 	address = "springrts.com",
		-- 	port = 8200,
		-- 	serverName = "Spring",
		-- 	protocol = "spring"
		-- }
}
end

local config = LoadConfig(CONFIG_FILE)
if not config then
	config = GetFallback()
end
return config
