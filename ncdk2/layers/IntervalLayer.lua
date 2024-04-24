local Layer = require("ncdk2.layers.Layer")
local IntervalTimePoint = require("ncdk2.tp.IntervalTimePoint")

---@class ncdk2.IntervalLayer: ncdk2.Layer
---@operator call: ncdk2.IntervalLayer
local IntervalLayer = Layer + {}

---@return ncdk2.IntervalTimePoint
function IntervalLayer:newTimePoint()
	return IntervalTimePoint()
end

---@param intervalData ncdk2.IntervalData
---@param time ncdk.Fraction
---@return ncdk2.IntervalTimePoint
function IntervalLayer:getTimePoint(intervalData, time)
	---@type ncdk2.IntervalTimePoint
	return Layer.getTimePoint(self, intervalData, time)
end

return IntervalLayer
