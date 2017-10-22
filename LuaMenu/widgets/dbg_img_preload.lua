--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
  return {
    name      = "Image Preloader",
    desc      = "Preloads images; fixes buildpic issues",
    author    = "jK",
    date      = "@2009",
    license   = "GPLv2",
    layer     = 1000,
    enabled   = true,  --  loaded by default?
    alwaysStart = true,
  }
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local index = 1
local files = nil
local BATCH_SIZE = 5

local function MaybeAddFile(fileName)
	if string.find(fileName, "%.dds") or string.find(fileName, "%.png") or string.find(fileName, "%.jpg") then
		files[#files+1] = fileName
	end
end

local function AddDir(path) 
	for _, f in ipairs(VFS.DirList(path)) do
		MaybeAddFile(f)
	end
end

function widget:DrawGenesis()
	if files == nil then
		files = {}
		MaybeAddFile(LUA_DIRNAME .. "images/heic1403aDowngrade.jpg")
		AddDir("LuaMenu/Widgets/chili/Skins/Evolved")
		--AddDir("LuaMenu/Images")
		--AddDir("LuaMenu/Images/starbackgrounds")
		--AddDir("LuaMenu/configs/gameConfig/zk/unitpics")
	else
		for i = 1, BATCH_SIZE do
			local file = files[index]
			if file then
				gl.Texture(7, file)
				gl.Texture(7, false)
				index = index + 1
			else 
				widgetHandler:RemoveWidget()
				return
			end
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
