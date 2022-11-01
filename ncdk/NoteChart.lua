local LayerDataSequence = require("ncdk.LayerDataSequence")
local InputMode = require("ncdk.InputMode")
local ResourceList = require("ncdk.ResourceList")

local NoteChart = {}

local mt = {__index = NoteChart}

function NoteChart:new()
	local noteChart = {}

	noteChart.layerDataSequence = LayerDataSequence:new()
	noteChart.layerDataSequence.noteChart = noteChart

	noteChart.inputMode = InputMode:new()
	noteChart.resourceList = ResourceList:new()

	return setmetatable(noteChart, mt)
end

function NoteChart:getLayerDataIndexIterator() return self.layerDataSequence:getLayerDataIndexIterator() end
function NoteChart:getInputIteraator() return self.layerDataSequence:getInputIteraator() end
function NoteChart:requireLayerData(...) return self.layerDataSequence:requireLayerData(...) end
function NoteChart:compute(...) return self.layerDataSequence:compute(...) end

function NoteChart:getResourceIterator(...) return self.resourceList:getIterator(...) end
function NoteChart:addResource(...) return self.resourceList:add(...) end

return NoteChart
