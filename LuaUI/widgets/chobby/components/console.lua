Console = LCS.class{}

function Console:init(channelName, sendMessageListener, noHistoryLoad)
	self.listener = sendMessageListener
	self.showDate = true
	self.dateFormat = "%H:%M"
	
	self.channelName = channelName

	-- TODO: currently this is handled by chat windows and battleroom chat separately
	self.unreadMessages = 0

	self.spHistory = ScrollPanel:New {
		x = 0,
		right = 2,
		y = 0,
		bottom = 35,
		verticalSmartScroll = true,
	}
	self.tbHistory = TextBox:New {
		x = 0,
		right = 0,
		y = 0,
-- 		maxHeight = 500,
		bottom = 0,
		text = "",
		fontsize = Configuration:GetFont(1).size,
		parent = self.spHistory,
		selectable = true,

		_inmousemove = false,
		OnClick = { function(obj)
			if not obj._inmousemove then
				screen0:FocusControl(self.ebInputText)
			end
			obj._inmousemove = false
		end},
		OnMouseMove = { function(obj, x, y, dx, dy, button)
			if button ~= 1 then
				return
			end
			obj._inmousemove = true
		end},
	}
	self.ebInputText = EditBox:New {
		x = 0,
		bottom = 7,
		height = 25,
		right = 2,
		text = "",
		fontsize = Configuration:GetFont(1).size,
		--hint = i18n("type_here_to_chat"),
	}
	
	self.ebInputText.KeyPress = function(something, key, ...)
		if key == Spring.GetKeyCode("tab") then
			self:Autocomplete(self.ebInputText.text)
			return false
		else
			self.subword = nil
			return Chili.EditBox.KeyPress(something, key, ...)
		end
	end
	self.ebInputText.OnKeyPress = {
		function(obj, key, mods, ...)
			if key == Spring.GetKeyCode("enter") or 
				key == Spring.GetKeyCode("numpad_enter") then
				self:SendMessage()
				return true
			end
		end
	}
	self.fakeImage = Image:New {
		x = 0, y = 0,
		bottom = 0, right = 0,
		OnClick = { function()
			screen0:FocusControl(self.ebInputText)
		end}
	}

	self.panel = Control:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		padding      = {0, 0, 0, 0},
		itemPadding  = {0, 0, 0, 0},
		itemMargin   = {0, 0, 0, 0},
		children = {
			self.spHistory,
			self.ebInputText,
			self.fakeImage,
		},
	}
	
	if not noHistoryLoad then
		self:LoadHistory(Configuration.lastLoginChatLength)
	end
end

function Console:Autocomplete(textSoFar)
	if not self.subword then
		local start = 0
		for i = 1, 100 do
			local newStart = (string.find(textSoFar, " ", start) or (start - 1)) + 1
			
			if start ~= newStart then
				start = newStart
			else
				break
			end
		end
	
		self.subword = string.sub(textSoFar, start)
		self.unmodifiedLength = string.len(textSoFar)
		local length = string.len(self.subword)
		
		self.suggestion = 0
		self.suggestions = {}
		
		if length == 0 then
			return
		end
		
		local users = lobby:GetUsers()
		for name, _ in pairs(users) do
			if name:starts(self.subword) then
				self.suggestions[#self.suggestions + 1] = string.sub(name, length + 1)
			end
		end
	end
	
	if #self.suggestions == 0 then
		return
	end
	
	self.suggestion = self.suggestion + 1
	if self.suggestion > #self.suggestions then
		self.suggestion = 1
	end
	
	self.ebInputText.selStart = self.unmodifiedLength + 1
	self.ebInputText.selEnd = string.len(textSoFar) + 1
	self.ebInputText:ClearSelected()
	
	self.ebInputText:TextInput(self.suggestions[self.suggestion])
end

function Console:SendMessage()
	if self.ebInputText.text ~= "" then
		message = self.ebInputText.text
		if self.listener then
			self.listener(message)
		end
		self.ebInputText:SetText("")
	end
end

-- if date is not passed, current time is assumed
function Console:AddMessage(message, userName, dateOverride, color, thirdPerson)
	local txt = ""
	local whiteText = ""
	if self.showDate then
		local timeOverride
		if dateOverride then
			local utcHour = tonumber(os.date("!%H"))
			local utcMinute = tonumber(os.date("!%M"))
			local localHour = tonumber(os.date("%H"))
			local localMinute = tonumber(os.date("%M"))
		
			local messageHour = tonumber(string.sub(dateOverride, 12, 13))
			local messageMinute = tonumber(string.sub(dateOverride, 15, 16))
			
			if messageHour and messageMinute then
				local hour = (localHour - utcHour + messageHour)%24
				if hour < 10 then
					hour = "0" .. hour
				end
				local minute = (localMinute - utcMinute + messageMinute)%60
				if minute < 10 then
					minute = "0" .. minute
				end
				 
				timeOverride = hour .. ":" .. minute
			else
				Spring.Echo("Bad dateOverride", dateOverride, messageHour, messageMinute)
			end
		end
		-- FIXME: the input "date" should ideally be a table so we can coerce the format
		local currentDate = timeOverride or os.date(self.dateFormat)
		txt = txt .. "\255\128\128\128[" .. currentDate .. "] "
		whiteText = whiteText .. "[" .. currentDate .. "] "
		if color ~= nil then
			txt = txt .. color
		end
	end
	if userName ~= nil then
		if thirdPerson then
			txt = txt .. userName .. " "
		else
			txt = txt .. "\255\50\160\255" .. userName .. ": \255\255\255\255"
			whiteText = whiteText .. userName .. ": "
			if color ~= nil then
				txt = txt .. color
			end
		end
	end
	txt = txt .. message
	whiteText = whiteText .. message
	if self.tbHistory.text == "" then
		self.tbHistory:SetText(txt)
	else
		self.tbHistory:AddLine(txt)
	end
	
	if self.channelName then
		Spring.CreateDir("chatLogs")
		local logFile, errorMessage = io.open('chatLogs/' .. self.channelName .. ".txt", 'a')
		if logFile then
			if dateOverride then
				logFile:write("\n" .. ((string.sub(dateOverride, 0, 19) .. " - ") or "") .. whiteText)
			else
				logFile:write("\n" .. whiteText)
			end
			io.close(logFile)
		end
	end
end

function Console:LoadHistory(numLines)
	if not self.channelName then
		return
	end
	local path = 'chatLogs/' .. self.channelName .. ".txt"
	if not VFS.FileExists(path) then
		return
	end
	
	local lineCount = 0
	for line in io.lines(path) do
		lineCount = lineCount + 1
	end
	
	local waitToWrite = lineCount - numLines
	for line in io.lines(path) do
		if waitToWrite > 0 then
			waitToWrite = waitToWrite - 1
		else
			local start = string.find(line, "%[")
			if start then
				local txt = "\255\128\128\128" .. string.sub(line, start)
				if self.tbHistory.text == "" then
					self.tbHistory:SetText(txt)
				else
					self.tbHistory:AddLine(txt)
				end
			end
		end
	end
	
	--local logFile, errorMessage = io.open(, 'r')

end
