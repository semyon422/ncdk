local class = require("class")

---@class ncdk2.Notes
---@operator call: ncdk2.Notes
---@field data {[string]: {[number]: ncdk2.Note[]}}
local Notes = class()

function Notes:new()
	self.data = {}
end

function Notes:sort()
	for _, r in pairs(self.data) do
		for _, notes in pairs(r) do
			table.sort(notes)
		end
	end
end

---@param note ncdk2.Note
---@param inputType string
---@param inputIndex number
function Notes:addNote(note, inputType, inputIndex)
	local notes = self:getNotesList(inputType, inputIndex)
	table.insert(notes, note)
	note.id = #notes
end

---@param inputType string
---@param inputIndex number
---@return ncdk2.Note[]
function Notes:getNotesList(inputType, inputIndex)
	local data = self.data
	data[inputType] = data[inputType] or {}
	data[inputType][inputIndex] = data[inputType][inputIndex] or {}
	return data[inputType][inputIndex]
end

return Notes
