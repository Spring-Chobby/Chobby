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

local function IsZkSiteUrl(urlString)
	if string.find(urlString, "http://zero%-k%.info/") == 1 then
		return true
	end
	if string.find(urlString, "http://zero%-k%.info") == 1 and string.len(urlString) == 18 then
		return true
	end
	if string.find(urlString, "https://zero%-k%.info/") == 1 then
		return true
	end
	if string.find(urlString, "https://zero%-k%.info") == 1 and string.len(urlString) == 19 then
		return true
	end
	return false
end

local function NeedLogin(urlString)
	if not IsZkSiteUrl(urlString) then
		return false
	end
	local isWiki = string.find(urlString, "/mediawiki/")
	if isWiki then
		return false
	end
	local lobby = WG.LibLobby.lobby
	local token = lobby:GetMySessionToken()
	return (not token)
end

local function ApplySessionToken(urlString, requireToken, applyUserIDandName)
	local isWiki = string.find(urlString, "/mediawiki/")
	if (not IsZkSiteUrl(urlString)) or isWiki then
		return urlString
	end
	
	local lobby = WG.LibLobby.lobby
	local token = lobby:GetMySessionToken()
	if (not token) then
		if requireToken then
			return false
		end
		return urlString
	end
	
	if applyUserIDandName then
		local myInfo = lobby:GetMyInfo()
		if myInfo.accountID then
			urlString = string.gsub(urlString, "_USER_ID_", myInfo.accountID)
		end
		if myInfo.userName then
			urlString = string.gsub(urlString, "_USER_NAME_", myInfo.userName)
		end
	end
	
	local alreadyAddedPos = string.find(urlString, "%?asmallcake=")
	if alreadyAddedPos then
		return string.sub(urlString, 0, alreadyAddedPos) .. token, false
	end
	local hasQuestionMark = string.find(urlString, "%?")
	if hasQuestionMark then
		return urlString .. "&asmallcake=" .. token, false
	end
	return urlString .. "?asmallcake=" .. token, false
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Functions
local BrowserHandler = {}

function BrowserHandler.OpenUrl(rawUrlString, requireLogin, applyUserIDandName)
	local Configuration = WG.Chobby.Configuration
	if WG.WrapperLoopback then
		if NeedLogin(rawUrlString) then
			local function TryClickAgain()
				local processedUrl = ApplySessionToken(rawUrlString, requireLogin, applyUserIDandName)
				if processedUrl then
					WG.BrowserHandler.OpenUrl(processedUrl)
				end
			end
			local function DelayedTryClickAgain()
				WG.Delay(TryClickAgain, 0.05)
			end
			local function LoginFunc()
				WG.LoginWindowHandler.TryLogin(DelayedTryClickAgain)
			end
			local function GoAnywayFunc()
				WG.SteamHandler.OpenUrlIfActive(urlString)
			end
			if requireLogin then
				WG.Chobby.ConfirmationPopup(LoginFunc, "You must log in to view this page.", nil, 315, 200, "Log In", "Cancel")
			else
				WG.Chobby.ConfirmationPopup(LoginFunc, "Log in first to access more site features.", nil, 315, 200, "Log In", "Not Now", GoAnywayFunc)
			end
		else
			local processedUrl = ApplySessionToken(rawUrlString, requireLogin, applyUserIDandName)
			if processedUrl then
				WG.SteamHandler.OpenUrlIfActive(processedUrl)
			end
		end
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
