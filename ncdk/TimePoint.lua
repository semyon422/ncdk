local ffi = require("ffi")
local bit = require("bit")
local class = require("class")

---@class ncdk.TimePoint
---@operator call: ncdk.TimePoint
---@field expandData ncdk.ExpandData?
---@field tempoData ncdk.TempoData?
---@field velocityData ncdk.VelocityData?
---@field absoluteTime number
local TimePoint = class()

TimePoint.visualTime = 0
TimePoint.visualSection = 0
TimePoint.currentSpeed = 1
TimePoint.localSpeed = 1
TimePoint.globalSpeed = 1

---@param timePoint ncdk.TimePoint?
---@return ncdk.TimePoint
function TimePoint:clone(timePoint)
	assert(not rawequal(self, timePoint), "not allowed to clone to itself")
	timePoint = timePoint or TimePoint()
	setmetatable(timePoint, getmetatable(self))
	for k, v in pairs(timePoint) do
		timePoint[k] = nil
	end
	for k, v in pairs(self) do
		timePoint[k] = v
	end
	return timePoint
end

local uint64_ptr = ffi.new("int64_t[1]")
local double_ptr = ffi.cast("double*", uint64_ptr)

---@return string
function TimePoint:getAbsoluteTimeKey()
	local time = self.absoluteTime
	double_ptr[0] = time
	return ("%s[%s]"):format(bit.tohex(uint64_ptr[0]), time)
end

---@param timePoint ncdk.TimePoint
---@return number
function TimePoint:getVisualTime(timePoint)
	if self.visualSection ~= timePoint.visualSection then
		return (self.visualSection - timePoint.visualSection) / 0
	end
	local globalSpeed = timePoint.globalSpeed
	local localSpeed = self.localSpeed
	return (self.visualTime - timePoint.visualTime) * globalSpeed * localSpeed + timePoint.absoluteTime
end

---@param timePoint ncdk.TimePoint
---@param mode string
---@return boolean
function TimePoint:compare(timePoint, mode)
	assert(mode, "missing mode")
	if mode == "visual" then
		if self.visualSection == timePoint.visualSection then
			return self.visualTime < timePoint.visualTime
		end
		return self.visualSection < timePoint.visualSection
	elseif mode == "absolute" then
		return self.absoluteTime < timePoint.absoluteTime
	end
	error("Invalid mode")
end

return TimePoint
