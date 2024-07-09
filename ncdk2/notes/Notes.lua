local class = require("class")

---@alias ncdk2.Column string

---@class ncdk2.Notes
---@operator call: ncdk2.Notes
---@field notes ncdk2.Note[]
local Notes = class()

function Notes:new()
	self.notes = {}
	---@type {[ncdk2.VisualPoint]: {[ncdk2.Column]: ncdk2.Note}}
	self.point_notes = {}
end

---@return fun(t: ncdk2.Note[]): integer, ncdk2.Note
---@return ncdk2.Note[]
---@return integer
function Notes:iter()
	return ipairs(self.notes)
end

---@return {[ncdk2.Column]: ncdk2.Note[]}
function Notes:getColumnNotes()
	---@type {[ncdk2.Column]: ncdk2.Note[]}
	local column_notes = {}
	for _, note in self:iter() do
		local column = note.column
		column_notes[column] = column_notes[column] or {}
		table.insert(column_notes[column], note)
	end
	return column_notes
end

function Notes:sort()
	table.sort(self.notes)
end

---@param vp ncdk2.VisualPoint
---@param column ncdk2.Column
---@return ncdk2.Note?
function Notes:get(vp, column)
	local point_notes = self.point_notes
	local ps = point_notes[vp]
	if not ps then
		return
	end
	return ps[column]
end

---@param note ncdk2.Note
function Notes:insert(note)
	assert(note, "missing note")
	table.insert(self.notes, note)

	local column = note.column
	local vp = note.visualPoint
	---@cast vp ncdk2.VisualPoint

	local point_notes = self.point_notes
	point_notes[vp] = point_notes[vp] or {}
	local ps = point_notes[vp]
	if ps[column] then
		error(("column is not empty (vp: %s, col: %s)"):format(vp, column))
	end
	ps[column] = note
end

function Notes:validate()
	self:sort()

	---@type {[ncdk2.Column]: {[ncdk2.Note]: true}}
	local map = {}
	for _, note in self:iter() do
		local column = note.column
		map[column] = map[column] or {}
		map[column][note] = true
	end
	for _, note in self:iter() do
		local column = note.column
		if note.endNote and not map[column][note.endNote] then
			error(("missing endNote %s for note %s on column %s"):format(note.endNote, note, column))
		end
		if note.startNote and not map[column][note.startNote] then
			error(("missing startNote %s for note %s on column %s"):format(note.startNote, note, column))
		end
	end
end

return Notes
