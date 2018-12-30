osu.NoteChartImporter = {}
local NoteChartImporter = osu.NoteChartImporter

osu.NoteChartImporter_metatable = {}
local NoteChartImporter_metatable = osu.NoteChartImporter_metatable
NoteChartImporter_metatable.__index = NoteChartImporter

NoteChartImporter.new = function(self)
	local noteChartImporter = {}
	
	noteChartImporter.metaData = {}
	
	setmetatable(noteChartImporter, NoteChartImporter_metatable)
	
	return noteChartImporter
end

NoteChartImporter.import = function(self, noteChartString)
	self.foregroundLayerData = self.noteChart.layerDataSequence:requireLayerData(1)
	self.backgroundLayerData = self.noteChart.layerDataSequence:requireLayerData(2)
	self.backgroundLayerData.invisible = true
	
	self.foregroundLayerData.timeData:setMode(ncdk.TimeData.Modes.Absolute)
	self.backgroundLayerData.timeData:setMode(ncdk.TimeData.Modes.Absolute)
	
	self.noteChartString = noteChartString
	self:stage1_process()
	self:stage2_process()
	
	self.noteChart.inputMode:setInputCount("key", self.metaData.CircleSize)
	
	self.noteChart:compute()
end

NoteChartImporter.stage1_process = function(self)
	self.metaData = {}
	self.eventParsers = {}
	self.tempTimingDataImporters = {}
	self.timingDataImporters = {}
	self.noteDataImporters = {}
	
	self.totalLength = 0
	
	for _, line in ipairs(self.noteChartString:split("\n")) do
		self:processLine(line)
	end
	
	self:processTimingDataImporters()
	table.sort(self.noteDataImporters, function(a, b) return a.startTime < b.startTime end)
	
	self.foregroundLayerData:updateZeroTimePoint()
	self.backgroundLayerData:updateZeroTimePoint()
	
	self:updatePrimaryBPM()
	self:processMeasureLines()
	
	self:processAudio()
end

NoteChartImporter.processTimingDataImporters = function(self)
	local redTimingData = {}
	local greenTimingData = {}
	
	for i = #self.tempTimingDataImporters, 1, -1 do
		local tdi = self.tempTimingDataImporters[i]
		if tdi.timingChange and not redTimingData[tdi.offset] then
			redTimingData[tdi.offset] = tdi
		elseif not tdi.timingChange and not redTimingData[tdi.offset] then
			greenTimingData[tdi.offset] = tdi
		end
	end
	
	for _, timingDataImporter in pairs(redTimingData) do
		table.insert(self.timingDataImporters, timingDataImporter)
	end
	
	for _, timingDataImporter in pairs(greenTimingData) do
		table.insert(self.timingDataImporters, timingDataImporter)
	end
	
	table.sort(self.timingDataImporters, function(a, b)
		if a.startTime == b.startTime then
			return a.timingChange
		else
			return a.startTime < b.startTime
		end
	end)
end

NoteChartImporter.updatePrimaryBPM = function(self)
	local lastTime = self.totalLength
	local currentBeatLength = 0
	local bpmDurations = {}
	
	for i = #self.timingDataImporters, 1, -1 do
		local tdi = self.timingDataImporters[i]
		
		if tdi.timingChange then
			currentBeatLength = tdi.beatLength
		end
		
		if not (currentBeatLength == 0 or tdi.offset > lastTime or (not tdi.timingChange and i > 1)) then
			bpmDurations[currentBeatLength] = bpmDurations[currentBeatLength] or 0
			bpmDurations[currentBeatLength] = bpmDurations[currentBeatLength] + (lastTime - (i == 1 and 0 or tdi.offset))
			
			lastTime = tdi.offset
		end
	end
	
	local longestDuration = 0
	local average = 0
	
	for beatLength, duration in pairs(bpmDurations) do
		if duration > longestDuration then
			longestDuration = duration
			average = beatLength
		end
	end
	
	self.primaryBeatLength = average
	self.primaryBPM = 60000 / average
end

NoteChartImporter.processAudio = function(self)
	local audioFileName = self.metaData["AudioFilename"]
	
	if audioFileName and audioFileName ~= "virtual" then
		local timePoint = self.backgroundLayerData:getZeroTimePoint()
		
		timePoint.velocityData = self.backgroundLayerData:getVelocityDataByTimePoint(timePoint)
		
		noteData = ncdk.NoteData:new(timePoint)
		noteData.inputType = "auto"
		noteData.inputIndex = 0
		noteData.soundFileName = audioFileName
		
		noteData.zeroClearVisualStartTime = self.backgroundLayerData:getVisualTime(timePoint, self.backgroundLayerData:getZeroTimePoint(), true)
		noteData.currentVisualStartTime = noteData.zeroClearVisualStartTime
	
		noteData.noteType = "SoundNote"
		self.backgroundLayerData:addNoteData(noteData)
	end
end

NoteChartImporter.addDefaultVelocityData = function(self)
	local timePoint = self.foregroundLayerData:getTimePoint(0)
	local velocityData = ncdk.VelocityData:new(timePoint)
	self.foregroundLayerData:addVelocityData(velocityData)
