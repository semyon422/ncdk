local Layer = require("ncdk2.layers.Layer")
local IntervalPoint = require("ncdk2.tp.IntervalPoint")
local IntervalAbsolute = require("ncdk2.conv.IntervalAbsolute")

---@class ncdk2.IntervalLayer: ncdk2.Layer
---@operator call: ncdk2.IntervalLayer
local IntervalLayer = Layer + {}

function IntervalLayer:new()
	Layer.new(self)
	self.intervalAbsolute = IntervalAbsolute()
end

---@param time ncdk.Fraction
---@return ncdk2.IntervalPoint
function IntervalLayer:newPoint(time)
	return IntervalPoint(time)
end

---@param time ncdk.Fraction
---@return ncdk2.IntervalPoint
function IntervalLayer:getPoint(time)
	---@type ncdk2.IntervalPoint
	return Layer.getPoint(self, time)
end

function IntervalLayer:compute()
	local timePointList = self:getPointList()
	self.intervalAbsolute:convert(timePointList)
	Layer.compute(self)
end

return IntervalLayer
