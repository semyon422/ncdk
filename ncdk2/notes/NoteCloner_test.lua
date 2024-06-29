local NoteCloner = require("ncdk2.notes.NoteCloner")
local Note = require("ncdk2.notes.Note")

local test = {}

function test.basic(t)
	local cloner = NoteCloner()
	local a = Note()
	local b = Note()
	b.startNote = a
	a.endNote = b

	local c = cloner:clone(a)
	local d = cloner:clone(b)
	cloner:assignStartEnd()

	t:eq(b.startNote, a)
	t:eq(a.endNote, b)

	t:eq(d.startNote, c)
	t:eq(c.endNote, d)

	t:rawne(a, c)
	t:rawne(b, d)
end

return test
