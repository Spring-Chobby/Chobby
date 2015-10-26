function gadget:GetInfo()
	return {
		name	= 'Initial Settings',
		desc	= 'Handles initial engine settings',
		author	= 'TurBoss',
		version	= 'v0.1',
		date	= 'Oct 25-10-2015 ',
		license	= 'GNU GPL, v2 or later',
		layer	= 0,
		enabled	= true
	}
end

if gadgetHandler:IsSyncedCode() then
	return
end

function gadget:GameSetup()
	return true, true
end

