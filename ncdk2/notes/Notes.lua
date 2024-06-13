local class = require("class")

---@alias ncdk2.Column string

---@class ncdk2.Notes
---@operator call: ncdk2.Notes
---@field column_notes {[ncdk2.Column]: ncdk2.Note[]}
local Notes = class()

function Notes:new()
	self.column_notes = {}
end

---@return fun(t: {[ncdk2.Column]: ncdk2.Note[]}, k?: ncdk2.Column): ncdk2.Column, ncdk2.Note[]
---@return {[ncdk2.Column]: ncdk2.Note[]}
function Notes:iter()
	return next, self.column_notes
end

function Notes:sort()
	for _, notes in self:iter() do
		table.sort(notes)
	end
end

---@param note ncdk2.Note
---@param column ncdk2.Column
function Notes:insert(note, column)
	local notes = self.column_notes
	notes[column] = notes[column] or {}
	table.insert(notes[column], note)
end

return Notes
