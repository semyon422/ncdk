local LayerData = require("ncdk.LayerData")

local LayerDataSequence = {}

local LayerDataSequence_metatable = {}
LayerDataSequence_metatable.__index = LayerDataSequence

LayerDataSequence.new = function(self)
	local layerDataSequence = {}
	
	layerDataSequence.layerDataCount = 0
	layerDataSequence.layerDataIndexes = {}
	layerDataSequence.inputCount = {}
	
	setmetatable(layerDataSequence, LayerDataSequence_metatable)
	
	return layerDataSequence
end

LayerDataSequence.requireLayerData = function(self, layerDataIndex)
	if not self[layerDataIndex] then
		self[layerDataIndex] = LayerData:new()
		self[layerDataIndex].layerDataSequence = self
		
		self.layerDataCount = self.layerDataCount + 1
		table.insert(self.layerDataIndexes, layerDataIndex)
	end
	
	return self[layerDataIndex]
end

LayerDataSequence.getLayerDataIndexIterator = function(self)
	local counter = 1
	
	return function()
		local layerDataIndex = self.layerDataIndexes[counter]
		
		counter = counter + 1
		
		return layerDataIndex
	end
end

LayerDataSequence.getInputIteraator = function(self)
	local inputs = {}
	for inputType, inputTypeData in pairs(self.inputCount) do
		for inputIndex, count in pairs(inputTypeData) do
			if count > 0 then
				inputs[#inputs + 1] = {inputType, inputIndex}
			end
		end
	end
	local counter = 1
	
	return function()
		local inputData = inputs[counter]
		if not inputData then return end
		
		counter = counter + 1
		
		return unpack(inputData)
	end
end

LayerDataSequence.increaseInputCount = function(self, inputType, inputIndex, value)
	local inputCount = self.inputCount
	inputCount[inputType] = inputCount[inputType] or {}
	inputCount[inputType][inputIndex] = (inputCount[inputType][inputIndex] or 0) + value
end

LayerDataSequence.compute = function(self)
	for layerDataIndex in self:getLayerDataIndexIterator() do
		self[layerDataIndex]:compute()
	end
end

return LayerDataSequence
