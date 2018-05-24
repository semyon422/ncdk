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
	
	self.noteChartString = noteChartString
	self:stage1_process()
	self:stage2_process()
end

NoteChartImporter.stage1_process = function(self)
	self.metaData = {}
	self.eventParsers = {}
	self.timingDataImporters = {}
	self.noteDataImporters = {}
	
	self.totalLength = 0
	
	for _, line in ipairs(self.noteChartString:split("\n")) do
		self:processLine(line)
	end
	
	table.sort(self.timingDataImporters, function(a, b)
		if a.startTime == b.startTime then
			return a.timingChange
		else
			return a.startTime < b.startTime
		end
	end)
	table.sort(self.noteDataImporters, function(a, b) return a.startTime < b.startTime end)
	
	self.foregroundLayerData:updateZeroTimePoint()
	self.backgroundLayerData:updateZeroTimePoint()
	
	self:updatePrimaryBPM()
	
	self:processAudio()
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
	local timePoint = self.foregroundLayerData:getTimePoint()
	timePoint.absoluteTime = 0
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
		local timePoint = self.foregroundLayerData:getTimePoint()
		timePoint.absoluteTime = offset / 1000
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
	
	table.insert(self.timingDataImporters, timingDataImporter)
end

NoteChartImporter.stage1_addNoteParser = function(self, line)
	local noteDataImporter = osu.NoteDataImporter:new()
	noteDataImporter.line = line
	noteDataImporter.noteChartImporter = self
	noteDataImporter:init()
	
	table.insert(self.noteDataImporters, noteDataImporter)
end