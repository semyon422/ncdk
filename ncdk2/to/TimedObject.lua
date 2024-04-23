local class = require("class")

---@class ncdk2.TimedObject
---@operator call: ncdk2.TimedObject
local TimedObject = class()

---@param timePoint ncdk2.TimePoint
function TimedObject:new(timePoint)
	self.timePoint = timePoint
end

---@param a ncdk2.TimedObject
---@param b ncdk2.TimedObject
---@return boolean
function TimedObject.__eq(a, b)
	return a.timePoint == b.timePoint
end

---@param a ncdk2.TimedObject
---@param b ncdk2.TimedObject
---@return boolean
function TimedObject.__lt(a, b)
	return a.timePoint < b.timePoint
end

---@param a ncdk2.TimedObject
---@param b ncdk2.TimedObject
---@return boolean
function TimedObject.__le(a, b)
	return a.timePoint <= b.timePoint
end

return TimedObject
