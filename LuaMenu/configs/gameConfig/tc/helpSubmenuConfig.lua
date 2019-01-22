--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Utilities

local function CreateLine(lineText, linkText, onClick)
	local Configuration = WG.Chobby.Configuration

	local lineHolder = Control:New {
		x = 0,
		y = 0,
		width = "100%",
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
	}

	if onClick then
		local linkButton = Button:New {
			x = 3,
			y = 3,
			height = 34,
			width = 95,
			caption = linkText,
			classname = "action_button",
			font = WG.Chobby.Configuration:GetFont(2),
			OnClick = {
				onClick
			},
			parent = lineHolder,
		}
	end

	local text = TextBox:New {
		name = "text",
		x = 110,
		y = 12,
		right = 0,
		height = 20,
		valign = 'center',
		fontsize = Configuration:GetFont(2).size,
		text = lineText,
		parent = lineHolder,
	}

	return lineHolder
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Community Links

local communityLines = {
	{
		"Site home page.",
		"Home",
		function ()
			WG.BrowserHandler.OpenUrl("http://www.cursed.one")
		end
	},
	{
		"Community forums.",
		"Forums",
		function ()
			WG.BrowserHandler.OpenUrl("https://springrts.com/phpbb/viewforum.php?f=54")
		end
	},
	{
		"Discord chat server.",
		"Discord",
		function ()
			WG.BrowserHandler.OpenUrl("https://discord.gg/6FGe3NJ")
		end
	},
	{
		"Youtube channel.",
		"Youtube",
		function ()
			WG.BrowserHandler.OpenUrl("https://www.youtube.com/user/azaremoth")
		end
	},
	{
		"Hall of Fame",
		"Ladder",
		function ()
			WG.BrowserHandler.OpenUrl("http://replays.springrts.com/hall_of_fame/TC/")
		end
	},
	{
		"Browse and download maps.",
		"Maps",
		function ()
			WG.BrowserHandler.OpenUrl("https://springfiles.com/spring/spring-maps")
		end
	},
	{
		"Browse and download replays.",
		"Replays",
		function ()
			WG.BrowserHandler.OpenUrl("http://replays.springrts.com/?game_pref=24")
		end
	},
}

local firstCommunityParent = true
local communityControl = Control:New {
	x = 0,
	y = 0,
	right = 0,
	bottom = 0,
	padding = {12, 12, 15, 15},
	OnParent = {
		function (obj)
			if not firstCommunityParent then
				return
			end
			firstCommunityParent = false

			local list = SortableList(obj)

			local items = {}
			for i = 1, #communityLines do
				local data = communityLines[i]
				items[#items + 1] = {#items, CreateLine(data[1], data[2], data[3])}
			end

			list:AddItems(items)
		end
	},
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Bug Reporting

local bugLines = {
	{
		textFunction = function ()
			return "Using engine " .. Spring.Utilities.GetEngineVersion() .. " " .. ((WG.Chobby.Configuration:GetIsRunning64Bit() and "64-bit.") or "32-bit.")
		end,
	},
--[[	{
		"Open game data folder to find settings, infolog etc...",
		"Local Data",
		function ()
			WG.WrapperLoopback.OpenFolder()
		end
	}, ]]--
	{
		"A useful site for uploading infologs.",
		"Pastebin",
		function ()
			WG.BrowserHandler.OpenUrl("https://www.pastebin.com")
		end
	},
	{
		"Report the bug on the forum.",
		"Forum",
		function ()
			WG.BrowserHandler.OpenUrl("https://springrts.com/phpbb/viewforum.php?f=54")
		end
	},
	{
		"Report an in-game bug on GitHub. This requires a GitHub account.",
		"Game Bug",
		function ()
			WG.BrowserHandler.OpenUrl("https://github.com/azaremoth/cursed/issues")
		end
	},
}

--[[if VFS.HasArchive("The Cursed $VERSION") then
	bugLines[#bugLines + 1] = {
		"Run a benchmark game.",
		"Benchmark",
		function ()
			local localLobby = WG.LibLobby and WG.LibLobby.localLobby
			if localLobby then
				localLobby:StartGameFromString(VFS.Include(LUA_DIRNAME .. "configs/gameConfig/tc/benchmarkFile.lua"))
			end
		end
	}
end]]--

local firstBugParent = true
local bugControl = Control:New {
	x = 0,
	y = 0,
	right = 0,
	bottom = 0,
	padding = {12, 12, 15, 15},
	OnParent = {
		function (obj)
			if not firstBugParent then
				return
			end
			firstBugParent = false

			local list = SortableList(obj, nil, 70)

			local items = {}
			for i = 1, #bugLines do
				local data = bugLines[i]
				items[#items + 1] = {#items, CreateLine(data[1] or data.textFunction(), data[2], data[3])}
			end

			list:AddItems(items)
		end
	},
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Structure

return {
	{
		name = "links",
		control = communityControl,
	},
--	{
--		name = "tutorials", 
--		control = WG.MissionHandler.GetControl(),
--	},
	{
		name = "report_a_bug",
		control = bugControl,
	},
}
