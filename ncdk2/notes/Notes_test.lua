local Notes = require("ncdk2.notes.Notes")
local Note = require("ncdk2.notes.Note")

local test = {}

function test.long_note(t)
	local notes = Notes()
	notes:insert(Note(1, "key", "hold", 1))
	notes:insert(Note(2, "key", "hold", -1))
	t:assert(notes:isValid())
end

function test.long_note_2_types(t)
	local notes = Notes()
	notes:insert(Note(1, "key", "hold", 1))
	notes:insert(Note(2, "key", "hold2", 1))
	notes:insert(Note(3, "key", "hold", -1))
	notes:insert(Note(4, "key", "hold2", -1))
	t:assert(notes:isValid())
end

function test.error_on_non_zero_weight(t)
	local notes = Notes()
	notes:insert(Note(1, "key", "note", 1))
	t:assert(not notes:isValid())
end

function test.link(t)
	local notes = Notes()
	notes:insert(Note(1, "key", "hold", 1))
	notes:insert(Note(2, "key", "hold", 1))
	notes:insert(Note(3, "key", "note", 0))
	notes:insert(Note(4, "key", "hold", -1))
	notes:insert(Note(5, "key", "hold", -1))

	local lnotes = notes:link(notes.notes)
	t:eq(#lnotes, 3)

	t:eq(lnotes[1]:getSize(), 2)
	t:eq(lnotes[1]:getType(), "hold")

	t:eq(lnotes[2]:getSize(), 2)
	t:eq(lnotes[2]:getType(), "hold")

	t:eq(lnotes[3]:getSize(), 1)
	t:eq(lnotes[3]:getType(), "note")
end

return test
