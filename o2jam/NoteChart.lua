o2jam.NoteChart = {}
local NoteChart = o2jam.NoteChart

o2jam.NoteChart_metatable = {}
local NoteChart_metatable = o2jam.NoteChart_metatable
NoteChart_metatable.__index = NoteChart

setmetatable(NoteChart, ncdk.NoteChart_metatable)

NoteChart.new = function(self)
	local noteChart = {}
	
	noteChart.layerDataSequence = ncdk.LayerDataSequence:new()
	noteChart.layerDataSequence.noteChart = noteChart
	
	noteChart.inputMode = ncdk.InputMode:new()
	noteChart.metaData = ncdk.MetaData:new()
	
	setmetatable(noteChart, NoteChart_metatable)
	
	return noteChart
end

NoteChart.import = function(self, noteChartString, chartIndex)
	self.noteChartImporter = o2jam.NoteChartImporter:new()
	self.noteChartImporter.noteChart = self
	self.noteChartImporter.chartIndex = chartIndex or 1
	self.noteChartImporter:import(noteChartString)
end

NoteChart.export = function(self)
	self.noteChartExporter = o2jam.NoteChartExporter:new()
	self.noteChartExporter.noteChart = self
	return self.noteChartExporter:export()
end