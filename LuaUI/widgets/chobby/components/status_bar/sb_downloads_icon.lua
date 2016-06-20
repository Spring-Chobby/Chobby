SBDownloadsIcon = SBItem:extends{}

function SBDownloadsIcon:init()
    self:super('init')

    self.btnDownloads = Button:New {
        x = self.imagePadding,
        width = self.iconSize + self.imagePadding,
        height = self.iconSize + self.imagePadding,
        y = (self.height - self.iconSize) / 2 - 4,
        caption = '',
        tooltip = i18n("downloads"),
        padding = {0, 0, 0, 0},
        itemPadding = {0, 0, 0, 0},
        borderThickness = 0,
        backgroundColor = {0, 0, 0, 0},
        focusColor      = {0.4, 0.4, 0.4, 1},
        children = {
            Label:New {
                x = 3,
                bottom = 0,
                height = 10,
                font = { 
                    size = 17, 
                    autoOutlineColor = false,
                    shadow = false,
                    outline = false,
                },
                caption = "",
            },
            Image:New {
                x = 4,
                y = 4,
                width = self.iconSize,
                height = self.iconSize,
                margin = {0, 0, 0, 0},
                file = CHILI_LOBBY_IMG_DIR .. "download_off.png",
            },
        },
    }
    self:AddControl(self.btnDownloads)
    self.downloads = 0
end

function SBDownloadsIcon:UpdateDownloadStatus()
    local img = self.btnDownloads.children[2]
    if self.downloads > 0 then
       -- self.btnDownloads.children[1]:SetCaption("\255\120\120\120" .. tostring(self.downloads) .. "\b")
        img.file = CHILI_LOBBY_IMG_DIR .. "download.png"
        self.btnDownloads.tooltip = "Downloads left: " .. tostring(self.downloads) .. "\n"
    else
        ChiliFX:AddGlowEffect({
            obj = img, 
            time = 3, 
            endValue = 0.4, 
            after = function()
                img.file = CHILI_LOBBY_IMG_DIR .. "download_off.png"
            end
        })
        self.btnDownloads.children[1]:SetCaption("")
        self.btnDownloads.tooltip = ""
        Chotify:Post({
            title = "Download",
            body = i18n("downloads_completed"),
        })
    end
    img:Invalidate()
end

function SBDownloadsIcon:DownloadStarted(...)
    self:UpdateDownloadStatus()
end

function SBDownloadsIcon:DownloadQueued(...)
    self.downloads = self.downloads + 1
    self:UpdateDownloadStatus()

    local img = self.btnDownloads.children[2]
    img.file = CHILI_LOBBY_IMG_DIR .. "download.png"
    ChiliFX:AddGlowEffect({
        obj = img, 
        time = 1,
        endValue = 1,
        startValue = 2,
    })
    Chotify:Post({
        title = "Download",
        body = i18n("items_to_download", {count=self.downloads}),
    })
end

function SBDownloadsIcon:DownloadFinished(...)
    self.downloads = self.downloads - 1
    self:UpdateDownloadStatus()
end

function SBDownloadsIcon:DownloadFailed(...)
    self.downloads = self.downloads - 1
    self:UpdateDownloadStatus()
end

function SBDownloadsIcon:DownloadProgress(id, done, size)
    self.btnDownloads.tooltip = "Downloads left: " .. tostring(self.downloads) .. "\n" .. "Current item progress: " .. done .. "/" .. size
end
