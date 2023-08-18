local class = require("class")

---@class ncdk.StopData
---@operator call: ncdk.StopData
local StopData = class()

---@param duration number|ncdk.Fraction
---@param isAbsolute boolean?
function StopData:new(duration, isAbsolute)
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

---@param a ncdk.StopData
---@param b ncdk.StopData
---@return boolean
function StopData.__eq(a, b)
	return a.timePoint == b.timePoint
end

---@param a ncdk.StopData
---@param b ncdk.StopData
---@return boolean
function StopData.__lt(a, b)
	return a.timePoint < b.timePoint
end

---@param a ncdk.StopData
---@param b ncdk.StopData
---@return boolean
function StopData.__le(a, b)
	return a.timePoint <= b.timePoint
end

return StopData
