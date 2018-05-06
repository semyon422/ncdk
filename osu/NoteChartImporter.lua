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
	
	self.noteChartString = noteChartString
	self:stage1_process()
	self:stage2_process()
end

NoteChartImporter.stage1_process = function(self)
	self.metaData = {}
	self.eventParsers = {}
	self.timingPointParsers = {}
	self.noteParsers = {}
	
	for _, line in ipairs(self.noteChartString:split("\n")) do
		self:processLine(line)
	end
	
	local compareByStartTime = function(a, b) return a.startTime < b.startTime end
	table.sort(self.timingPointParsers, compareByStartTime)
	table.sort(self.noteParsers, compareByStartTime)
end

NoteChartImporter.stage2_process = function(self)
	self.foregroundLayerData:updateZeroTimePoint()
	
	local timePoint = self.foregroundLayerData:getTimePoint()
	timePoint.absoluteTime = 0
	local velocityData = ncdk.VelocityData:new(timePoint)
	self.foregroundLayerData:addVelocityData(velocityData)
	
	for _, timingPointParser in ipairs(self.timingPointParsers) do
		timingPointParser:stage2_process()
	end
	for _, noteParser in ipairs(self.noteParsers) do
		noteParser:stage2_process()
	end
end

NoteChartImporter.processLine = function(self, line)
	if line:find("^%[") then
		self.currentBlockName = line:match("^%[(.+)%]")
	else
		if line:find("^%a+:.*$") then
			local key, value = line:match("^(%a+):(.*)")
			self.metaData[key] = value
		elseif self.currentBlockName == "TimingPoints" and line:find("^.+,.+,.+,.+,.+,.+,.+,.+$") then
			self:stage1_addTimingPointParser(line)
		elseif self.currentBlockName == "HitObjects" and line:trim() ~= "" then
			self:stage1_addNoteParser(line)
		end
	end
end

NoteChartImporter.stage1_addTimingPointParser = function(self, line)
	local timingPointParser = osu.TimingPointParser:new()
	table.insert(self.timingPointParsers, timingPointParser)
	timingPointParser.noteChartImporter = self
	timingPointParser.line = line
	
	timingPointParser:stage1_process()
end

NoteChartImporter.stage1_addNoteParser = function(self, line)
	local noteParser = osu.NoteParser:new()
	table.insert(self.noteParsers, noteParser)
	noteParser.noteChartImporter = self
	noteParser.line = line
	
	noteParser:stage1_process()
end