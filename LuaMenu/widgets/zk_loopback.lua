LIB_LOBBY_DIRNAME = "libs/liblobby/lobby/" -- why is this needed? why doesnt api load first?

VFS.Include(LIB_LOBBY_DIRNAME .. "json.lua")
VFS.Include(LIB_LOBBY_DIRNAME .. "utilities.lua")

function widget:GetInfo()
return {
	name    = "ZK wrapper loopback interface",
	desc    = "Creates a commlink between wrapper and chobby",
	author  = "Licho",
	date    = "too late man",
	license = "GNU GPL, v2 or later",
	layer   = -10010,
	enabled = true,
}
end

local socket = socket
local client
local buffer = ""
local commands = {} -- table with possible commands

-- debug message/popup
local function Echo(stuff)
	Chotify:Post({
		title = "Wrapper",
		body = stuff,
	})
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Connectivity and sending

-- sends command to wrapper
function SendCommand(cmdName, args) 
	if (args == nil) then
		client:send(cmdName .. " {}\n")
	else
		client:send(cmdName .. " " ..json.encode(args).."\n")
	end
end

local function SocketConnect(host, port)
	client=socket.tcp()
	client:settimeout(0)
	res, err = client:connect(host, port)
	if not res and not res=="timeout" then
		Echo("Error in connect wrapper: "..err)
		return false
	end
	return true
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Callin Functions

-- Use listener interface from configuration when implementing this
--function Example(args)
--	Echo(args.Message)
--end

--commands["Example"] = Example

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Callout Functions

local WrapperLoopback = {}

-- opens URL
function WrapperLoopback.OpenUrl(url) 
	Spring.Echo("Opening URL", url)
	SendCommand("OpenUrl", {Url = url})
end

-- opens folder
function WrapperLoopback.OpenFolder(folder) 
	SendCommand("OpenFolder", {Folder = folder})
end

-- restart chobby
function WrapperLoopback.Restart() 
	SendCommand("Restart", nil)
end

-- notifies user/flashes spring window (message ignored atm)
function WrapperLoopback.Alert(message)
	SendCommand("Alert", {Message= message})
end

-- sets TTS volume
function WrapperLoopback.TtsVolume(volume) 
	SendCommand("TtsVolume", {Volume = volume})
end

-- speaks using TTS, send name of speaker for alternating speaker voices
function WrapperLoopback.TtsSay(name, text) 
	SendCommand("TtsSay", {Name = name, Text = text})
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

-- init
function widget:Initialize()
	if true then
		widgetHandler:RemoveWidget()
		return
	end
	CHOBBY_DIR = LUA_DIRNAME .. "widgets/chobby/"
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)
	
    local port = VFS.LoadFile("chobby_wrapper_port.txt"); -- get wrapper port from VFS file
	if not port then
		widgetHandler:RemoveWidget()
		Spring.Log("Chobby", LOG.NOTICE, "No port support, chobby_wrapper_port.txt not found.")
		return
	end
    Spring.Log("Chobby", LOG.NOTICE, "Using wrapper port: ", port)
    SocketConnect("127.0.0.1", port)
	
	WG.WrapperLoopback = WrapperLoopback
end

-- pocesses raw string line and executes command
local function CommandReceived(command) 
	i = command:find(" ")
	if i ~= nil then
		cmdName = command:sub(1, i - 1)
		arguments = command:sub(i + 1)
	else
		cmdName = command
	end

	local commandFunc = commands[cmdName]
	if commandFunc ~= nil then
		local success, obj = pcall(json.decode, arguments)
		if not success then
			Spring.Log(LOG_SECTION, LOG.ERROR, "Failed to parse JSON: " .. tostring(arguments))
		else 
			commandFunc(obj)
		end
	else
		Spring.Log(LOG_SECTION, LOG.ERROR, "No such function: " .. cmdName .. ", for command: " .. command)
	end
end

-- update socket - receive data and split into lines
function widget:Update()
	local readable, writeable, err = socket.select({client}, {client}, 0)
	if err ~= nil then
		Spring.Echo("Loopback error in select", err)
		--Echo("Error in select: " .. err)
	end
	for _, input in ipairs(readable) do
		local s, status, str = input:receive('*a') --try to read all data
		if (status == "timeout" or status == nil) and str ~= nil and str ~= "" then
			local commands = explode("\n", str)
			commands[1] = buffer .. commands[1]
			for i = 1, #commands-1 do
				local command = commands[i]
				if command ~= nil then
					CommandReceived(command)
				end
			end
			buffer = commands[#commands]

		elseif status == "closed" then
			input:close()
		end
	end
end
