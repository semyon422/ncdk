local class = require("class")
local Note = require("refchart.Note")

---@class refchart.Notes
---@operator call: refchart.Notes
---@field [integer] refchart.Note
local Notes = class()

---@param notes ncdk2.Notes
---@param vp_ref {[ncdk2.VisualPoint]: refchart.VisualPointReference}
function Notes:new(notes, vp_ref)
	---@type refchart.Note[]
	for i, note in ipairs(notes.notes) do
		local _note = Note()
		_note.point = vp_ref[note.visualPoint]
		_note.column = note.column
		_note.type = note.type
		_note.weight = note.weight
		self[i] = _note
	end
end

return Notes
