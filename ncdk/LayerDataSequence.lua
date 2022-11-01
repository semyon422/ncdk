local LayerData = require("ncdk.LayerData")

local LayerDataSequence = {}

local mt = {__index = LayerDataSequence}

function LayerDataSequence:new()
	return setmetatable({}, mt)
end

function LayerDataSequence:getLayerData(i)
	if not self[i] then
		assert(i == #self + 1)
		self[i] = LayerData:new()
		self[i].noteChart = self.noteChart
	end

	return self[i]
end

function LayerDataSequence:compute()
	for layerDataIndex in ipairs(self) do
		self[layerDataIndex]:compute()
	end
end

return LayerDataSequence
