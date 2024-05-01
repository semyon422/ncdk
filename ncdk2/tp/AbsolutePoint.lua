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

AbsolutePoint.__eq = Point.__eq
AbsolutePoint.__lt = Point.__lt
AbsolutePoint.__le = Point.__le

return AbsolutePoint
