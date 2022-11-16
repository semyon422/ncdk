local NoteData = {}

local mt = {__index = NoteData}

NoteData.inputType = "none"
NoteData.inputIndex = 0

function NoteData:new(timePoint, inputType, inputIndex)
	local noteData = {}

	noteData.timePoint = timePoint
	noteData.inputType = inputType
	noteData.inputIndex = inputIndex

	return setmetatable(noteData, mt)
end

return NoteData
