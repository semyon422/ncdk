osu.NoteChart = {}
local NoteChart = osu.NoteChart

osu.NoteChart_metatable = {}
local NoteChart_metatable = osu.NoteChart_metatable
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
	self.noteChartImporter = osu.NoteChartImporter:new()
	self.noteChartImporter.noteChart = self
	self.noteChartImporter:import(noteChartString)
end

NoteChart.export = function(self)
	self.noteChartExporter = osu.NoteChartExporter:new()
	self.noteChartExporter.noteChart = self
	return self.noteChartExporter:export()
end