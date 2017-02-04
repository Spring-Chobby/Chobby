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
	if not friendIDList then
		return
	end
	local lobby = WG.LibLobby.lobby
	for i = 1, #friendIDList do
		local userName = lobby:GetUserNameBySteamID(friendIDList[i])
		lobby:FriendRequest(userName)
	end
end

local function JoinFriend(friendID)
	if not friendID then
		return
	end
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
	local lobby = WG.LibLobby.lobby
	if listenersInitialized then
		return
	end
	listenersInitialized = true
	
	local function OnUsersSent()
		if storedFriendList then
			AddSteamFriends(storedFriendList)
			storedFriendList = nil
		end
		if storedJoinFriendID then
			JoinFriend(storedJoinFriendID)
			storedJoinFriendID = nil
		end
	end
	
	lobby:AddListener("OnFriendList", OnUsersSent) -- All users are present before FriendList is recieved.
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
	
	if storedFriendList then
		for i = 1, #storedFriendList do
			steamFriendByID[storedFriendList[i]] = true
		end
	end
	
	if lobby.status ~= "connected" then
		storedJoinFriendID = joinFriendID
		storedFriendList = friendList
		InitializeListeners()
		return
	end
	
	AddSteamFriends(storedFriendList)
	JoinFriend(joinFriendID) 
end

function SteamHandler.SteamJoinFriend(joinFriendID)
	local lobby = WG.LibLobby.lobby
	if not lobby then
		Spring.Echo("Loopback error: Sent steam before lobby initialization")
		return
	end
	
	if lobby.status ~= "connected" then
		storedJoinFriendID = joinFriendID
		InitializeListeners()
		return
	end
	JoinFriend(joinFriendID) 
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


function SteamHandler.SteamOverlayChanged(isActive) 
	Spring.Echo("OVERLAY CHANGE " .. isActive)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Initialization

function widget:Initialize() 
	WG.SteamHandler = SteamHandler
end
