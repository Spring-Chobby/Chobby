Downloader = Component:extends{}

function Downloader:init()
	self:super("init")
	self.scale = 1.4 * Configuration:GetScale()
	self.fontSize = 14
	self.lblInstructions = Label:New {
		x = 1,
		width = 100 * self.scale,
		y = 20 * self.scale,
		height = 20 * self.scale,
		caption = i18n("start_download"),
		font = { size = self.scale * self.fontSize},
	}

	self.lblDownload = Label:New {
		x = 1,
		width = 100 * self.scale,
		y = 50 * self.scale,
		height = 20 * self.scale,
		caption = i18n("download_noun") .. ":",
		font = { size = self.scale * self.fontSize},
	}
	self.prDownload = Progressbar:New {
		x = 1 * self.scale,
		width = 200 * self.scale,
		y = 75 * self.scale,
		height = 20 * self.scale,
		value = 0,
	}

	self.btnStart = Button:New {
		x = 1,
		width = 80 * self.scale,
		bottom = 1,
		height = 40 * self.scale,
		caption = i18n("start_verb"),
		font = { size = self.scale * self.fontSize},
		OnClick = {
			function()
		self:startDownload("swiw:stable", "game")
			end
		},
	}

	local ww, wh = Spring.GetWindowGeometry()
	local w, h = 265 * self.scale, 220 * self.scale
	self.window = Window:New {
		x = (ww / 2 - w) / 2,
		y = (wh - h) / 2,
		width = w,
		height = h,
		caption = i18n("download_noun"),
		resizable = false,
		children = {
			self.lblInstructions,
			self.lblDownload,
			self.prDownload,
			self.btnStart,
		},
		parent = screen0,
	}
end

function Downloader:startDownload(archiveName, archiveType)
	VFS.DownloadArchive(archiveName, archiveType)
end

function Downloader:DownloadStarted(...)
	self.lblDownload:SetCaption("Download started!")
end

function Downloader:DownloadFinished(...)
	self.lblDownload:SetCaption("Download finished!")
end

function Downloader:DownloadFailed(x, errorID)
	self.lblDownload:SetCaption("Download failed: " .. errorID)
end

lastUpdate = 0
function Downloader:DownloadProgress(ID, done, size)
	Spring.Echo("Download progress!")
	if Spring.GetGameSeconds() == lastUpdate or size == 0 then
		return
	end
	lastUpdate = Spring.GetGameSeconds()
	--self.lblDownload:SetCaption("Download progress!")
	Spring.Echo("done: " .. tostring(done) .. ", size: " .. tostring(size) .. ", progress: " .. (done/size) .. ", progress%: " .. (100 * done/size))
	self.prDownload:SetValue(100 * done / size)
end

function Downloader:DownloadQueued(...)
	self.lblDownload:SetCaption("Download queued!")
end
