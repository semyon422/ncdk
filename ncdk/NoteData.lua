local class = require("class")

---@class ncdk.NoteData
---@operator call: ncdk.NoteData
local NoteData = class()

NoteData.id = 0  -- for consistent sorting purposes only

---@param timePoint ncdk.TimePoint
function NoteData:new(timePoint)
	self.timePoint = timePoint
end

---@return ncdk.NoteData
function NoteData:clone()
	local noteData = setmetatable({}, NoteData)
	for k, v in pairs(self) do
		noteData[k] = v
	end
	return noteData
end

---@param a ncdk.TimePoint
---@return string
function NoteData.__tostring(a)
	return ("note %s"):format(a.timePoint)
end

---@param a ncdk.NoteData
---@param b ncdk.NoteData
---@return boolean
function NoteData.__eq(a, b)
	return a.timePoint == b.timePoint
end

---@param a ncdk.NoteData
---@param b ncdk.NoteData
---@return boolean
function NoteData.__lt(a, b)
	return a.timePoint < b.timePoint or a.timePoint == b.timePoint and a.id < b.id
end

---@param a ncdk.NoteData
---@param b ncdk.NoteData
---@return boolean
function NoteData.__le(a, b)
	return a.timePoint <= b.timePoint
end

return NoteData
