    self.myChannels = {}
function Wrapper:_OnJoin(chanName)

	table.insert(self.myChannels, chanName)

    self:super("_OnJoin", chanName)
end
Wrapper.commands["JOIN"] = Wrapper._OnJoin

-- override
end
function Wrapper:GetMyChannels()
    return self.myChannels
