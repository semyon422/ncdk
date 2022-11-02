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

	noteChart.inputCount = {}

	return setmetatable(noteChart, mt)
end

function NoteChart:getInputIterator()
	local inputs = {}
	for inputType, inputTypeData in pairs(self.inputCount) do
		for inputIndex in pairs(inputTypeData) do
			inputs[#inputs + 1] = {inputType, inputIndex}
		end
	end
	local counter = 1

	return function()
		local input = inputs[counter]
		if not input then return end
		counter = counter + 1
		return unpack(input)
	end
end

function NoteChart:increaseInputCount(inputType, inputIndex, value)
	local inputCount = self.inputCount
	inputCount[inputType] = inputCount[inputType] or {}
	local t = inputCount[inputType]
	t[inputIndex] = (t[inputIndex] or 0) + value
	assert(t[inputIndex] >= 0)
	if t[inputIndex] == 0 then
		t[inputIndex] = nil
	end
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
