local class = require("class")
local table_util = require("table_util")

---@alias ncdk2.NoteType string

---@class ncdk2.Note
---@operator call: ncdk2.Note
local Note = class()

Note.weight = 0

---@param visualPoint ncdk2.IVisualPoint
---@param column ncdk2.Column
---@param _type ncdk2.NoteType
---@param weight integer
function Note:new(visualPoint, column, _type, weight)
	self.visualPoint = assert(visualPoint, "missing visualPoint")
	self.column = assert(column, "missing column")
	self.type = _type
	self.weight = weight
end

---@return ncdk2.Note
function Note:clone()
	local note = setmetatable({}, Note)
	table_util.copy(self, note)
	return note
end

---@return number
function Note:getTime()
	return self.visualPoint.point.absoluteTime
end

---@param vp ncdk2.IVisualPoint?
---@return number
function Note:getVisualTime(vp)
	return self.visualPoint:getVisualTime(vp)
end

---@return number
function Note:getBeatModulo()
	local b = self.visualPoint.point:getBeatModulo()
	if type(b) == "number" then
		return b
	end
	return b:tonumber()
end

---@return number
function Note:getBeatDuration()
	return self.visualPoint.point:getBeatDuration()
end

---@param a ncdk2.Note
---@return string
function Note.__tostring(a)
	return ("Note(%s,%s,%s,%s)"):format(a.visualPoint, a.column, a.weight, a.type)
end

---@param a ncdk2.Note
---@param b ncdk2.Note
---@return boolean
function Note.__eq(a, b)
	return a.visualPoint == b.visualPoint and a.column == b.column
end

---@param a ncdk2.Note
---@param b ncdk2.Note
---@return boolean
function Note.__lt(a, b)
	return a.visualPoint < b.visualPoint or a.visualPoint == b.visualPoint and a.column < b.column
end

return Note
