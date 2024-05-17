local Layer = require("ncdk2.layers.Layer")
local AbsolutePoint = require("ncdk2.tp.AbsolutePoint")
local AbsoluteAbsolute = require("ncdk2.compute.AbsoluteAbsolute")

---@class ncdk2.AbsoluteLayer: ncdk2.Layer
---@operator call: ncdk2.AbsoluteLayer
local AbsoluteLayer = Layer + {}

function AbsoluteLayer:new()
	Layer.new(self)
	self.absoluteAbsolute = AbsoluteAbsolute()
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
	self.absoluteAbsolute:convert(pointList)
	Layer.compute(self)
end

return AbsoluteLayer
