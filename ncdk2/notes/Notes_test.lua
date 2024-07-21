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

return test
