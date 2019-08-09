local NoteData = {}

local NoteData_metatable = {}
NoteData_metatable.__index = NoteData

NoteData.inputType = "none"
NoteData.inputIndex = 0

NoteData.new = function(self, timePoint)
	local noteData = {}
	
	noteData.timePoint = timePoint
	
	setmetatable(noteData, NoteData_metatable)
	
	return noteData
end

return NoteData
