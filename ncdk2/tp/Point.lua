local IPoint = require("ncdk2.tp.IPoint")
local ffi = require("ffi")
local bit = require("bit")

---@class ncdk2.Point: ncdk2.IPoint
---@operator call: ncdk2.Point
---@field absoluteTime number
local Point = IPoint + {}

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
	double_ptr[0] = self.absoluteTime
	return bit.tohex(uint64_ptr[0])
end

---@param point ncdk2.Point
---@return boolean
function Point:compare(point)
	return self.absoluteTime < point.absoluteTime
end

---@param a ncdk2.Point
---@return string
function Point.__tostring(a)
	return ("Point(%s)"):format(a.absoluteTime)
end

---@param a ncdk2.Point
---@param b ncdk2.Point
---@return boolean
function Point.__eq(a, b)
	return a.absoluteTime == b.absoluteTime
end

---@param a ncdk2.Point
---@param b ncdk2.Point
---@return boolean
function Point.__lt(a, b)
	return a.absoluteTime < b.absoluteTime
end

---@param a ncdk2.Point
---@param b ncdk2.Point
---@return boolean
function Point.__le(a, b)
	return a.absoluteTime <= b.absoluteTime
end

return Point
