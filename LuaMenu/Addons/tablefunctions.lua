
Spring.Utilities = Spring.Utilities or {}

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
--deep not safe with circular tables! defaults To false
function Spring.Utilities.CopyTable(tableToCopy, deep)
	local copy = {}
	for key, value in pairs(tableToCopy) do
		if (deep and type(value) == "table") then
			copy[key] = Spring.Utilities.CopyTable(value, true)
		else
			copy[key] = value
		end
	end
	return copy
end

function Spring.Utilities.MergeTable(primary, secondary, deep)
	local new = Spring.Utilities.CopyTable(primary, deep)
	for i, v in pairs(secondary) do
		-- key not used in primary, assign it the value at same key in secondary
		if not new[i] then
			if (deep and type(v) == "table") then
				new[i] = Spring.Utilities.CopyTable(v, true)
			else
				new[i] = v
			end
		-- values at key in both primary and secondary are tables, merge those
		elseif type(new[i]) == "table" and type(v) == "table"  then
			new[i] = Spring.Utilities.MergeTable(new[i], v, deep)
		end
	end
	return new
end

function Spring.Utilities.TableEqual(table1, table2)
	if not table1 then
		return not ((table2 and true) or false)
	end
	if not table2 then
		return false
	end
	for key, value in pairs(table1) do
		if table2[key] ~= value then
			return false
		end
	end
	for key, value in pairs(table2) do
		if table1[key] ~= value then
			return false
		end
	end
	return true
end

-- Returns whether the first table is equal to a subset of the second
function Spring.Utilities.TableSubsetEquals(table1, table2)
	if not table1 then
		return true
	end
	if not table2 then
		return false
	end
	for key, value in pairs(table1) do
		if table2[key] ~= value then
			return false
		end
	end
	return true
end

function Spring.Utilities.TableToString(data, key)
	 local dataType = type(data)
	-- Check the type
	if key then
		if type(key) == "number" then
			key = "[" .. key .. "]"
		end
	end
	if dataType == "string" then
		return key .. [[="]] .. data .. [["]] 
	elseif dataType == "number" then
		return key .. "=" .. data 
	elseif dataType == "boolean" then
		return key .. "=" .. ((data and "true") or "false")
	elseif dataType == "table" then
		local str
		if key then
			str = key ..  "={"
		else
			str = "{"
		end
		for k, v in pairs(data) do
			str = str .. Spring.Utilities.TableToString(v, k) .. ","
		end
		return str .. "}"
	else
		Spring.Echo("TableToString Error: unknown data type", dataType)
	end
	return ""
end

-- need this because SYNCED.tables are merely proxies, not real tables
local function MakeRealTable(proxy)
	local proxyLocal = proxy
	local ret = {}
	for i,v in spairs(proxyLocal) do
		if type(v) == "table" then
			ret[i] = MakeRealTable(v)
		else
			ret[i] = v
		end
	end
	return ret
end

local function TableEcho(data, name, indent, tableChecked)
	name = name or "TableEcho"
	indent = indent or ""
	if (not tableChecked) and type(data) ~= "table" then
		Spring.Echo(indent .. name, data)
		return
	end
	Spring.Echo(indent .. name .. " = {")
	local newIndent = indent .. "    "
	for name, v in pairs(data) do
		local ty = type(v)
		--Spring.Echo("type", ty)
		if ty == "table" then
			TableEcho(v, name, newIndent, true)
		elseif ty == "boolean" then
			Spring.Echo(newIndent .. name .. " = " .. (v and "true" or "false"))
		elseif ty == "string" or ty == "number" then
			if type(name) == "userdata" then
				Spring.Echo(newIndent, name, v)
			else
				Spring.Echo(newIndent .. name .. " = " .. v)
			end
		elseif ty == "userdata" then
			Spring.Echo(newIndent .. "userdata", name, v)
		else
			Spring.Echo(newIndent .. name .. " = ", v)
		end
	end
	Spring.Echo(indent .. "},")
end

function Spring.Utilities.ShallowCopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in pairs(orig) do
			copy[orig_key] = orig_value
		end
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

Spring.Utilities.TableEcho = TableEcho