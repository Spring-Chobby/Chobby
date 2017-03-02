local RANK_DIR = LUA_DIRNAME .. "configs/gameConfig/zk/rankImages/"
local IMAGE_DIR          = LUA_DIRNAME .. "images/"
local IMAGE_AUTOHOST     = IMAGE_DIR .. "ranks/robot.png"
local IMAGE_PLAYER       = IMAGE_DIR .. "ranks/player.png"


local function GetImageFunction(icon, isBot)
	if isBot then
		return IMAGE_AUTOHOST
	elseif icon then
		return RANK_DIR .. icon .. ".png"
	end
	return oldImage or IMAGE_PLAYER
end

return GetImageFunction
