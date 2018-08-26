ucs.NoteChart = {}
local NoteChart = ucs.NoteChart

ucs.NoteChart_metatable = {}
local NoteChart_metatable = ucs.NoteChart_metatable
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

NoteChart.import = function(self, noteChartString)
	self.noteChartImporter = ucs.NoteChartImporter:new()
	self.noteChartImporter.noteChart = self
	self.noteChartImporter:import(noteChartString)
end

NoteChart.export = function(self)
	self.noteChartExporter = ucs.NoteChartExporter:new()
	self.noteChartExporter.noteChart = self
	return self.noteChartExporter:export()
end