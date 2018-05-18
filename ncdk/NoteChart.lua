ncdk.NoteChart = {}
local NoteChart = ncdk.NoteChart

ncdk.NoteChart_metatable = {}
local NoteChart_metatable = ncdk.NoteChart_metatable
NoteChart_metatable.__index = NoteChart

NoteChart.new = function(self)
	local noteChart = {}
	
	noteChart.layerDataSequence = ncdk.LayerDataSequence:new()
	noteChart.layerDataSequence.noteChart = noteChart
	
	noteChart.inputMode = ncdk.InputMode:new()
	noteChart.metaData = ncdk.MetaData:new()
	
	setmetatable(noteChart, NoteChart_metatable)
	
	return noteChart
end

NoteChart.getLayerDataIndexIterator = function(self) return self.layerDataSequence:getLayerDataIndexIterator() end
NoteChart.getInputIteraator = function(self) return self.layerDataSequence:getInputIteraator() end
NoteChart.requireLayerData = function(self, ...) return self.layerDataSequence:requireLayerData(...) end

NoteChart.hashSet = function(self, ...) self.metaData:hashSet(...) end
NoteChart.hashGet = function(self, ...) self.metaData:hashGet(...) end