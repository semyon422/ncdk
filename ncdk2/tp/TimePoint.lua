local class = require("class")
local ffi = require("ffi")
local bit = require("bit")

---@class ncdk2.TimePoint
---@operator call: ncdk2.TimePoint
---@field absoluteTime number
local TimePoint = class()

TimePoint.absoluteTime = 0

local uint64_ptr = ffi.new("int64_t[1]")
local double_ptr = ffi.cast("double*", uint64_ptr)

---@return string
function TimePoint:getAbsoluteTimeKey()
	local time = self.absoluteTime
	double_ptr[0] = time
	return ("%s[%s]"):format(bit.tohex(uint64_ptr[0]), time)
end

return TimePoint
