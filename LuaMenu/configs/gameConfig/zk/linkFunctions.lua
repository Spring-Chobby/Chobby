local function link_reportPlayer(accountID) 
	return "http://zero-k.info/Users/ReportToAdmin/" .. accountID
end

local function link_userPage(accountID) 
	return "http://zero-k.info/Users/Detail/" .. accountID
end

local function link_homePage() 
	return "http://zero-k.info/"
end

local function link_replays() 
	return "http://zero-k.info/Battles"
end

local function link_maps() 
	return "http://zero-k.info/Maps"
end

local function link_particularMapPage(mapName)
	return "http://zero-k.info/Maps/DetailName?name=" .. mapName
end

return link_reportPlayer, link_userPage, link_homePage, link_replays, link_maps, link_particularMapPage