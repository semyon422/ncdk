local NoteData = {}

local mt = {__index = NoteData}

NoteData.inputType = "none"
NoteData.inputIndex = 0

function NoteData:new(timePoint)
	local noteData = {}

	noteData.timePoint = timePoint

	return setmetatable(noteData, mt)
end

return NoteData
