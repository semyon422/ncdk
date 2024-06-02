local class = require("class")

---@class chartedit.VisualPoint
---@operator call: chartedit.VisualPoint
---@field prev chartedit.VisualPoint?
---@field next chartedit.VisualPoint?
local VisualPoint = class()

---@param point chartedit.Point
function VisualPoint:new(point)
	self.point = point
end

---@param a chartedit.VisualPoint
---@return string
function VisualPoint.__tostring(a)
	return ("VisualPoint(%s)"):format(a.point)
end

return VisualPoint
