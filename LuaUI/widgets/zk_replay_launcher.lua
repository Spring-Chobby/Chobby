
if not (Spring.GetConfigInt("LuaSocketEnabled", 0) == 1) then
	Spring.Echo("LuaSocketEnabled is disabled")
	return false
end

function widget:GetInfo()
return {
	name    = "ZK replay downloader",
	desc    = "Downloads and launches ZK replays",
	author  = "Anarchid, abma (http demo)",
	date    = "July 2016",
	license = "GNU GPL, v2 or later",
	layer   = 0,
	enabled = true,
}
end

local socket = socket

local client
local set
local headersent

local host = "zero-k.info"
local port = 80
local path = "/replays/20160704_190323_Drab_100.sdf"
local file = "20160704_190323_Drab_100.sdf";
local replaydata = "";

local downloads = {};
local url;

local hasMap = false;
local hasEngine = false;
local hasGame = false;

local function dumpConfig()
	-- dump all luasocket related config settings to console
	for _, conf in ipairs({"TCPAllowConnect", "TCPAllowListen", "UDPAllowConnect", "UDPAllowListen"  }) do
		Spring.Echo(conf .. " = " .. Spring.GetConfigString(conf, ""))
	end
end

local function newset()
    local reverse = {}
    local set = {}
    return setmetatable(set, {__index = {
        insert = function(set, value)
            if not reverse[value] then
                table.insert(set, value)
                reverse[value] = table.getn(set)
            end
        end,
        remove = function(set, value)
            local index = reverse[value]
            if index then
                reverse[value] = nil
                local top = table.remove(set)
                if top ~= value then
                    reverse[top] = index
                    set[index] = top
                end
            end
        end
    }})
end


-- initiates a connection to host:port, returns true on success
local function SocketConnect(host, port)
	client=socket.tcp()
	client:settimeout(0)
	res, err = client:connect(host, port)
	if not res and not res=="timeout" then
		Spring.Echo("Error in connect: "..err)
		return false
	end
	set = newset()
	set:insert(client)
	return true
end

function widget:Initialize()
	CHOBBY_DIR = "LuaUI/widgets/chobby/"
	VFS.Include("LuaUI/widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)
	url = VFS.Include("libs/neturl/url.lua");
	lobby:AddListener("OnLaunchRemoteReplay", onLaunchReplay)
end

function onLaunchReplay(wtf, replay, game, map, engine)
	Spring.Echo("LAUNCHING REPLAY")
	Spring.Echo("url: ".. replay)
	Spring.Echo("game: ".. game)
	Spring.Echo('map: '.. map)
	Spring.Echo('engine: '.. engine)

	if(VFS.HasArchive(game)) then
		hasGame = true;
	else
		Spring.Echo("need to download game");
	end

	if(VFS.HasArchive(map)) then
		hasMap = true;
	else
		Spring.Echo("need to download map");
	end

	hasEngine = true 
	-- somehow check for engine? or check if current = required, and use that

	local parsed = url.parse(replay);
	host = parsed.host;
	path = parsed.path;
	file = path:match("([^/]*)$");

	replaydata = "";

	Spring.Echo("Download file "..path.." from host "..host.." into demos/"..file);

	-- if needed stuff available: download replay, launch game
	-- otherwise: start downloads (socket/VFS) and watch for completion of all (ghetto async)
	SocketConnect(host, port);
end

-- called when data was received through a connection
local function SocketDataReceived(sock, str)
	replaydata = replaydata .. str;
end

local headersent
-- called when data can be written to a socket
local function SocketWriteAble(sock)
	if headersent==nil then
		-- socket is writeable
		headersent=1
		Spring.Echo("sending http request")
		sock:send("GET " .. path .. " HTTP/1.0\r\nHost: " .. host ..  " \r\n\r\n")
	end
end

-- called when a connection is closed
local function SocketClosed(sock)
	Spring.Echo("closed connection");
	local saveFilename = 'demos/'..file;
    
    local body_start = replaydata:find("\r\n\r\n", 1, true) + 4
    local f = assert(io.open(saveFilename, 'wb')) -- open in "binary" mode
    f:write(replaydata:sub(body_start));
    f:close()
	replaydata = "";
    Spring.Echo("saved replay file, launching game");
	Spring.Start(saveFilename, "");
end

function widget:Update()
	if set==nil or #set<=0 then
		return
	end
	-- get sockets ready for read
	local readable, writeable, err = socket.select(set, set, 0)
	if err~=nil then
		-- some error happened in select
		if err=="timeout" then
			-- nothing to do, return
			return
		end
		Spring.Echo("Error in select: " .. error)
	end
	for _, input in ipairs(readable) do
		local s, status, partial = input:receive('*a') --try to read all data
		if status == "timeout" or status == nil then
			SocketDataReceived(input, s or partial)
		elseif status == "closed" then
			SocketClosed(input)
			input:close()
			set:remove(input)
		end
	end
	for __, output in ipairs(writeable) do
		SocketWriteAble(output)
	end
end
