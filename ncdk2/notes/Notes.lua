local class = require("class")
local LinkedNote = require("ncdk2.notes.LinkedNote")

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

---@return ncdk2.Note[]
function Notes:getNotes()
	return self.notes
end

---@return ncdk2.LinkedNote[]
function Notes:getLinkedNotes()
	return self:link(self.notes)
end

---@return {[ncdk2.Column]: ncdk2.Note[]}
function Notes:getColumnNotes()
	---@type {[ncdk2.Column]: ncdk2.Note[]}
	local _notes = {}
	for _, note in self:iter() do
		local column = note.column
		_notes[column] = _notes[column] or {}
		table.insert(_notes[column], note)
	end
	return _notes
end

---@return {[ncdk2.Column]: ncdk2.LinkedNote[]}
function Notes:getColumnLinkedNotes()
	---@type {[ncdk2.Column]: ncdk2.LinkedNote[]}
	local _notes = {}
	for column, notes in pairs(self:getColumnNotes()) do
		_notes[column] = self:link(notes)
	end
	return _notes
end

function Notes:sort()
	table.sort(self.notes)
end

---@param vp ncdk2.IVisualPoint
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
		error(("column is not empty: %s"):format(note))
	end
	ps[column] = note
end

---@param note ncdk2.LinkedNote
function Notes:insertLinked(note)
	self:insert(note.startNote)
	if note.endNote then
		self:insert(note.endNote)
	end
end

function Notes:isValid()
	---@type {[ncdk2.Column]: {[ncdk2.Note]: true}}
	local map = {}
	for _, note in self:iter() do
		local column = note.column
		map[column] = map[column] or {}
		map[column][note] = true
	end

	---@type {[ncdk2.Column]: {[ncdk2.NoteType]: integer}}
	local weights = {}

	for _, note in self:iter() do
		local column = note.column
		local _type = note.type
		weights[column] = weights[column] or {}
		weights[column][_type] = (weights[column][_type] or 0) + note.weight
	end

	local errors = {}
	for column, t in pairs(weights) do
		for _type, weight in pairs(t) do
			if weight ~= 0 then
				table.insert(errors, ("%s:%s"):format(column, _type))
			end
		end
	end
	if #errors == 0 then
		return true
	end
	return false, "non-zero weights in " .. table.concat(errors, ", ")
end

---@param notes ncdk2.Note[]
---@return ncdk2.LinkedNote[]
function Notes:link(notes)
	---@type ncdk2.LinkedNote[]
	local lnotes = {}

	---@type {[ncdk2.Column]: {[ncdk2.NoteType]: integer[]}}
	local istack = {}

	for _, note in ipairs(notes) do
		if note.weight == 0 then
			table.insert(lnotes, LinkedNote(note))
		elseif note.weight == 1 then
			table.insert(lnotes, LinkedNote(note))
			local c, t = note.column, note.type
			istack[c] = istack[c] or {}
			istack[c][t] = istack[c][t] or {}
			table.insert(istack[c][t], #lnotes)
		elseif note.weight == -1 then
			local c, t = note.column, note.type
			local index = table.remove(istack[c][t])
			lnotes[index].endNote = note
		end
	end

	return lnotes
end

return Notes
