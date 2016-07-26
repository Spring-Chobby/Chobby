
StringUtilities = StringUtilities or {}

function StringUtilities.GetTruncatedString(myString, myFont, maxLength)
	if (not maxLength) then
		return myString
	end
	local length = string.len(myString)
	while myFont:GetTextWidth(myString) > maxLength do
		length = length - 1
		myString = string.sub(myString, 0, length)
		if length < 1 then
			return ""
		end
	end
	return myString
end

function StringUtilities.TruncateStringIfRequired(myString, myFont, maxLength)
	if (not maxLength) or (myFont:GetTextWidth(myString) <= maxLength) then
		return false
	end
	return StringUtilities.GetTruncatedString(myString, myFont, maxLength)
end