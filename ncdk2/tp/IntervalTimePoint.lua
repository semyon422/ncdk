local TimePoint = require("ncdk2.tp.TimePoint")
local Fraction = require("ncdk.Fraction")

---@class ncdk2.IntervalTimePoint: ncdk2.TimePoint
---@operator call: ncdk2.IntervalTimePoint
---@field _measureData ncdk2.MeasureData?
---@field measureData ncdk2.MeasureData?
---@field _intervalData ncdk2.IntervalData?
---@field intervalData ncdk2.IntervalData?
local IntervalTimePoint = TimePoint + {}

---@param time ncdk.Fraction
function IntervalTimePoint:new(time)
	self.time = time
end

---@return ncdk.Fraction
function IntervalTimePoint:getBeatModulo()
	local measureData = self.measureData
	if not measureData then
		return self.time % 1
	end
	return (self.time - measureData.timePoint.time + measureData.start) % 1
end

---@return number
function IntervalTimePoint:tonumber()
	local id = self.intervalData
	if not id then
		return 0
	end
	if id:isSingle() then
		return id.offset
	end
	local a, b, offset = id:getPair()
	local ta = a.offset
	local time = self.time:tonumber() - a:time():tonumber()
	return ta + a:getBeatDuration() * time
end

---@param a ncdk2.IntervalTimePoint
---@return string
function IntervalTimePoint.__tostring(a)
	return ("IntervalTimePoint(%s)"):format(a.time)
end

---@param a ncdk2.IntervalTimePoint
---@param b ncdk2.IntervalTimePoint
---@return boolean
function IntervalTimePoint.__eq(a, b)
	return a.time == b.time
end

---@param a ncdk2.IntervalTimePoint
---@param b ncdk2.IntervalTimePoint
---@return boolean
function IntervalTimePoint.__lt(a, b)
	return a.time < b.time
end

---@param a ncdk2.IntervalTimePoint
---@param b ncdk2.IntervalTimePoint
---@return boolean
function IntervalTimePoint.__le(a, b)
	return a.time <= b.time
end

return IntervalTimePoint
