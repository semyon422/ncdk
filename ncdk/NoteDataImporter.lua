ncdk.NoteDataImporter = {}
local NoteDataImporter = ncdk.NoteDataImporter

ncdk.NoteDataImporter_metatable = {}
local NoteDataImporter_metatable = ncdk.NoteDataImporter_metatable
NoteDataImporter_metatable.__index = NoteDataImporter

NoteDataImporter.new = function(self, lineTable)
	local noteDataImporter = {}
	
	noteDataImporter.lineTable = lineTable
	
	setmetatable(noteDataImporter, NoteDataImporter_metatable)
	
	return noteDataImporter
end

NoteDataImporter.NoteTypeEnum = {
	ShortNote = 0,
	LongNote = 1,
	SoundNote = 2
}

NoteDataImporter.NoteDataEnum = {
	noteType = 3
}

NoteDataImporter.ShortNoteDataEnum = {
	startMeasureTime = 4,
	startSide = 5,
	inputType = 6,
	inputIndex = 7,
	soundFileName = 8
}

NoteDataImporter.LongNoteDataEnum = {
	startMeasureTime = 4,
	startSide = 5,
	endMeasureTime = 6,
	endSide = 7,
	inputType = 8,
	inputIndex = 9,
	soundFileName = 10
}

NoteDataImporter.getNoteData = function(self, layerData)
	local timeData, velocityDataSequence = layerData.timeData, layerData.velocityDataSequence
	
	local noteType = tonumber(self.lineTable[self.NoteDataEnum.noteType])
	
	if noteType == self.NoteTypeEnum.ShortNote or noteType == self.NoteTypeEnum.SoundNote then
		local startMeasureTime = ncdk.Fraction:new():fromString(self.lineTable[self.ShortNoteDataEnum.startMeasureTime])
		local startSide = tonumber(self.lineTable[self.ShortNoteDataEnum.startSide])
		local startTimePoint = timeData:getTimePoint(startMeasureTime, startSide)
		startTimePoint.velocityData = velocityDataSequence:getVelocityDataByTimePoint(startTimePoint)
		
		local noteData = ncdk.NoteData:new(startTimePoint)
		
		noteData.inputType = self.lineTable[self.ShortNoteDataEnum.inputType]
		noteData.inputIndex = tonumber(self.lineTable[self.ShortNoteDataEnum.inputIndex])
		if noteType == self.NoteTypeEnum.ShortNote then
			noteData.noteType = "ShortNote"
		else
			noteData.noteType = "SoundNote"
		end
		noteData.soundFileName = self.lineTable[self.ShortNoteDataEnum.soundFileName]
		
		noteData.zeroClearVisualStartTime = layerData:getVisualTime(startTimePoint, layerData:getZeroTimePoint(), true)
		noteData.currentVisualStartTime = noteData.zeroClearVisualStartTime
		
		return noteData
	elseif noteType == self.NoteTypeEnum.LongNote then
		local startMeasureTime = ncdk.Fraction:new():fromString(self.lineTable[self.LongNoteDataEnum.startMeasureTime])
		local startSide = tonumber(self.lineTable[self.LongNoteDataEnum.startSide])
		local startTimePoint = timeData:getTimePoint(startMeasureTime, startSide)
		startTimePoint.velocityData = velocityDataSequence:getVelocityDataByTimePoint(startTimePoint)
		
		local endMeasureTime = ncdk.Fraction:new():fromString(self.lineTable[self.LongNoteDataEnum.endMeasureTime])
		local endSide = tonumber(self.lineTable[self.LongNoteDataEnum.endSide])
		local endTimePoint = timeData:getTimePoint(endMeasureTime, endSide)
		endTimePoint.velocityData = velocityDataSequence:getVelocityDataByTimePoint(endTimePoint)
		
		local noteData = ncdk.NoteData:new(startTimePoint, endTimePoint)
		
		noteData.inputType = self.lineTable[self.LongNoteDataEnum.inputType]
		noteData.inputIndex = tonumber(self.lineTable[self.LongNoteDataEnum.inputIndex])
		noteData.noteType = "LongNote"
		noteData.soundFileName = self.lineTable[self.LongNoteDataEnum.soundFileName]
		
		noteData.zeroClearVisualStartTime = layerData:getVisualTime(startTimePoint, layerData:getZeroTimePoint(), true)
		noteData.zeroClearVisualEndTime = layerData:getVisualTime(endTimePoint, layerData:getZeroTimePoint(), true)
		noteData.currentVisualStartTime = noteData.zeroClearVisualStartTime
		noteData.currentVisualEndTime = noteData.zeroClearVisualEndTime
		
		return noteData
	end
end