local TimePoint = require("ncdk2.tp.TimePoint")

---@class ncdk2.AbsoluteTimePoint: ncdk2.TimePoint
---@operator call: ncdk2.AbsoluteTimePoint
---@field tempoData ncdk2.TempoData?
local AbsoluteTimePoint = TimePoint + {}

---@param a ncdk2.AbsoluteTimePoint
---@return string
function AbsoluteTimePoint.__tostring(a)
	return ("AbsoluteTimePoint(%s)"):format(a.absoluteTime)
end

---@param a ncdk2.AbsoluteTimePoint
---@param b ncdk2.AbsoluteTimePoint
---@return boolean
function AbsoluteTimePoint.__eq(a, b)
	return a.absoluteTime == b.absoluteTime
end

---@param a ncdk2.AbsoluteTimePoint
---@param b ncdk2.AbsoluteTimePoint
---@return boolean
function AbsoluteTimePoint.__lt(a, b)
	return a.absoluteTime < b.absoluteTime
end

---@param a ncdk2.AbsoluteTimePoint
---@param b ncdk2.AbsoluteTimePoint
---@return boolean
function AbsoluteTimePoint.__le(a, b)
	return a.absoluteTime <= b.absoluteTime
end

return AbsoluteTimePoint
