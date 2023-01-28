local InputMode = require("ncdk.InputMode")
local ResourceList = require("ncdk.ResourceList")
local LayerData = require("ncdk.LayerData")

local NoteChart = {}

local mt = {__index = NoteChart}

function NoteChart:new()
	local noteChart = {}

	noteChart.layerDatas = {}

	noteChart.inputMode = InputMode:new()
	noteChart.resourceList = ResourceList:new()

	return setmetatable(noteChart, mt)
end

function NoteChart:getInputIterator()
	return coroutine.wrap(function()
		for layerDataIndex, layerData in ipairs(self.layerDatas) do
			for inputType, r in pairs(layerData.noteDatas) do
				for inputIndex, noteDatas in pairs(r) do
					coroutine.yield(noteDatas, inputType, inputIndex, layerDataIndex)
				end
			end
		end
	end)
end

function NoteChart:getLayerDataIterator() return ipairs(self.layerDatas) end

function NoteChart:getLayerData(i)
	local layerDatas = self.layerDatas

	if not layerDatas[i] then
		assert(i == #layerDatas + 1)
		layerDatas[i] = LayerData:new()
		layerDatas[i].noteChart = self
	end

	return layerDatas[i]
end

function NoteChart:compute()
	for _, layerData in ipairs(self.layerDatas) do
		layerData:compute()
	end
end

function NoteChart:getResourceIterator(...) return self.resourceList:getIterator(...) end
function NoteChart:addResource(...) return self.resourceList:add(...) end

return NoteChart
