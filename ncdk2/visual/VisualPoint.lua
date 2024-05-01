local class = require("class")

---@class ncdk2.VisualPoint
---@operator call: ncdk2.VisualPoint
---@field _expand ncdk2.Expand?
---@field _velocity ncdk2.Velocity?
---@field velocity ncdk2.Velocity?
local VisualPoint = class()

VisualPoint.visualTime = 0
VisualPoint.section = 0
VisualPoint.currentSpeed = 1
VisualPoint.localSpeed = 1
VisualPoint.globalSpeed = 1

---@param point ncdk2.Point
function VisualPoint:new(point)
	self.point = point
end

---@param vp ncdk2.VisualPoint
---@return number
function VisualPoint:getVisualTime(vp)
	if self.section ~= vp.section then
		return (self.section - vp.section) / 0
	end
	local globalSpeed = vp.globalSpeed
	local localSpeed = self.localSpeed
	return (self.visualTime - vp.visualTime) * globalSpeed * localSpeed + vp.point.absoluteTime
end

---@param vp ncdk2.VisualPoint
---@return boolean
function VisualPoint:compare(vp)
	if self.section == vp.section then
		return self.visualTime < vp.visualTime
	end
	return self.section < vp.section
end

---@param a ncdk2.VisualPoint
---@return string
function VisualPoint.__tostring(a)
	return ("VisualPoint(%s)"):format(a.point)
end

return VisualPoint
