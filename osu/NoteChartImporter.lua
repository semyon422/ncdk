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
	
	for _, line in ipairs(self.noteChartString:split("\n")) do
		self:processLine(line)
	end
	
	local compareByStartTime = function(a, b) return a.startTime < b.startTime end
	table.sort(self.timingDataImporters, compareByStartTime)
	table.sort(self.noteDataImporters, compareByStartTime)
	
	self.foregroundLayerData:updateZeroTimePoint()
	self.backgroundLayerData:updateZeroTimePoint()
	
	self:processAudio()
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

NoteChartImporter.stage2_process = function(self)
	self:addDefaultVelocityData()
	
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