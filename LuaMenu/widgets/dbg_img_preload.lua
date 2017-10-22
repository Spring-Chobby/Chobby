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

local i = 1
local v = 1
local files = nil

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
		AddDir("LuaMenu/Images")
		AddDir("LuaMenu/Widgets/chili/Skins/Evolved")
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------