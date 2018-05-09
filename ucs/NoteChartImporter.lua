ucs.NoteChartImporter = {}
local NoteChartImporter = ucs.NoteChartImporter

ucs.NoteChartImporter_metatable = {}
local NoteChartImporter_metatable = ucs.NoteChartImporter_metatable
NoteChartImporter_metatable.__index = NoteChartImporter

NoteChartImporter.new = function(self)
	local noteChartImporter = {}
	
	noteChartImporter.currentMeasureTime = ncdk.Fraction:new(0)
	noteChartImporter.currentBPM = 0
	noteChartImporter.currentDelay = 0
	noteChartImporter.currentBeat = 1
	noteChartImporter.currentSplit = 1
	noteChartImporter.currentTimeData = nil
	noteChartImporter.timeData = {}
	noteChartImporter.noteData = {}
	
	setmetatable(noteChartImporter, NoteChartImporter_metatable)
	
	return noteChartImporter
end

NoteChartImporter.import = function(self, noteChartString)
	self.foregroundLayerData = self.noteChart.layerDataSequence:requireLayerData(1)
	self.backgroundLayerData = self.noteChart.layerDataSequence:requireLayerData(2)
	self.backgroundLayerData.invisible = true
	
	for lineIndex, line in ipairs(noteChartString:split("\n")) do
		self:processLine(line:trim(), lineIndex)
	end
	
	self:processAudio()
	
	self:importTimingData()
	self.foregroundLayerData:updateZeroTimePoint()
	
	self:importVelocityData()
	self:importNoteData()
end

NoteChartImporter.processAudio = function(self)
	if self.noteChart.audioFileName then
		local startTimePoint = self.backgroundLayerData:getZeroTimePoint()
		
		startTimePoint.velocityData = self.backgroundLayerData:getVelocityDataByTimePoint(startTimePoint)
		
		noteData = ncdk.NoteData:new(startTimePoint)
		noteData.inputType = "auto"
		noteData.inputIndex = 0
		noteData.soundFileName = self.noteChart.audioFileName
		
		noteData.zeroClearVisualStartTime = self.backgroundLayerData:getVisualTime(startTimePoint, self.backgroundLayerData:getZeroTimePoint(), true)
		noteData.currentVisualStartTime = noteData.zeroClearVisualStartTime
	
		noteData.noteType = "SoundNote"
		self.backgroundLayerData:addNoteData(noteData)
	end
end

NoteChartImporter.processLine = function(self, line, lineIndex)
	if line:find("^:.+=.+$") then
		local key, value = line:match("^:(.+)=(.+)$")
		
		if key == "Format" then
			self.noteChart:hashSet("Format", tonumber(value))
		elseif key == "Mode" then
			self.noteChart:hashSet("Mode", value)
		elseif key == "BPM" or key == "Delay" or key == "Beat" or key == "Split" then
			if not self.timeData[self.currentMeasureTime] then
				self.timeData[self.currentMeasureTime] = {}
				self.timeData[self.currentMeasureTime].startMeasureTime = self.currentMeasureTime
				self.timeData[self.currentMeasureTime].previousTimeData = self.currentTimeData
				self.currentTimeData = self.timeData[self.currentMeasureTime]
				if self.currentTimeData.previousTimeData then
					self.currentTimeData.previousTimeData.endMeasureTime = self.currentTimeData.startMeasureTime
				end
			end
			self.currentTimeData[key:lower()] = tonumber(value)
			
			if key == "BPM" then
				self.currentBPM = tonumber(value)
			elseif key == "Delay" then
				self.currentDelay = tonumber(value)
			elseif key == "Beat" then
				self.currentBeat = tonumber(value)
			elseif key == "Split" then
				self.currentSplit = tonumber(value)
			end
		end
	elseif #line == 5 or #line == 10 then
		if line ~= "....." and line ~= ".........." then
			table.insert(self.noteData, {
				measureTime = self.currentMeasureTime,
				line = line,
				lineIndex = lineIndex
			})
		end
		self.currentMeasureTime = self.currentMeasureTime + ncdk.Fraction:new(1, self.currentBeat * self.currentSplit)
	end
end

NoteChartImporter.importTimingData = function(self)
	self:importSignature()
	self:importTempoData()
	self:importStopData()
end

NoteChartImporter.importSignature = function(self)
end

NoteChartImporter.importTempoData = function(self)
	for _, timeData in pairs(self.timeData) do
		if timeData.bpm then
			self.foregroundLayerData:addTempoData(
				ncdk.TempoData:new(
					timeData.startMeasureTime,
					timeData.bpm
				)
			)
		end
	end
	
	self.foregroundLayerData.timeData.tempoDataSequence:sort()
end

NoteChartImporter.importStopData = function(self)
	for _, timeData in pairs(self.timeData) do
		if timeData.delay and timeData.delay ~= 0 then
			local measureTime = timeData.startMeasureTime
			local measureDuration = ncdk.Fraction:new(0)
			
			local stopData = ncdk.StopData:new(measureTime, measureDuration)
			
			stopData.duration = timeData.delay / 1000
			
			self.foregroundLayerData:addStopData(stopData)
		end
	end
	
	self.foregroundLayerData.timeData.stopDataSequence:sort()
end

NoteChartImporter.importVelocityData = function(self)
	local measureTime = ncdk.Fraction:new(0)
	local timePoint = self.foregroundLayerData:getTimePoint(measureTime, 1)
	local velocityData = ncdk.VelocityData:new(timePoint)
	self.foregroundLayerData:addVelocityData(velocityData)
end

NoteChartImporter.importNoteData = function(self)
	local longNoteData = {}
	for _, noteDataLine in pairs(self.noteData) do
		for inputIndex = 1, #noteDataLine.line do
			local noteChar = noteDataLine.line:sub(inputIndex, inputIndex)
			
			if noteChar ~= "." then
				local measureTime = noteDataLine.measureTime
				local startTimePoint = self.foregroundLayerData:getTimePoint(measureTime, 1)
				startTimePoint.velocityData = self.foregroundLayerData:getVelocityDataByTimePoint(startTimePoint)
				
				local noteData
				if noteChar == "M" or noteChar == "X" then
					noteData = ncdk.NoteData:new(startTimePoint)
					noteData.inputType = "key"
					noteData.inputIndex = inputIndex
					
					noteData.zeroClearVisualStartTime = self.foregroundLayerData:getVisualTime(startTimePoint, self.foregroundLayerData:getZeroTimePoint(), true)
					noteData.currentVisualStartTime = noteData.zeroClearVisualStartTime
					
					noteData.noteType = "ShortNote"
					longNoteData[inputIndex] = noteData
					self.foregroundLayerData:addNoteData(noteData)
				elseif noteChar == "W" then
					noteData = longNoteData[inputIndex]
					if not noteData then error(noteDataLine.lineIndex) end
					noteData.endTimePoint = startTimePoint
					
					noteData.noteType = "LongNote"
				
					noteData.zeroClearVisualEndTime = self.foregroundLayerData:getVisualTime(startTimePoint, self.foregroundLayerData:getZeroTimePoint(), true)
					noteData.currentVisualEndTime = noteData.zeroClearVisualEndTime
					
					longNoteData[inputIndex] = nil
				end
			end
		end
	end
	
	self.backgroundLayerData.noteDataSequence:sort()
	self.foregroundLayerData.noteDataSequence:sort()
end