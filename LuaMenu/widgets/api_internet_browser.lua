--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Internet Browser API",
		desc      = "Provides the interface for opening URLs and interacting with a browser.",
		author    = "GoogleFrog",
		date      = "22 September 2016",
		license   = "GNU LGPL, v2.1 or later",
		layer     = -10000,
		enabled   = true  --  loaded by default?
	}
end

local urlPattern = "https?://[%w-_%.%?%.:/%+=&]+"

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Utilities

local function ApplySessionToken(urlString)
	local isZkSite = string.find(urlString, "http://zero%-k%.info") == 1
	if not isZkSite then
		return urlString
	end
	local lobby = WG.LibLobby.lobby
	if lobby:GetMyIsAdmin() then
		return urlString -- Don't use tokens for admins
	end
	local token = lobby:GetMySessionToken()
	if not token then
		return urlString
	end
	local alreadyAddedPos = string.find(urlString, "%?asmallcake=")
	if alreadyAddedPos then
		return string.sub(urlString, 0, alreadyAddedPos) .. token
	end
	local hasQuestionMark = string.find(urlString, "%?")
	if hasQuestionMark then
		return urlString .. "&asmallcake=" .. token
	end
	return urlString .. "?asmallcake=" .. token
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Functions
local BrowserHandler = {}

function BrowserHandler.OpenUrl(urlString)
	urlString = ApplySessionToken(urlString)
	if WG.WrapperLoopback then
		WG.WrapperLoopback.OpenUrl(urlString)
	else
		Spring.SetClipboard(urlString)
		WG.TooltipHandler.TooltipOverride("URL copied " .. urlString, 1)
	end
end

function BrowserHandler.AddClickableUrls(chatString, onTextClick, textTooltip)

	local urlStart, urlEnd = string.find(chatString, "http[^%s]*")
	--Spring.Echo("URL urlStart, urlEnd", chatString, urlStart, urlEnd)
	while urlStart do
		-- Cull end puncuation
		local endChar = string.sub(chatString, urlEnd, urlEnd)
		if string.find(endChar, "%p") then
			urlEnd = urlEnd - 1
		end
		
		local urlString = string.sub(chatString, urlStart, urlEnd)
		
		onTextClick[#onTextClick + 1] = {
			startIndex = urlStart, 
			endIndex = urlEnd, 
			OnTextClick = { 
				function() 
					BrowserHandler.OpenUrl(urlString)
				end
			} 
		}
		
		textTooltip[#textTooltip + 1] = {
			startIndex = urlStart, 
			endIndex = urlEnd,
			tooltip = urlString,
		}
		
		urlStart, urlEnd = string.find(chatString, urlPattern, urlEnd)
	end
	
	return onTextClick, textTooltip
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

function widget:Initialize()
	WG.BrowserHandler = BrowserHandler
end
