LOG_SECTION = "liblobby"

function dumpConfig()
    -- dump all luasocket related config settings to console
    for _, conf in ipairs({"TCPAllowConnect", "TCPAllowListen", "UDPAllowConnect", "UDPAllowListen"  }) do
        Spring.Log(LOG_SECTION, LOG.INFO, conf .. " = " .. Spring.GetConfigString(conf, ""))
    end
end

function string.starts(String,Start)
    return string.sub(String,1,string.len(Start))==Start
end

function string.ends(String,End)
    return End=='' or string.sub(String,-string.len(End))==End
end

function explode(div,str)
if (div=='') then return false end
local pos,arr = 0,{}
-- for each divider found
for st,sp in function() return string.find(str,div,pos,true) end do
    table.insert(arr,string.sub(str,pos,st-1)) -- Attach chars left of current divider
    pos = sp + 1 -- Jump past current divider
end
table.insert(arr,string.sub(str,pos)) -- Attach chars right of last divider
return arr
end

function concat(...)
    local args = {...}
    local argsClean = {}
    for k, v in pairs(args) do
        if v == nil then
            break
        end
        table.insert(argsClean, v)
    end
    return table.concat(argsClean, " ")
end

function tableToString(data)
    local retString = "{"
	local first = true
    for key, value in pairs(data) do
		if not first then
			retString = retString .. ","
		end
        retString = retString .. "\"" .. key .. "\":" 
		if type(value) == "table" then
			tableToString(data)
		elseif type(value) == "string" then
			retString = retString .. "\"" .. value .. "\""
		else -- Assume number
			retString = retString .. value
		end
		first = false
    end
	retString = retString .. "}"
    return retString
end

function parseTags(tags)
    local tags = explode("\t", tags)
    local tagsMap = {}
    for _, tag in pairs(tags) do
        local indx = string.find(tag, "=")
        local key = string.sub(tag, 1, indx-1)
        local value = string.sub(tag, indx+1)
        tagsMap[key] = value
    end
    return tagsMap
end

function getTag(tags, tagName, mandatory)
    local value = tags[tagName]
    if mandatory and value == nil then
        error("Missing mandatory parameter: " .. tostring(tagName))
    end
    return value
end
