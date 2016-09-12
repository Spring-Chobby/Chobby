local RANK_DIR = LUA_DIRNAME .. "configs/gameConfig/zk/rankImages/"
local IMAGE_DIR          = LUA_DIRNAME .. "images/"

local IMAGE_AUTOHOST     = IMAGE_DIR .. "ranks/robot.png"
local IMAGE_PLAYER       = IMAGE_DIR .. "ranks/player.png"
local IMAGE_MODERATOR    = IMAGE_DIR .. "ranks/moderator.png"

local function GetImageFunction(level, skill, isBot, isModerator)
	if isBot then
		return IMAGE_AUTOHOST
	elseif isModerator then
		return IMAGE_MODERATOR
	elseif level and skill then
		local levelBracket = math.max(0, math.min(7, math.floor(level/10)))
		
		local skillBracket = math.max(0, math.min(7, math.floor((skill-1000)/200)))
		
		return RANK_DIR .. levelBracket .. "_" .. skillBracket .. ".png"
	end
	return IMAGE_PLAYER
end

return GetImageFunction