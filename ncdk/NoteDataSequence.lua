local NoteDataSequence = {}

local NoteDataSequence_metatable = {}
NoteDataSequence_metatable.__index = NoteDataSequence

NoteDataSequence.new = function(self)
	local noteDataSequence = {}
	
	noteDataSequence.noteDataCount = 0
	
	setmetatable(noteDataSequence, NoteDataSequence_metatable)
	
	return noteDataSequence
end

NoteDataSequence.addNoteData = function(self, ...)
	local layerDataSequence = self.layerData.layerDataSequence

	for _, noteData in ipairs({...}) do
		table.insert(self, noteData)
		self.noteDataCount = self.noteDataCount + 1
		
		layerDataSequence:increaseInputCount(noteData.inputType, noteData.inputIndex, 1)
	end
end

NoteDataSequence.getNoteData = function(self, noteDataIndex)
	return self[noteDataIndex]
end

NoteDataSequence.getNoteDataCount = function(self)
	return self.noteDataCount
end

local sort = function(noteData1, noteData2)
	return noteData1.timePoint < noteData2.timePoint
end

NoteDataSequence.sort = function(self)
	return table.sort(self, sort)
end

return NoteDataSequence
