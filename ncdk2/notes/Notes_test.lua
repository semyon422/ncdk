local Notes = require("ncdk2.notes.Notes")
local Note = require("ncdk2.notes.Note")

local test = {}

function test.long_note(t)
	local notes = Notes()
	notes:insert(Note(1, "key", 1, "hold"))
	notes:insert(Note(2, "key", -1, "hold"))
	t:assert(notes:isValid())
end

function test.long_note_2_types(t)
	local notes = Notes()
	notes:insert(Note(1, "key", 1, "hold"))
	notes:insert(Note(2, "key", 1, "hold2"))
	notes:insert(Note(3, "key", -1, "hold"))
	notes:insert(Note(4, "key", -1, "hold2"))
	t:assert(notes:isValid())
end

function test.error_on_non_zero_weight(t)
	local notes = Notes()
	notes:insert(Note(1, "key", 1, "note"))
	t:assert(not notes:isValid())
end

return test
