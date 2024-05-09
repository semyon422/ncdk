local class = require("class")

---@class ncdk2.Note
---@operator call: ncdk2.Note
local Note = class()

---@param visualPoint ncdk2.VisualPoint
function Note:new(visualPoint)
	self.visualPoint = visualPoint
end

---@param a ncdk2.Note
---@return string
function Note.__tostring(a)
	return ("Note(%s)"):format(a.visualPoint)
end

---@param a ncdk2.Note
---@param b ncdk2.Note
---@return boolean
function Note.__eq(a, b)
	return a.visualPoint.point == b.visualPoint.point
end

---@param a ncdk2.Note
---@param b ncdk2.Note
---@return boolean
function Note.__lt(a, b)
	return a.visualPoint.point < b.visualPoint.point
end

---@param a ncdk2.Note
---@param b ncdk2.Note
---@return boolean
function Note.__le(a, b)
	return a.visualPoint.point <= b.visualPoint.point
end

return Note
