--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Analytics Handler",
		desc      = "Handles analytics events",
		author    = "GoogleFrog",
		date      = "20 February 2017",
		license   = "GPL-v2",
		layer     = 0,
		handler   = true,
		enabled   = true,
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Vars

local onetimeEvents = {}
local indexedRepeatEvents = {}

local ANALYTICS_EVENT = "analyticsEvent_"
local ANALYTICS_EVENT_ERROR = "analyticsEventError_"

-- Do not send analytics for dev versions as they will likely be nonsense.
local ACTIVE = not VFS.HasArchive("Zero-K $VERSION")
local VERSION = "events_2020_05_27:"

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

local Analytics = {}

function Analytics.SendOnetimeEvent(eventName, value)
	eventName = VERSION .. eventName
	if onetimeEvents[eventName] then
		return
	end
	onetimeEvents[eventName] = true
	if ACTIVE and WG.WrapperLoopback ~= nil and WG.WrapperLoopback.GaAddDesignEvent ~= nil then
		WG.WrapperLoopback.GaAddDesignEvent(eventName, value)
	else
		Spring.Echo("DesignEvent", eventName, value)
	end
end

function Analytics.SendIndexedRepeatEvent(eventName, value, suffix)
	eventName = VERSION .. eventName
	indexedRepeatEvents[eventName] = (indexedRepeatEvents[eventName] or 0) + 1

	eventName = eventName .. "_" .. indexedRepeatEvents[eventName]
	if suffix then
		eventName = eventName .. suffix
	end
	if ACTIVE and WG.WrapperLoopback ~= nil and WG.WrapperLoopback.GaAddDesignEvent ~= nil then
		WG.WrapperLoopback.GaAddDesignEvent(eventName, value)
	else
		Spring.Echo("DesignEvent", eventName, value)
	end
end

function Analytics.SendRepeatEvent(eventName, value)
	eventName = VERSION .. eventName
	if ACTIVE and WG.WrapperLoopback ~= nil and WG.WrapperLoopback.GaAddDesignEvent ~= nil then
		WG.WrapperLoopback.GaAddDesignEvent(eventName, value)
	else
		Spring.Echo("DesignEvent", eventName, value)
	end
end

function Analytics.SendErrorEvent(eventName, severity)
	eventName = VERSION .. eventName
	if onetimeEvents[eventName] then
		return
	end
	severity = severity or "Info"
	if ACTIVE and WG.WrapperLoopback ~= nil and WG.WrapperLoopback.GaAddErrorEvent ~= nil then
		WG.WrapperLoopback.GaAddErrorEvent(severity, eventName)
	else
		Spring.Echo("ErrorEvent", eventName, severity)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Utilities

local function HandleAnalytics(msg)
	if string.find(msg, ANALYTICS_EVENT) == 1 then
		msg = string.sub(msg, 16)
		local pipe = string.find(msg, "|")
		if pipe then
			Analytics.SendOnetimeEvent(string.sub(msg, 0, pipe - 1), string.sub(msg, pipe + 1))
		else
			Analytics.SendOnetimeEvent(msg)
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Graphics

local settings = {
	"AllowDeferredMapRendering",
	"AllowDeferredModelRendering",
	"AdvMapShading",
	"AdvUnitShading",
}

local function IsTesselationShaderSupported()
	return gl.HasExtension and gl.HasExtension("GL_ARB_tessellation_shader") and (gl.SetTesselationShaderParameter ~= nil)
end

local function SendGraphicsSettings()
	for i = 1, #settings do
		local value = Spring.GetConfigInt(settings[i], -1)
		Analytics.SendOnetimeEvent("settings:" .. settings[i], value)
	end
end

function widget:ActivateGame()
	-- Give time for the settings that the player will use to be applied properly.
	WG.Delay(SendGraphicsSettings, 30)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Initialize

local function ProcessString(str)
	return string.gsub(string.gsub(str," ","_"),"/","_")
end

function DelayedInitialize()
	local function OnBattleStartSingleplayer()
		Analytics.SendOnetimeEvent("lobby:singleplayer:game_loading")
		-- Singleplayer events have their own, better, handling.
	end
	local function OnBattleStartMultiplayer(_, battleType)
		Analytics.SendOnetimeEvent("lobby:multiplayer:game_loading")
		Analytics.SendRepeatEvent("game_start:multiplayer:connecting_" .. (battleType or "unknown"))
	end

	WG.LibLobby.localLobby:AddListener("OnBattleAboutToStart", OnBattleStartSingleplayer)
	WG.LibLobby.lobby:AddListener("OnBattleAboutToStart", OnBattleStartMultiplayer)

	Analytics.SendOnetimeEvent("lobby:started")
	if Platform and Platform.glVersionShort and type(Platform.glVersionShort) == "string" then
		Analytics.SendOnetimeEvent("graphics:openglVersion:" .. Platform.glVersionShort)
	else
		Analytics.SendOnetimeEvent("graphics:openglVersion:notFound")
	end

	Analytics.SendOnetimeEvent("graphics:gpu:" .. ProcessString(tostring((Platform and Platform.gpu) or "unknown") or "unknown"))
	Analytics.SendOnetimeEvent("graphics:glRenderer:" .. ProcessString(tostring((Platform and Platform.glRenderer) or "unknown") or "unknown"))
	Analytics.SendOnetimeEvent("graphics:tesselation", ((IsTesselationShaderSupported() and 1) or 0))
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

function widget:RecvLuaMsg(msg)
	if HandleAnalytics(msg) then
		return
	end
end

function widget:Initialize()
	WG.Analytics = Analytics
	WG.Delay(DelayedInitialize, 1)
end

function widget:GetConfigData()
	return {
		onetimeEvents = onetimeEvents,
		indexedRepeatEvents = indexedRepeatEvents,
	}
end

function widget:SetConfigData(data)
	-- Reverse compatibility with onetimeEvents = data
	if data["lobby:started"] then
		onetimeEvents = data or {}
		return
	end
	onetimeEvents = data.onetimeEvents or {}
	indexedRepeatEvents = data.indexedRepeatEvents or {}
end
