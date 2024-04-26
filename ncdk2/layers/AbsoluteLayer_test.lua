local AbsoluteLayer = require("ncdk2.layers.AbsoluteLayer")
local Note = require("ncdk2.notes.Note")
local Velocity = require("ncdk2.visual.Velocity")

local test = {}

function test.basic(t)
	local layer = AbsoluteLayer()

	local p_0 = layer:getPoint(0)
	local vp_0 = layer:newVisualPoint(p_0)
	vp_0._velocity = Velocity(2)

	local p_1 = layer:getPoint(2)
	local vp_1 = layer:newVisualPoint(p_1)

	local note = Note(vp_1)
	layer.notes:addNote(note, "key", 1)

	layer:compute()

	t:eq(note.visualPoint.visualTime, 4)
	t:eq(note.visualPoint.point.absoluteTime, 2)
end

return test
