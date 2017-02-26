--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Codex Handler",
		desc      = "Knowledge is power. Guard it well",
		author    = "GoogleFrog, KingRaptor",
		date      = "24 November 2016",
		license   = "GNU LGPL, v2.1 or later",
		layer     = -100000,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Local Variables

local CODEX_BUTTON_FONT_SIZE = 14
local OUTLINE_COLOR = {0.54,0.72,1,0.3}
local IMAGE_SIZE = 96
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Utilities

-- TODO
local function IsCodexEntryVisible(id)
	return true
end

local function SortCodexEntries(a, b)
	if (not entryA) or (not entryB) then
		return false
	end
	local aKey = entryA.sortkey or entryA.name
	local bKey = entryB.sortkey or entryB.name
	aKey = string.lower(aKey)
	bKey = string.lower(bKey)
	return aKey < bKey
end

local function LoadCodexEntries(path)
	local codexEntries = WG.CampaignAPI.GetCodexEntries()
	
	local categories = {}
	local categoriesOrdered = {}
	for id, entry in pairs(codexEntries) do
		if IsCodexEntryVisible(id) then
			categories[entry.category] = categories[entry.category] or {}
			local cat = categories[entry.category]
			cat[#cat + 1] = entry
		end
	end
	
	-- sort categories
	for catID in pairs(categories) do
		categoriesOrdered[#categoriesOrdered + 1] = catID
	end
	table.sort(categoriesOrdered)
	return codexEntries, categories, categoriesOrdered
end

local function UpdateCodexEntry(entry, codexText, codexImage)
	-- TODO reimplement coloration for specific entries' read/unread state
	--[[
	if not gamedata.codexRead[entryID] then
		if codexTreeControls[entryID] then
			local button = codexTreeControls[entryID]
			--button.font.outline = false
			button.font.shadow = false
			--button.font.size = CODEX_BUTTON_FONT_SIZE
			button:Invalidate()
		end
	end
	]]
	WG.CampaignAPI.MarkCodexEntryRead(entry.id)
	codexText:SetText(entry.text)
	codexImage.file = entry.image
	codexImage:Invalidate()
end

local function PopulateCodexTree(parent, codexText, codexImage)
	local nodes = {}
	local codexEntries, categories, categoriesOrdered = LoadCodexEntries()
	
	-- make tree view nodes
	for i=1,#categoriesOrdered do
		local catID = categoriesOrdered[i]
		local cat = categories[catID]
		table.sort(cat, SortCodexEntries)
		local node = {catID, {}}
		local subnode = node[2]
		for j=1,#cat do
			local entry = cat[j]
			--local unlocked = gamedata.codexUnlocked[entryID]
			local read = true	--gamedata.codexRead[entryID]
			local button = Button:New{
				caption = entry.name,
				backgroundColor = {0,0,0,0},
				borderColor = {0,0,0,0},
				OnClick = { function()
					UpdateCodexEntry(entry, codexText, codexImage)
				end},
				font = {
					size = CODEX_BUTTON_FONT_SIZE,	-- - (read and 0 or 1),
					shadow = (read ~= true),
					--outline = (read ~= true),
					outlineWidth = 6,
					outlineHeight = 6,
					--outlineColor = Spring.Utilities.CopyTable(OUTLINE_COLOR),
					autoOutlineColor = false,
				}
			}
			subnode[#subnode + 1] = button
			--Spring.Echo(catID, entry.name)
		end
		nodes[#nodes + 1] = node
	end
	
	-- make treeview
	for i=1,#parent.children do
		parent.children[i]:Dispose()		
	end
	local codexTree = Chili.TreeView:New{
		parent = parent,
		nodes = nodes,	--{"wtf", "lololol", {"omg"}},
		font = {size = CODEX_BUTTON_FONT_SIZE}
	}
	codexText:SetText("")
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Controls

local function InitializeControls(parentControl)
	local codexTextScroll = ScrollPanel:New{
		parent = parentControl,
		x = "40%",
		y = IMAGE_SIZE + 8 + 8,
		bottom = 4,
		right = 4,
		orientation = "vertical",
		children = {}
	}
	local codexText = TextBox:New {
		parent = codexTextScroll,
		x = 0,
		y = 0,
		width = "100%",
		height = "100%",
		text = "",
		font = {size = 18},
	}
	
	local codexImagePanel = Panel:New{
		parent = parentControl,
		y = 4,
		right = 4,
		height = IMAGE_SIZE,
		width = IMAGE_SIZE,
	}
	local codexImage = Image:New{
		parent = codexImagePanel,
		x = 0,
		y = 0,
		width = "100%",
		height = "100%",
	}
	
	local codexTreeScroll = ScrollPanel:New{
		parent = parentControl,
		x = 4,
		y = 4,
		bottom = 4,
		right = "60%",
		orientation = "vertical",
		children = {}
	}
	
	local externalFunctions = {}
	
	function externalFunctions.PopulateCodexTree()
		PopulateCodexTree(codexTreeScroll, codexText, codexImage)
	end
	externalFunctions.PopulateCodexTree()
	
	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Interface

local CodexHandler = {}

function CodexHandler.GetControl()

	local codexManagerStuff	-- FIXME rename

	local window = Control:New {
		name = "codexHandler",
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		padding = {0, 0, 0, 0},
		OnParent = {
			function(obj)
				if obj:IsEmpty() then
					codexManagerStuff = InitializeControls(obj)
				else
					codexManagerStuff.PopulateCodexTree()
				end
			end
		},
	}
	return window
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

function widget:Initialize()
	CHOBBY_DIR = LUA_DIRNAME .. "widgets/chobby/"
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)

	WG.CodexHandler = CodexHandler
end

function widget:Shutdown()
	WG.CodexHandler = nil
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------