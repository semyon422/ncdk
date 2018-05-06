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
	
	setmetatable(noteChart, NoteChart_metatable)
	
	return noteChart
end

NoteChart.import = function(self, noteChartString)
	local noteChartImporter = osu.NoteChartImporter:new()
	noteChartImporter.noteChart = self
	noteChartImporter:import(noteChartString)
end

NoteChart.export = function(self)
	local noteChartExporter = osu.NoteChartExporter:new()
	noteChartExporter.noteChart = self
	return noteChartExporter:export()
end