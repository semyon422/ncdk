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

---@return ncdk2.AbsoluteTimePoint
function AbsoluteLayer:newTimePoint()
	return AbsoluteTimePoint()
end

---@param time number
---@return ncdk2.AbsoluteTimePoint
function AbsoluteLayer:getTimePoint(time)
	---@type ncdk2.AbsoluteTimePoint
	return Layer.getTimePoint(self, time)
end

return AbsoluteLayer
