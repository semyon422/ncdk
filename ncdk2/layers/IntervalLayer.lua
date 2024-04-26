local Layer = require("ncdk2.layers.Layer")
local IntervalTimePoint = require("ncdk2.tp.IntervalTimePoint")
local IntervalAbsolute = require("ncdk2.conv.IntervalAbsolute")
local Visual = require("ncdk2.visual.Visual")

---@class ncdk2.IntervalLayer: ncdk2.Layer
---@operator call: ncdk2.IntervalLayer
local IntervalLayer = Layer + {}

function IntervalLayer:new()
	Layer.new(self)
	self.intervalAbsolute = IntervalAbsolute()
	self.visual = Visual()
end

---@param time ncdk.Fraction
---@return ncdk2.IntervalTimePoint
function IntervalLayer:newTimePoint(time)
	return IntervalTimePoint(time)
end

---@param time ncdk.Fraction
---@return ncdk2.IntervalTimePoint
function IntervalLayer:getTimePoint(time)
	---@type ncdk2.IntervalTimePoint
	return Layer.getTimePoint(self, time)
end

function IntervalLayer:computeTimePoints()
	local timePointList = self:getTimePointList()
	self.intervalAbsolute:convert(timePointList)

	self.visual:compute(self.visualTimePoints)
end

return IntervalLayer
