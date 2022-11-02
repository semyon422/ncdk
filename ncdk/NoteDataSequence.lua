local NoteDataSequence = {}

local mt = {__index = NoteDataSequence}

function NoteDataSequence:new()
	local noteDataSequence = {}

	noteDataSequence.noteDataCount = 0

	return setmetatable(noteDataSequence, mt)
end

function NoteDataSequence:addNoteData(...)
	local noteChart = self.layerData.noteChart

	for _, noteData in ipairs({...}) do
		table.insert(self, noteData)
		self.noteDataCount = self.noteDataCount + 1
		noteData.id = self.noteDataCount

		noteChart:increaseInputCount(noteData.inputType, noteData.inputIndex, 1)
	end
end

function NoteDataSequence:getNoteData(noteDataIndex)
	return self[noteDataIndex]
end

function NoteDataSequence:getNoteDataCount()
	return self.noteDataCount
end

local function sort(noteData1, noteData2)
	if noteData1.timePoint == noteData2.timePoint then
		return noteData1.id < noteData2.id
	end
	return noteData1.timePoint < noteData2.timePoint
end

function NoteDataSequence:sort()
	return table.sort(self, sort)
end

return NoteDataSequence
