local IntervalLayer = require("ncdk2.layers.IntervalLayer")
local Note = require("ncdk2.notes.Note")
local Interval = require("ncdk2.to.Interval")
local Velocity = require("ncdk2.visual.Velocity")
local Fraction = require("ncdk.Fraction")

local test = {}

function test.basic(t)
	local layer = IntervalLayer()

	local p_0 = layer:getPoint(Fraction(0))
	p_0._interval = Interval(0)
	local vp_0 = layer:newVisualPoint(p_0)
	vp_0._velocity = Velocity(2)

	local p_1 = layer:getPoint(Fraction(4))
	p_1._interval = Interval(2)
	local vp_1 = layer:newVisualPoint(p_1)

	local note = Note(vp_1)
	layer.notes:insert(note, 1)

	layer:compute()

	t:eq(note.visualPoint.visualTime, 4)
	t:eq(note.visualPoint.point.absoluteTime, 2)
end

return test
