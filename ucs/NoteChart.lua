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
	local noteChartImporter = ucs.NoteChartImporter:new()
	noteChartImporter.noteChart = self
	noteChartImporter:import(noteChartString)
end

NoteChart.export = function(self)
	local noteChartExporter = ucs.NoteChartExporter:new()
	noteChartExporter.noteChart = self
	return noteChartExporter:export()
end