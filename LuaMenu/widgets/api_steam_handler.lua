--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function widget:GetInfo()
	return {
		name      = "Steam Handler",
		desc      = "Handles steam connection, friends etc..",
		author    = "GoogleFrog",
		date      = "4 February 2017",
		license   = "GPL-v2",
		layer     = 0,
		handler   = true,
		enabled   = true,
	}
end

local storedFriendList
local storedJoinFriendID

local steamFriendByID = {}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Utilities

local function AddSteamFriends(friendIDList)
	local lobby = WG.LibLobby.lobby
	for i = 1, #friendIDList do
		local userName = lobby:GetUserNameBySteamID(friendIDList[i])
		lobby:FriendRequest(userName)
	end
end

local function JoinFriend(friendID)
	local lobby = WG.LibLobby.lobby
	local userName = lobby:GetUserNameBySteamID(friendID)
	lobby:InviteToParty(userName)
	
	local userInfo = lobby:GetUser(userName) or {}
	if userInfo.battleID then
		WG.Chobby.interfaceRoot.TryToJoinBattle(userInfo.battleID)
	end
end

local listenersInitialized = false
local function InitializeListeners()
	if listenersInitialized then
		return
	end
	listenersInitialized = true
	
	local function OnUsersSent()
		if storedFriendList then
			AddSteamFriends(storedFriendList)
		end
		if storedJoinFriendID then
			JoinFriend(storedJoinFriendID)
		end
	end
	
	lobby:AddListener("OnQueueOpened", OnUsersSent)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Externals Functions

local SteamHandler = {}

function SteamHandler.SteamOnline(authToken, joinFriendID, friendList)
	local lobby = WG.LibLobby.lobby
	if not lobby then
		Spring.Echo("Loopback error: Sent steam before lobby initialization")
		return
	end
	
	if authToken then
		lobby:SetSteamAuthToken(authToken)
	end
	
	for i = 1, #storedFriendList do
		steamFriendByID[storedFriendList[i]] = true
	end
	
	if lobby.status ~= "connected" then
		storedJoinFriendID = joinFriendID
		storedFriendList = friendList
		return
	end
	
	AddSteamFriends(storedFriendList)
	JoinFriend(joinFriendID) 
	
	InitializeListeners()
end

function SteamHandler.SteamJoinfriend(joinFriendID)
	local lobby = WG.LibLobby.lobby
	if not lobby then
		Spring.Echo("Loopback error: Sent steam before lobby initialization")
		return
	end
	
	if lobby.status ~= "connected" then
		storedJoinFriendID = joinFriendID
		return
	end
	JoinFriend(joinFriendID) 
	
	InitializeListeners()
end

function SteamHandler.InviteUserViaSteam(userName, steamID)
	if not steamID then
		local lobby = WG.LibLobby.lobby
		steamID = lobby:GetUser(userName).steamID
	end
	if steamID then
		WG.WrapperLoopback.SteamInviteFriendToGame(steamID)
	end
end

function SteamHandler.GetIsSteamFriend(steamID)
	return steamID and steamFriendByID[steamID]
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Initialization

function widget:Initialize() 
	WG.SteamHandler = SteamHandler
end