end

NoteChartImporter.processVelocityData = function(self)
	local currentBeatLength = self.primaryBeatLength
	local currentVelocity = 1
	
	local hasDefaultVelocity = false
	
	local rawVelocity = {}
	for i = 1, #self.timingDataImporters do
		local tdi = self.timingDataImporters[i]
		
		rawVelocity[tdi.offset] = rawVelocity[tdi.offset] or 1
		
		if tdi.timingChange then
			currentBeatLength = tdi.beatLength
			currentVelocity = 1
			rawVelocity[tdi.offset] = rawVelocity[tdi.offset] * self.primaryBeatLength / currentBeatLength
		else
			currentVelocity = -100 / tdi.beatLength
			rawVelocity[tdi.offset] = rawVelocity[tdi.offset] * currentVelocity
			hasDefaultVelocity = true
		end
	end
	
	for offset, value in pairs(rawVelocity) do
		local timePoint = self.foregroundLayerData:getTimePoint(offset / 1000)
		local velocityData = ncdk.VelocityData:new(
			timePoint,
			ncdk.Fraction:new():fromNumber(value, 1000)
		)
		self.foregroundLayerData:addVelocityData(velocityData)
	end
	
	if not hasDefaultVelocity then
		self:addDefaultVelocityData()
	end
	
	self.foregroundLayerData.spaceData.velocityDataSequence:sort()
end

NoteChartImporter.stage2_process = function(self)
	self:processVelocityData()
	
	for _, noteParser in ipairs(self.noteDataImporters) do
		self.foregroundLayerData:addNoteData(noteParser:getNoteData())
	end
	self.foregroundLayerData.noteDataSequence:sort()
end

NoteChartImporter.processLine = function(self, line)
	if line:find("^%[") then
		self.currentBlockName = line:match("^%[(.+)%]")
	else
		if line:find("^%a+:.*$") then
			local key, value = line:match("^(%a+):%s?(.*)")
			self.metaData[key] = value:trim()
		elseif self.currentBlockName == "TimingPoints" and line:find("^.+,.+,.+,.+,.+,.+,.+,.+$") then
			self:stage1_addTimingPointParser(line)
		elseif self.currentBlockName == "HitObjects" and line:trim() ~= "" then
			self:stage1_addNoteParser(line)
		end
	end
end

NoteChartImporter.stage1_addTimingPointParser = function(self, line)
	local timingDataImporter = osu.TimingDataImporter:new(line)
	timingDataImporter.line = line
	timingDataImporter.noteChartImporter = self
	timingDataImporter:init()
	
	table.insert(self.tempTimingDataImporters, timingDataImporter)
end

NoteChartImporter.stage1_addNoteParser = function(self, line)
	local noteDataImporter = osu.NoteDataImporter:new()
	noteDataImporter.line = line
	noteDataImporter.noteChartImporter = self
	noteDataImporter:init()
	
	table.insert(self.noteDataImporters, noteDataImporter)
end

NoteChartImporter.processMeasureLines = function(self)
	local currentTime = 0
	local offset
	local firstTdi
	for i = 1, #self.timingDataImporters do
		local tdi = self.timingDataImporters[i]
		if tdi.timingChange then
			firstTdi = tdi
			offset = firstTdi.offset
			break
		end
	end
	while true do
		if offset - firstTdi.measureLength <= 0 then
			break
		else
			offset = offset - firstTdi.measureLength
		end
	end
	
	local lines = {}
	for i = 1, #self.timingDataImporters do
		local currentTdi = self.timingDataImporters[i]
		local nextTdi
		for j = i + 1, #self.timingDataImporters do
			if self.timingDataImporters[j].timingChange then
				nextTdi = self.timingDataImporters[j]
				break
			end
		end
		local nextLastTime = nextTdi and nextTdi.offset or self.totalLength
		if currentTdi.timingChange then
			local measureLength
			if currentTdi.measureLength < 1 then
				measureLength = math.huge
			else
				measureLength = currentTdi.measureLength
			end
			while true do
				if nextLastTime - offset > 1 then
					table.insert(lines, offset)
					offset = math.min(offset + measureLength, nextLastTime)
				else
					offset = nextLastTime
					break
				end
			end
		end
	end
	
	for _, startTime in ipairs(lines) do
		local measureTime = ncdk.Fraction:new(measureIndex)
		local timePoint = self.foregroundLayerData:getTimePoint(startTime / 1000)
		
		for inputIndex = 1, self.metaData.CircleSize do
			local startNoteData = ncdk.NoteData:new(timePoint)
			startNoteData.inputType = "key"
			startNoteData.inputIndex = inputIndex
			startNoteData.noteType = "LineNoteStart"
			self.foregroundLayerData:addNoteData(startNoteData)
			
			local endNoteData = ncdk.NoteData:new(timePoint)
			endNoteData.inputType = "key"
			endNoteData.inputIndex = inputIndex
			endNoteData.noteType = "LineNoteEnd"
			self.foregroundLayerData:addNoteData(endNoteData)
			
			startNoteData.endNoteData = endNoteData
			endNoteData.startNoteData = startNoteData
		end
	end
end
