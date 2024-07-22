local class = require("class")

---@class ncdk2.LinkedNote
---@operator call: ncdk2.LinkedNote
local LinkedNote = class()

---@param startNote ncdk2.Note
---@param endNote ncdk2.Note?
function LinkedNote:new(startNote, endNote)
	self.startNote = startNote
	self.endNote = endNote
end

function LinkedNote:clone()
	local note = setmetatable({}, LinkedNote)
	note.startNote = self.startNote:clone()
	note.endNote = self.endNote and self.endNote:clone()
	return note
end

function LinkedNote:getSize()
	return self.endNote and 2 or 1
end

---@return ncdk2.Column
function LinkedNote:getColumn()
	return self.startNote.column
end

---@param column ncdk2.Column
function LinkedNote:setColumn(column)
	self.startNote.column = column
	if self.endNote then
		self.endNote.column = column
	end
end

function LinkedNote:getType()
	return self.startNote.type
end

---@param _type string
function LinkedNote:setType(_type)
	self.startNote.type = _type
	if self.endNote then
		self.endNote.type = _type
	end
end

return LinkedNote
