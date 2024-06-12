local class = require("class")
local table_util = require("table_util")

---@class ncdk2.Note
---@operator call: ncdk2.Note
local Note = class()

---@param visualPoint ncdk2.IVisualPoint
function Note:new(visualPoint)
	self.visualPoint = visualPoint
end

---@return ncdk2.Note
function Note:clone()
	local note = Note()
	table_util.copy(self, note)
	return note
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
	return a.visualPoint == b.visualPoint
end

---@param a ncdk2.Note
---@param b ncdk2.Note
---@return boolean
function Note.__lt(a, b)
	return a.visualPoint < b.visualPoint
end

---@param a ncdk2.Note
---@param b ncdk2.Note
---@return boolean
function Note.__le(a, b)
	return a.visualPoint <= b.visualPoint
end

return Note
