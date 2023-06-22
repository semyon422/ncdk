local ffi = require("ffi")
local bit = require("bit")

local TimePoint = {}

TimePoint.visualTime = 0
TimePoint.visualSection = 0

function TimePoint:new()
	self.__index = self
	return setmetatable({}, self)
end

function TimePoint:clone(timePoint)
	assert(not rawequal(self, timePoint), "not allowed to clone to itself")
	timePoint = timePoint or TimePoint:new()
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
function TimePoint:getAbsoluteTimeKey()
	local time = self.absoluteTime
	double_ptr[0] = time
	return ("%s[%s]"):format(bit.tohex(uint64_ptr[0]), time)
end

function TimePoint:getVisualTime(timePoint)
	if self.visualSection ~= timePoint.visualSection then
		return (self.visualSection - timePoint.visualSection) / 0
	end
	local globalSpeed = timePoint.velocityData and timePoint.velocityData.globalSpeed or 1
	local localSpeed = self.velocityData and self.velocityData.localSpeed or 1
	return (self.visualTime - timePoint.visualTime) * globalSpeed * localSpeed + timePoint.absoluteTime
end

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
end

return TimePoint
