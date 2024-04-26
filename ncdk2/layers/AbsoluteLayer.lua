local Layer = require("ncdk2.layers.Layer")
local AbsoluteTimePoint = require("ncdk2.tp.AbsoluteTimePoint")

---@class ncdk2.AbsoluteLayer: ncdk2.Layer
---@operator call: ncdk2.AbsoluteLayer
local AbsoluteLayer = Layer + {}

---@param tempo number
function AbsoluteLayer:setPrimaryTempo(tempo)
	assert(tempo >= 0, "Wrong primary tempo")
	self.primaryTempo = tempo
end

---@param time number
---@return ncdk2.AbsoluteTimePoint
function AbsoluteLayer:newTimePoint(time)
	return AbsoluteTimePoint(time)
end

---@param time number
---@return ncdk2.AbsoluteTimePoint
function AbsoluteLayer:getTimePoint(time)
	---@type ncdk2.AbsoluteTimePoint
	return Layer.getTimePoint(self, time)
end

function AbsoluteLayer:compute()
	local timePointList = self:getTimePointList()
	Layer.compute(self)
end

return AbsoluteLayer
