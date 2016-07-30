
if not (Spring.GetConfigInt("LuaSocketEnabled", 0) == 1) then
	Echo("LuaSocketEnabled is disabled")
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
local saveFilename = "";
local replayMap = "";
local replayGame = "";

local downloads = {};
local url;

local hasMap = false;
local hasEngine = false;
local hasGame = false;
local hasFile = false;

local downloads = {
	map = false,
	game = false
}

local function dumpConfig()
	-- dump all luasocket related config settings to console
	for _, conf in ipairs({"TCPAllowConnect", "TCPAllowListen", "UDPAllowConnect", "UDPAllowListen"  }) do
		Echo(conf .. " = " .. Spring.GetConfigString(conf, ""))
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

local function Echo(stuff)
	Spring.Echo("<ZKReplayLauncher> "..stuff);
end


-- initiates a connection to host:port, returns true on success
local function SocketConnect(host, port)
	client=socket.tcp()
	client:settimeout(0)
	res, err = client:connect(host, port)
	if not res and not res=="timeout" then
		Echo("Error in connect: "..err)
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
	Echo("LAUNCHING REPLAY")
	Echo("url: ".. replay)
	Echo("game: ".. game)
	Echo('map: '.. map)
	Echo('engine: '.. engine)

	hasGame = false;
	hasMap = false;
	hasEngine = false;
	hasFile = false;

	hasEngine = engine:find(Game.version) == 1
	
	if not hasEngine then
		Echo("Replay engine "..engine.." incompatible with current engine "..Game.version);
	end

	replayMap = map;
	replayGame = game;

	if(VFS.HasArchive(game)) then
		hasGame = true;
	else
		Echo("Downloading game...");
		VFS.DownloadArchive(game, "game")
	end

	if(VFS.HasArchive(map)) then
		hasMap = true;
	else
		Echo("Downloading map...");
		VFS.DownloadArchive(map, "map");
	end


 
	-- somehow check for engine? or check if current = required, and use that

	local parsed = url.parse(replay);
	local localpath = parsed.path;

	host = parsed.host;
	file = localpath:match("([^/]*)$");
	path = localpath:gsub(" ","%%20");

	replaydata = "";

	Echo("Download file "..path.." from host "..host.." into demos/"..file);

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
		Echo("sending http request".." GET " .. path .. " HTTP/1.0\r\nHost: " .. host ..  " \r\n\r\n")
		sock:send("GET " .. path .. " HTTP/1.0\r\nHost: " .. host ..  " \r\n\r\n")
	end
end

local function AttemptStart()
	Echo("Checking if ready to start");

	if not hasFile then
		return Echo("Weird attempt to start without demofile")
	end

	if not hasMap then
		return Echo("Map not downloaded yet")
	end

	if not hasGame then
		return Echo("Game not downloaded yet");
	end

	Echo("LAUNCH GAME FINAELLYY!!!");

	Spring.Start(saveFilename, "");
end


-- called when a connection is closed
local function SocketClosed(sock)
	Echo("closed connection");
    local body_start = replaydata:find("\r\n\r\n", 1, true);

	if not body_start then
		Echo("Unable to find http body -- connection fail? Dumping response.");
		Echo(replaydata)
		return;
	end

	body_start = body_start + 4;

	local headers = replaydata:sub(1,body_start-1);
	if headers:find("200 OK") then
		saveFilename = 'demos/'..file;
		local f = assert(io.open(saveFilename, 'wb')) -- open in "binary" mode
		f:write(replaydata:sub(body_start));
		f:close()
		replaydata = "";
		Echo("Saved replay file");
		hasFile = true;
		AttemptStart();
	else
		Echo("Unable to download file. Response headers: ")
		Echo(headers);
	end
end

function widget:DownloadQueued(downloadID, archiveName, archiveType)
	Echo("Download "..downloadID.." queued")
	Echo("name = "..archiveName..", type = "..archiveType)
	if (archiveName == replayMap and archiveType == "map") then
		Echo("Queued map donwload");
		downloads.map = downloadID;
	end

	if (archiveName == replayGame and archiveType == "game") then
		Echo("Queued game download");
		downloads["game"] = downloadID;
	end
end

function widget:DownloadFinished(downloadID)
	Echo("Download "..downloadID.." finished")
	if(downloads.map == downloadID) then
		hasMap = true;
		Echo("Map downloaded");
		AttemptStart();
	end

	if(downloads.game == downloadID) then
		hasGame = true;
		Echo("Game downloaded");
		AttemptStart();
	end
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
		Echo("Error in select: " .. error)
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
