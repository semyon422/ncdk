local class = require("class")

---@class ncdk2.NoteCloner
---@operator call: ncdk2.NoteCloner
local NoteCloner = class()

function NoteCloner:new()
	---@type {[ncdk2.Note]: ncdk2.Note}
	self.startNotes = {}
	---@type {[ncdk2.Note]: ncdk2.Note}
	self.endNotes = {}
	---@type {[ncdk2.Note]: ncdk2.Note}
	self.notes_map = {}
end

---@param _note ncdk2.Note
function NoteCloner:clone(_note)
	local note = _note:clone()
	if _note.startNote then
		note.startNote = nil
		self.startNotes[note] = _note.startNote
	end
	if _note.endNote then
		note.endNote = nil
		self.endNotes[note] = _note.endNote
	end
	self.notes_map[_note] = note
	return note
end

function NoteCloner:assignStartEnd()
	local notes_map = self.notes_map
	for note, _startNote in pairs(self.startNotes) do
		note.startNote = notes_map[_startNote]
	end
	for note, _endNote in pairs(self.endNotes) do
		note.endNote = notes_map[_endNote]
	end
end

return NoteCloner
