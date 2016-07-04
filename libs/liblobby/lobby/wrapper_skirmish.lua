WrapperSkirmish = Observable:extends()

function WrapperSkirmish:init(myUserName)
	self.listeners = {}
	-- don't use these fields directly, they are subject to change
	self:_Clean()
end

function WrapperSkirmish:_Clean()
	self.battle = {}
	self.battleID = nil
	
	self.loginData = nil
	self.myUserName = nil
	self.scriptPassword = nil
	
	self.AllyNumber = nil
	self.TeamNumber = nil
	self.IsSpectator = nil
	self.Sync = nil
end

------------------------------------------------------------------------
-- Listeners
------------------------------------------------------------------------
function WrapperSkirmish:_OnUpdateBattleInfo(spectatorCount, locked, mapHash, mapName)
	self.battle.spectatorCount = spectatorCount or self.battle.spectatorCount
	self.battle.locked = locked or self.battle.locked
	self.battle.mapHash = mapHash or self.battle.mapHash
	self.battle.mapName = mapName or self.battle.mapName
	self:_CallListeners("OnUpdateBattleInfo", self:GetMyBattleID(), spectatorCount, locked, mapHash, mapName)
end

function WrapperSkirmish:_OnLeftBattle()
	self:_CallListeners("OnLeftBattle", self:GetMyBattleID(), self:GetMyUserName())
end

function WrapperSkirmish:_OnJoinedBattle()
	self:_CallListeners("OnJoinedBattle", self:GetMyBattleID(), self:GetMyUserName())
end

function WrapperSkirmish:_UpdateUserBattleStatus(data)
	if data.Name then
		self.AllyNumber = data.AllyNumber or self.AllyNumber
		self.TeamNumber = data.TeamNumber or self.TeamNumber
		if data.IsSpectator ~= nil then
			self.IsSpectator = data.IsSpectator
		end
		self.Sync = data.Sync or self.Sync
		
		data.AllyNumber = self.AllyNumber
		data.TeamNumber = self.TeamNumber
		data.IsSpectator = self.IsSpectator
		data.Sync = self.Sync
	end
	self:_CallListeners("UpdateUserBattleStatus", data)
end

function WrapperSkirmish:_RemoveBot(data)
	self:_CallListeners("RemoveBot", data)
end

function WrapperSkirmish:_OnSaidBattle(userName, message)
	self:_CallListeners("OnSaidBattle", userName, message)
end

function WrapperSkirmish:_OnSaidBattleEx(userName, message)
	self:_CallListeners("OnSaidBattleEx", userName, message)
end

function WrapperSkirmish:_OnBattleClosed()
	self:_CallListeners("OnBattleClosed", self:GetMyBattleID())
end

------------------------------------------------------------------------
-- Getters
------------------------------------------------------------------------
function WrapperSkirmish:GetMyBattleID()
	return self.battleID
end

function WrapperSkirmish:GetMyUserName()
	return self.myUserName
end

function WrapperSkirmish:GetBattle()
	return self.battle
end

function WrapperSkirmish:GetMyIsSpectator()	
	return self.IsSpectator
end

------------------------------------------------------------------------
-- Setters
------------------------------------------------------------------------
function WrapperSkirmish:StartBattle()
	self:_OnSaidBattleEx("Battle", "about to start (not really, needs implementation).")
	Spring.Echo("Implement start battle")
	return self
end

function WrapperSkirmish:SayBattle(message)
	self:_OnSaidBattle(self:GetMyUserName(), message)
	return self
end

function WrapperSkirmish:SetBattleStatus(battleData)
	battleData.Name = self:GetMyUserName()
	self:_UpdateUserBattleStatus(battleData)
	return self
end

function WrapperSkirmish:LeaveBattle()
	self:_OnLeftBattle()
	self:_OnBattleClosed()
	return self
end

function WrapperSkirmish:SetBattleState(myUserName, gameName, mapName, battleName)
	self.myUserName = myUserName
	self.battle.gameName = gameName
	self.battle.mapName = mapName
	self.battle.users = {myUserName}
	self.battle.title = battleName
	self.battleID = 1
	return self
end

return WrapperSkirmish
