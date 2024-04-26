local Layer = require("ncdk2.layers.Layer")
local AbsolutePoint = require("ncdk2.tp.AbsolutePoint")

---@class ncdk2.AbsoluteLayer: ncdk2.Layer
---@operator call: ncdk2.AbsoluteLayer
local AbsoluteLayer = Layer + {}

---@param tempo number
function AbsoluteLayer:setPrimaryTempo(tempo)
	assert(tempo >= 0, "Wrong primary tempo")
	self.primaryTempo = tempo
end

---@param time number
---@return ncdk2.AbsolutePoint
function AbsoluteLayer:newPoint(time)
	return AbsolutePoint(time)
end

---@param time number
---@return ncdk2.AbsolutePoint
function AbsoluteLayer:getPoint(time)
	---@type ncdk2.AbsolutePoint
	return Layer.getPoint(self, time)
end

function AbsoluteLayer:compute()
	local pointList = self:getPointList()
	Layer.compute(self)
end

return AbsoluteLayer
