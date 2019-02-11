local nameList = {
}

local categories = {
}

local humanNames = {
}

--------- To Generate ------------
--[[
local inNameList = {}
local nameList = {}
local carrierDefs = VFS.Include("LuaRules/Configs/drone_defs.lua")
local function AddUnit(unitName)
	if inNameList[unitName] then
		return
	end
	inNameList[unitName] = true
	nameList[#nameList + 1] = unitName
	
	local ud = UnitDefNames[unitName]
	if ud.buildOptions then
		for i = 1, #ud.buildOptions do
			AddUnit(UnitDefs[ud.buildOptions[i] ].name)
		end
	end
	
	if ud.customParams.morphto then
		AddUnit(ud.customParams.morphto)
	end
	
	if ud.weapons then
		for i = 1, #ud.weapons do
			local wd = WeaponDefs[ud.weapons[i].weaponDef]
			if wd and wd.customParams and wd.customParams.spawns_name then
				AddUnit(wd.customParams.spawns_name)
			end
		end
	end
	
	if carrierDefs[ud.id] then
		local data = carrierDefs[ud.id]
		for i = 1, #data do
			local droneUnitDefID = data[i].drone
			if droneUnitDefID and UnitDefs[droneUnitDefID] then
				AddUnit(UnitDefs[droneUnitDefID].name)
			end
		end
	end
end

local function GenerateLists()
	AddUnit("cloakcon")
	local humanNames = {}
	for i = 1, #nameList do
		humanNames[nameList[i] ] = {
			humanName = UnitDefNames[nameList[i] ].humanName,
			description = UnitDefNames[nameList[i] ].tooltip,
		}
	end
	Spring.Echo(Spring.Utilities.TableToString(nameList, "nameList"))
	Spring.Echo(Spring.Utilities.TableToString(humanNames, "humanNames"))
end

GenerateLists()
--]]

local function UnitOrder(name1, name2)
	local data1 = name1 and humanNames[name1]
	local data2 = name1 and humanNames[name2]
	if not data1 then
		return (data2 and true)
	end
	if not data2 then
		return true
	end
	
	local category1 = categories[data1.category].order
	local category2 = categories[data2.category].order
	return category1 < category2 or (category1 == category2 and data1.order < data2.order)
end

return {
	nameList = nameList,
	humanNames = humanNames,
	categories = categories,
	UnitOrder = UnitOrder,
}