local class = require("class")
local InputMode = require("ncdk.InputMode")
local ResourceList = require("ncdk.ResourceList")
local LayerData = require("ncdk.LayerData")

---@class ncdk.NoteChart
---@operator call: ncdk.NoteChart
local NoteChart = class()

function NoteChart:new()
	self.layerDatas = {}
	self.inputMode = InputMode()
	self.resourceList = ResourceList()
end

---@return function
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

---@return function
---@return table
---@return number
function NoteChart:getLayerDataIterator() return ipairs(self.layerDatas) end

---@param i number
---@return ncdk.LayerData
function NoteChart:getLayerData(i)
	local layerDatas = self.layerDatas

	if not layerDatas[i] then
		assert(i == #layerDatas + 1)
		layerDatas[i] = LayerData()
		layerDatas[i].noteChart = self
	end

	return layerDatas[i]
end

function NoteChart:compute()
	for _, layerData in ipairs(self.layerDatas) do
		layerData:compute()
	end
end

---@return function
function NoteChart:getResourceIterator()
	return self.resourceList:getIterator()
end

---@param type string
---@param name string
---@param sequence table
function NoteChart:addResource(type, name, sequence) self.resourceList:add(type, name, sequence) end

return NoteChart
