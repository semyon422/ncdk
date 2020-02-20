local LayerDataSequence = require("ncdk.LayerDataSequence")
local InputMode = require("ncdk.InputMode")
local MetaData = require("ncdk.MetaData")
local ResourceList = require("ncdk.ResourceList")

local NoteChart = {}

local NoteChart_metatable = {}
NoteChart_metatable.__index = NoteChart

NoteChart.new = function(self)
	local noteChart = {}
	
	noteChart.layerDataSequence = LayerDataSequence:new()
	noteChart.layerDataSequence.noteChart = noteChart
	
	noteChart.inputMode = InputMode:new()
	noteChart.metaData = MetaData:new()
	noteChart.resourceList = ResourceList:new()

	noteChart.metaData.noteChart = noteChart
	
	setmetatable(noteChart, NoteChart_metatable)
	
	return noteChart
end

NoteChart.getLayerDataIndexIterator = function(self) return self.layerDataSequence:getLayerDataIndexIterator() end
NoteChart.getInputIteraator = function(self) return self.layerDataSequence:getInputIteraator() end
NoteChart.requireLayerData = function(self, ...) return self.layerDataSequence:requireLayerData(...) end

NoteChart.getResourceIterator = function(self, ...) return self.resourceList:getIterator(...) end
NoteChart.addResource = function(self, ...) return self.resourceList:add(...) end

NoteChart.compute = function(self, ...) return self.layerDataSequence:compute(...) end

return NoteChart
