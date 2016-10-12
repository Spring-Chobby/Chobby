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
-- External Functions
local BrowserHandler = {}

function BrowserHandler.OpenUrl(urlString)
	if WG.WrapperLoopback then
		WG.WrapperLoopback.OpenUrl(urlString)
	else
		Spring.SetClipboard(urlString)
		WG.TooltipHandler.TooltipOverride("URL copied " .. urlString, 1)
	end
end

function BrowserHandler.AddClickableUrls(chatString, onTextClick)

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
		
		urlStart, urlEnd = string.find(chatString, urlPattern, urlEnd)
	end
	
	return onTextClick
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

function widget:Initialize()
	WG.BrowserHandler = BrowserHandler
end
