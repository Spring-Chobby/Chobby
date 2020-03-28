--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Battle Proposal Handler",
		desc      = "Handles the battle proposal system.",
		author    = "GoogleFrog",
		date      = "28 March 2020",
		license   = "GNU LGPL, v2.1 or later",
		layer     = 0,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local parameterStr = {
	"minelo=",
	"maxelo=",
	"minsize=",
	"maxsize=",
}

for i = 1, #parameterStr do
	parameterStr[i] = {parameterStr[i], string.len(parameterStr[i])}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Variables

local currentProposal
local acceptedProposal

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External functions

local BattleProposalHandler = {}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function BattleProposalHandler.GetProposalFromString(message, onlyCheckExistence)
	if string.sub(message, 1, 1) ~= "!" or string.sub(message, 1, 14) ~= "!proposeBattle"then
		return false
	end
	
	if onlyCheckExistence then
		return true
	end
	
	local data = message:split(" ")
	local paramValues = {}
	for i = 1, #data do
		for j = 1, #parameterStr do
			if string.sub(data[i], 1, parameterStr[j][2]) == parameterStr[j][1] then
				local value = tonumber(string.sub(data[i], parameterStr[j][2] + 1))
				if value then
					paramValues[j] = value
				end
			end
		end
	end
	
	local proposalValues = {
		minelo = paramValues[1] or false,
		maxelo = paramValues[2] or false,
		minsize = paramValues[3] or 4,
	}
	proposalValues.maxsize = math.max(proposalValues.minsize, paramValues[4] or 8)
	
	return true, proposalValues
end

function BattleProposalHandler.CheckProposalSent(message)
	local hasProposal, newProposalValues = BattleProposalHandler.GetProposalFromString(message)
	if not hasProposal then
		return false
	end
	
	if currentProposal and newProposalValues.minelo == currentProposal.minelo
	                   and newProposalValues.maxelo == currentProposal.maxelo
	                   and newProposalValues.minsize == currentProposal.minsize
	                   and newProposalValues.maxsize == currentProposal.maxsize then
		return true
	end
	
	currentProposal = newProposalValues
	
	currentProposal.currentPlayers = 1
	currentProposal.acceptedPlayers = {}
	return true
end

function BattleProposalHandler.AcceptProposal(userName)
	acceptedProposal = userName
	lobby:BattleProposalRespond(userName, true)
end

function BattleProposalHandler.AddClickableInvites(userName, preMessage, message, onTextClick, textTooltip)
	local hasProposal, prop = BattleProposalHandler.GetProposalFromString(message)
	if not hasProposal then
		return false
	end
	if not (WG.LibLobby and WG.LibLobby.lobby) then
		return
	end
	
	local myProposal = (userName == WG.LibLobby.lobby:GetMyUserName())
	
	local myInfo = WG.LibLobby.lobby:GetMyInfo()
	local effectiveSkill = math.max(myInfo.skill or 1500, myInfo.casualSkill or 1500)
	local skillTooLow = (prop.minelo and effectiveSkill < prop.minelo)
	local skillTooHigh = (prop.maxelo and effectiveSkill > prop.maxelo)
	
	local startIndex = string.len(preMessage)
	local endIndex = startIndex + string.len(message) + 1
	
	if not (skillTooLow or skillTooLow) then
		onTextClick[#onTextClick + 1] = {
			startIndex = startIndex,
			endIndex = endIndex,
			OnTextClick = {
				function()
					if WG.LibLobby and WG.LibLobby.lobby then
						WG.LibLobby.lobby:BattleProposalRespond(userName, true)
					end
				end
			}
		}
	end
	
	local proposalString
	if skillTooLow then
		proposalString = "Your skill rating is too low for this proposal."
	elseif skillTooHigh then
		proposalString = "Your skill rating is too high for this proposal."
	else
		if myProposal then
			proposalString = "This is your battle proposal.\nOther players may click it to accept."
		else
			proposalString = "Click to accept " .. userName .. "'s battle"
		end
		if prop.minelo then
			proposalString = proposalString .. "\nMin rating: " .. prop.minelo
		end
		if prop.maxelo then
			proposalString = proposalString .. "\nMax rating: " .. prop.maxelo
		end
		proposalString = proposalString .. "\nA battle will open when " .. prop.minsize .. " players accept."
	end
	
	textTooltip[#textTooltip + 1] = {
		startIndex = startIndex,
		endIndex = endIndex,
		tooltip = proposalString,
	}

	return onTextClick, textTooltip
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

function DelayedInitialize()
	local lobby = WG.LibLobby.lobby

	local function OnBattleProposalResponse(listener, userName, accepted)
		if (not accepted) then
			return
		end
		if (not currentProposal) or currentProposal.acceptedPlayers[userName] then
			return
		end
		local user = lobby:GetUser(userName)
		if (not user) or (userName == lobby:GetMyUserName())then
			return
		end
		local effectiveSkill = math.max(user.skill or 1500, user.casualSkill or 1500)
		if (currentProposal.minelo and effectiveSkill < currentProposal.minelo) or (currentProposal.maxelo and effectiveSkill > currentProposal.maxelo) then
			return
		end
		
		currentProposal.currentPlayers = currentProposal.currentPlayers + 1
		currentProposal.acceptedPlayers[userName] = true
		
		if currentProposal.currentPlayers >= currentProposal.minsize and not currentProposal.openingBattleName then
			-- Check for users leaving
			for acceptedUserName, _ in pairs(currentProposal.acceptedPlayers) do
				local currentUser = lobby:GetUser(userName)
				if (not currentUser) or currentUser.isOffline then
					currentProposal.acceptedPlayers[acceptedUserName] = nil
					currentProposal.currentPlayers = currentProposal.currentPlayers - 1
				end
			end
			
			-- Host the battle
			if currentProposal.currentPlayers >= currentProposal.minsize then
				currentProposal.password = math.floor(math.random()*100000)
				currentProposal.openingBattleName = (lobby:GetMyUserName() or "Player") .. "'s Proposed Battle"
				lobby:HostBattle(currentProposal.openingBattleName, currentProposal.password, "Team")
			end
		end
	end

	local function OnJoinedBattle(listener, battleID, hashCode)
		if not (currentProposal and currentProposal.openingBattleName) then
			return
		end
		local battleInfo = lobby:GetBattle(battleID)
		if battleInfo.title ~= currentProposal.openingBattleName then
			return
		end
		
		for acceptedUserName, _ in pairs(currentProposal.acceptedPlayers) do
			lobby:BattleProposalBattleInvite(acceptedUserName, battleID, currentProposal.password)
		end
		currentProposal = nil
	end

	local function OnBattleProposalBattleInvite(listener, userName, battleID, password)
		if acceptedProposal ~= userName then
			return
		end
		lobby:JoinBattle(battleID, password)
		acceptedProposal = false
	end
	
	lobby:AddListener("OnBattleProposalResponse", OnBattleProposalResponse)
	lobby:AddListener("OnJoinedBattle", OnJoinedBattle)
	lobby:AddListener("OnBattleProposalBattleInvite", OnBattleProposalBattleInvite)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:Initialize()
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)

	WG.BattleProposalHandler = BattleProposalHandler
	WG.Delay(DelayedInitialize, 1)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
