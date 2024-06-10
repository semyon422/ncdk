local IVisualPoint = require("ncdk2.visual.IVisualPoint")

---@class chartedit.VisualPoint: ncdk2.IVisualPoint
---@operator call: chartedit.VisualPoint
---@field prev chartedit.VisualPoint?
---@field next chartedit.VisualPoint?
---@field _expand ncdk2.Expand?
---@field _velocity ncdk2.Velocity?
local VisualPoint = IVisualPoint + {}

---@param point chartedit.Point
function VisualPoint:new(point)
	self.point = point
end

---@param a chartedit.VisualPoint
---@return string
function VisualPoint.__tostring(a)
	return ("VisualPoint(%s)"):format(a.point)
end

---@param vp chartedit.VisualPoint?
---@return number
function VisualPoint:getVisualTime(vp)
	return self.point.absoluteTime
end

return VisualPoint
