local TimedObject = require("ncdk2.to.TimedObject")

---@class ncdk2.StopData: ncdk2.TimedObject
---@operator call: ncdk2.StopData
local StopData = TimedObject + {}

---@param timePoint ncdk2.TimePoint
---@param duration number|ncdk.Fraction
---@param isAbsolute boolean?
function StopData:new(timePoint, duration, isAbsolute)
	TimedObject.new(self, timePoint)
	self.duration = duration
	self.isAbsolute = isAbsolute
end

---@param duration number|ncdk.Fraction
---@return boolean
function StopData:set(duration)
	local _duration = self.duration
	self.duration = duration
	return _duration ~= duration
end

---@param a ncdk.StopData
---@return string
function StopData.__tostring(a)
	return tostring(a.timePoint) .. "," .. a.duration
end

StopData.__eq = TimedObject.__eq
StopData.__lt = TimedObject.__lt
StopData.__le = TimedObject.__le

return StopData
