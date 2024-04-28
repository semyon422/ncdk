local Point = require("ncdk2.tp.Point")

---@class ncdk2.AbsolutePoint: ncdk2.Point
---@operator call: ncdk2.AbsolutePoint
---@field _tempo ncdk2.Tempo?
---@field tempo ncdk2.Tempo?
local AbsolutePoint = Point + {}

---@param a ncdk2.AbsolutePoint
---@return string
function AbsolutePoint.__tostring(a)
	return ("AbsolutePoint(%s)"):format(a.absoluteTime)
end

---@param a ncdk2.AbsolutePoint
---@param b ncdk2.AbsolutePoint
---@return boolean
function AbsolutePoint.__eq(a, b)
	return a.absoluteTime == b.absoluteTime
end

---@param a ncdk2.AbsolutePoint
---@param b ncdk2.AbsolutePoint
---@return boolean
function AbsolutePoint.__lt(a, b)
	return a.absoluteTime < b.absoluteTime
end

---@param a ncdk2.AbsolutePoint
---@param b ncdk2.AbsolutePoint
---@return boolean
function AbsolutePoint.__le(a, b)
	return a.absoluteTime <= b.absoluteTime
end

return AbsolutePoint
