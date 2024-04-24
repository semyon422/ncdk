local TimedObject = require("ncdk2.to.TimedObject")
local Fraction = require("ncdk.Fraction")

---@class ncdk2.MeasureData: ncdk2.TimedObject
---@operator call: ncdk2.MeasureData
---@field timePoint ncdk2.IntervalTimePoint
local MeasureData = TimedObject + {}

MeasureData.start = Fraction(0)

---@param start ncdk.Fraction?
function MeasureData:new(start)
	self.start = start
end

---@param start ncdk.Fraction
---@return boolean
function MeasureData:set(start)
	local _start = self.start
	self.start = start
	return _start ~= start
end

---@param a ncdk.MeasureData
---@return string
function MeasureData.__tostring(a)
	return tostring(a.timePoint) .. "," .. a.start
end

MeasureData.__eq = TimedObject.__eq
MeasureData.__lt = TimedObject.__lt
MeasureData.__le = TimedObject.__le

return MeasureData
