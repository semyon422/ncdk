local class = require("class")

---@class ncdk2.NoteData
---@operator call: ncdk2.NoteData
local NoteData = class()

-- !!! delete this, there should be only one inputType-inputIndex note per time point
NoteData.id = 0  -- for consistent sorting purposes only

---@param visualTimePoint ncdk2.VisualTimePoint
function NoteData:new(visualTimePoint)
	self.visualTimePoint = visualTimePoint
end

---@param a ncdk2.NoteData
---@return string
function NoteData.__tostring(a)
	return ("NoteData(%s)"):format(a.visualTimePoint)
end

---@param a ncdk2.NoteData
---@param b ncdk2.NoteData
---@return boolean
function NoteData.__eq(a, b)
	return a.visualTimePoint.timePoint == b.visualTimePoint.timePoint
end

---@param a ncdk2.NoteData
---@param b ncdk2.NoteData
---@return boolean
function NoteData.__lt(a, b)
	return a.visualTimePoint.timePoint < b.visualTimePoint.timePoint
end

---@param a ncdk2.NoteData
---@param b ncdk2.NoteData
---@return boolean
function NoteData.__le(a, b)
	return a.visualTimePoint.timePoint <= b.visualTimePoint.timePoint
end

return NoteData
