Component = LCS.class{}

Component.registeredComponents = {}

function Component:DoInit()
	table.insert(Component.registeredComponents, self)
end

function Component:init()
	self:DoInit()
end

function Component:unregister()
	for i, comp in pairs(Component.registeredComponents) do
		if comp == self then
			table.remove(Component.registeredComponents, i)
		end
	end	
end

function Component:ScaleUpdate(scale)
end

function Component:ViewResize(viewSizeX, viewSizeY)
end

function Component:DownloadStarted(...)
end

function Component:DownloadFinished(...)
end

function Component:DownloadFailed(...)
end

function Component:DownloadProgress(id, done, size)
end

function Component:DownloadQueued(...)
end
