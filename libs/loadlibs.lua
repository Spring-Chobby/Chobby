package = {}
package.path = "./libs/?.lua;./libs/?/init.lua;libs/vstruct/?/init.lua;libs/vstruct/?.lua"
package.loaded = {}
package.preload = {}
_G["package"] = package
function module(name)
    if package.loaded[name] then
        return package.loaded[name]
    else
        local t = _G[name]
        if t ~= nil then
            return t
        end
        local t = { _NAME = name }
        t._M = t
        _G[name] = t        
        package.loaded[name] = t
        setfenv(1, t)
        return t
    end
end

function require(name)
--    Spring.Echo("Loading... " .. name)
    if package.loaded[name] == false then
        error("previous error loading " .. name)
    elseif package.loaded[name] then
        return package.loaded[name]
    end
    if package.preload[name] then
        package.loaded[name] = package.preload[name]()
        return package.loaded[name]
    end
    for path in package.path:gmatch("[^;]+") do
        local file = path:gsub("%?", (name:gsub("%.", "/")))
        local fd = VFS.LoadFile(file)
        if fd then
            local loader = assert(loadstring(fd, name))
            package.loaded[name] = loader()
--            Spring.Echo("Loaded... " .. name)
            return package.loaded[name]
        end
    end
    error("couldn't find module " .. name)
end

