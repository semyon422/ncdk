local class = require("class")
local ffi = require("ffi")
local bit = require("bit")

---@class ncdk2.Point
---@operator call: ncdk2.Point
---@field absoluteTime number
local Point = class()

Point.absoluteTime = 0

---@param absoluteTime number
function Point:new(absoluteTime)
	self.absoluteTime = absoluteTime
end

local uint64_ptr = ffi.new("int64_t[1]")

---@type {[0]: number}
local double_ptr = ffi.cast("double*", uint64_ptr)

---@return string
function Point:getAbsoluteTimeKey()
	local time = self.absoluteTime
	double_ptr[0] = time
	return ("%s[%s]"):format(bit.tohex(uint64_ptr[0]), time)
end

---@param timePoint ncdk2.Point
---@return boolean
function Point:compare(timePoint)
	return self.absoluteTime < timePoint.absoluteTime
end

---@param a ncdk2.Point
---@return string
function Point.__tostring(a)
	return ("Point(%s)"):format(a.absoluteTime)
end

return Point
