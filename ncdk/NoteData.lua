local NoteData = {}

local mt = {__index = NoteData}

NoteData.inputType = "none"
NoteData.inputIndex = 0
NoteData.id = 0  -- for consistent sorting purposes only

function NoteData:new(timePoint, inputType, inputIndex)
	local noteData = {}

	noteData.timePoint = timePoint
	noteData.inputType = inputType
	noteData.inputIndex = inputIndex

	return setmetatable(noteData, mt)
end

function mt.__tostring(a)
	return ("%s,%s,%s"):format(a.timePoint, a.inputType, a.inputIndex)
end

function mt.__eq(a, b)
	return a.timePoint == b.timePoint
end
function mt.__lt(a, b)
	return a.timePoint < b.timePoint or a.timePoint == b.timePoint and a.id < b.id
end
function mt.__le(a, b)
	return a.timePoint <= b.timePoint
end

return NoteData
