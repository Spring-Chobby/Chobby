Downloader = Component:extends{}

function Downloader:init(tbl)
	self:super("init")
	self.lblDownload = Label:New {
		x = 0,
		y = 0,
		width = 100,
		height = 20,
		caption = "",
	}

	self.prDownload = Progressbar:New {
		x = 0,
		y = 20,
		width = 200,
		height = 30,
		value = 0,
	}

	self.window = Window:New(table.merge({
		width = 200,
		height = 50,
		caption = '',
		padding = {0, 0, 0, 0},
		resizable = false,
		draggable = false,
		children = {
			self.lblDownload,
			self.prDownload,
		},
	}, tbl))

	self.downloads = {}
	self._lastUpdate = 0
end

function Downloader:Hide()
	self.lblDownload:Hide()
	self.prDownload:Hide()
end

function Downloader:_CleanupDownload()
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
end

function Downloader:DownloadFinished(downloadID)
	if not self.downloads[downloadID] then
		return
	end
	self.downloads[downloadID] = nil
	self.prDownload:SetCaption("\255\0\255\0Download complete.\b")
	WG.Delay(function() self:_CleanupDownload() end, 5)
end

function Downloader:DownloadFailed(downloadID, errorID)
	if not self.downloads[downloadID] then
		return
	end
	self.downloads[downloadID] = nil
	self.prDownload:SetCaption("\255\255\0\0Download failed [".. errorID .."].\b")
	WG.Delay(function() self:_CleanupDownload() end, 5)
end

function Downloader:DownloadQueued(downloadID, archiveName, archiveType)
	self.downloads[downloadID] = { archiveName = archiveName, archiveType = archiveType, startTime = os.clock() }
end
