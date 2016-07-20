Downloader = Component:extends{}

function Downloader:init(tbl, timeout, updateListener)
	self:super("init")
	self.lblDownload = Label:New {
		x = 20,
		y = 0,
		right = 0,
		height = 20,
		align = "left",
		valign = "top",
		font = Configuration:GetFont(2),
		caption = "",
	}

	self.prDownload = Progressbar:New {
		x = 0,
		y = 24,
		right = 0,
		height = 30,
		value = 0,
	}
	
	self.queueLabel = Label:New {
		x = 0,
		y = 60,
		right = 0,
		height = 16,
		align = "left",
		valign = "center",
		font = Configuration:GetFont(1),
		caption = "Queue:",
	}
	
	self.queueList = Label:New {
		x = 5,
		y = 80,
		right = 0,
		bottom = 0,
		align = "left",
		valign = "top",
		font = Configuration:GetFont(1),
		caption = "",
	}

	self.window = Control:New(table.merge({
		caption = '',
		padding = {0, 0, 0, 0},
		resizable = false,
		draggable = false,
		children = {
			self.lblDownload,
			self.prDownload,
			self.queueLabel,
			self.queueList,
		},
	}, tbl))
	
	self.queueLabel:Hide()
	self.queueList:Hide()

	self.downloads = {}
	self._lastUpdate = 0
	self.delayID = 0
	self.timeout = timeout
	self.updateListener = updateListener
end

function Downloader:UpdateQueue()
	local downloadCount = 0
	local failure = false
	
	local queueText = false
	for downloadID, data in pairs(self.downloads) do
		downloadCount = downloadCount + 1
		if not data.started and not data.complete then
			local text = data.archiveName
			if data.failed then
				failure = true
				text = Configuration:GetErrorColor() .. "*" .. text .. "*" .. Configuration:GetNormalColor()
			end
			if queueText then
				queueText = queueText .. "\n" .. text
			else
				if not self.queueLabel.visible then
					self.queueLabel:Show()
					self.queueList:Show()
				end
				queueText = text
			end
		end
	end
	
	if queueText then
		self.queueList:SetCaption(queueText)
	else
		if self.queueLabel.visible then
			self.queueLabel:Hide()
			self.queueList:Hide()
		end
	end
	
	if self.updateListener then
		self.updateListener(downloadCount, failure)
	end
end

function Downloader:Hide()
	self.lblDownload:Hide()
	self.prDownload:Hide()
end

function Downloader:_CleanupDownload(myDelayID)
	if self.delayID ~= myDelayID then
		return
	end

	for downloadID, data in pairs(self.downloads) do
		if data.failed or data.complete then
			self.downloads[downloadID] = nil
		end
	end
	self:UpdateQueue()
	
	for _, _ in pairs(self.downloads) do
		return -- don't hide progress bar if there are active downloads
	end
-- 	if window.disposed then
-- 		return
-- 	end
	if not self.prDownload.hidden then
		self.prDownload:Hide()
	end
	if not self.lblDownload.hidden then
		self.lblDownload:Hide()
	end
end

-- util function to round to decimal spaces
function round2(num, idp)
  return string.format("%." .. (idp or 0) .. "f", num)
end

function Downloader:DownloadProgress(downloadID, downloaded, total)
	if not self.downloads[downloadID] then
		return
	end
	if Spring.GetGameSeconds() == self._lastUpdate or total == 0 then
		return
	end
	
	self._lastUpdate = Spring.GetGameSeconds()

	
	local elapsedTime = os.clock() - self.downloads[downloadID].startTime
	local doneRatio = downloaded / total
	local remainingSeconds = (1 - doneRatio) * elapsedTime / (doneRatio + 0.001)

	-- calculate suffix
	local suffix = "B"
	if total > 1024 then
		total = total / 1024
		downloaded = downloaded / 1024
		suffix = "KB"
	end
	if total > 1024 then
		total = total / 1024
		downloaded = downloaded / 1024
		suffix = "MB"
	end
	local remainingTimeStr = ""
	remainingSeconds = math.ceil(remainingSeconds)
	if remainingSeconds > 60 then
		local minutes = math.floor(remainingSeconds / 60)
		remainingSeconds = remainingSeconds - minutes * 60
		if minutes > 60 then
			local hours = math.floor(minutes / 60)
			minutes = minutes - hours * 60
			remainingTimeStr = remainingTimeStr .. tostring(hours) .. "h"
		end
		remainingTimeStr = remainingTimeStr .. tostring(minutes) .. "m"
	end
	remainingTimeStr = remainingTimeStr .. tostring(remainingSeconds) .. "s"
	-- round to one decimal
	local totalStr = round2(total, 1)
	local downloadedStr = round2(downloaded, 1)

	self.prDownload:SetCaption(remainingTimeStr .. " left: " .. downloadedStr .. "/" .. totalStr .. " MB")
	self.prDownload:SetValue(100 * doneRatio)
end

function Downloader:DownloadStarted(downloadID)
	if not self.downloads[downloadID] then
		return
	end
	if self.prDownload.hidden then
		self.prDownload:Show()
	end
	if self.lblDownload.hidden then
		self.lblDownload:Show()
	end
	self.lblDownload:SetCaption(self.downloads[downloadID].archiveName)
	self.downloads[downloadID].started = true
	self:UpdateQueue()
end

function Downloader:DownloadFinished(downloadID)
	if not self.downloads[downloadID] then
		return
	end
	self.downloads[downloadID].complete = true
	self.prDownload:SetCaption("\255\0\255\0Download complete.\b")
	
	-- Effectively a reimplementation of SignalMask from LUS
	if self.timeout then
		self.delayID = self.delayID + 1
		local thisDelayID = self.delayID
		WG.Delay(function() self:_CleanupDownload(thisDelayID) end, self.timeout)
	end
	self:UpdateQueue()
end

function Downloader:DownloadFailed(downloadID, errorID)
	if not self.downloads[downloadID] then
		return
	end
	self.downloads[downloadID].failed = true
	self.prDownload:SetCaption("\255\255\0\0Download failed [".. errorID .."].\b")
	
	-- Effectively a reimplementation of SignalMask from LUS
	if self.timeout then
		self.delayID = self.delayID + 1
		local thisDelayID = self.delayID
		WG.Delay(function() self:_CleanupDownload(thisDelayID) end, self.timeout)
	end
	self:UpdateQueue()
end

function Downloader:DownloadQueued(downloadID, archiveName, archiveType)
	self.downloads[downloadID] = { archiveName = archiveName, archiveType = archiveType, startTime = os.clock() }
	self:UpdateQueue()
end
