local class = require("class")

---@class ncdk2.Notes
---@operator call: ncdk2.Notes
---@field column_notes {[number]: ncdk2.Note[]}
local Notes = class()

function Notes:new()
	self.column_notes = {}
end

---@return fun(table: {[number]: ncdk2.Note[]}, index?: number):number, ncdk2.Note[]
---@return {[number]: ncdk2.Note[]}
function Notes:iter()
	return next, self.column_notes
end

function Notes:sort()
	for _, notes in self:iter() do
		table.sort(notes)
	end
end

---@param note ncdk2.Note
---@param column number
function Notes:insert(note, column)
	local notes = self.column_notes
	notes[column] = notes[column] or {}
	table.insert(notes[column], note)
end

return Notes
