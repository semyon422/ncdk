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
	assert(note, "missing note")
	local notes = self.column_notes
	notes[column] = notes[column] or {}
	table.insert(notes[column], note)
end

---@return {[ncdk2.VisualPoint]: {[ncdk2.Column]: ncdk2.Note}}
function Notes:getPointNotes()
	---@type {[ncdk2.VisualPoint]: {[ncdk2.Column]: ncdk2.Note}}
	local point_notes = {}
	for column, notes in self:iter() do
		for _, note in ipairs(notes) do
			local vp = note.visualPoint
			---@cast vp ncdk2.VisualPoint

			point_notes[vp] = point_notes[vp] or {}
			local nds = point_notes[vp]
			if nds[column] then
				error(("column is not empty (vp: %s, col: %s, old: %s, new: %s)"):format(
					vp, column, nds[column], note
				))
			end
			nds[column] = note
		end
	end
	return point_notes
end

function Notes:validate()
	self:sort()
	self:getPointNotes()  -- one Note per (VisualPoint, Column)

	for column, notes in self:iter() do
		---@type {[ncdk2.Note]: true}
		local map = {}
		for _, note in ipairs(notes) do
			map[note] = true
		end
		for _, note in ipairs(notes) do
			if note.endNote and not map[note.endNote] then
				error(("missing endNote %s for note %s on column %s"):format(note.endNote, note, column))
			end
			if note.startNote and not map[note.startNote] then
				error(("missing startNote %s for note %s on column %s"):format(note.startNote, note, column))
			end
		end
	end
end

return Notes
