local MeasureInterval = require("ncdk2.convert.MeasureInterval")
local MeasureLayer = require("ncdk2.layers.MeasureLayer")
local Note = require("ncdk2.notes.Note")
local Tempo = require("ncdk2.to.Tempo")
local Velocity = require("ncdk2.visual.Velocity")
local Fraction = require("ncdk.Fraction")

local test = {}

local function create_layer()
	local layer = MeasureLayer()

	local p_0 = layer:getPoint(Fraction(0))
	p_0._tempo = Tempo(120)
	local vp_0 = layer:newVisualPoint(p_0)
	vp_0._velocity = Velocity(2)

	local p_1 = layer:getPoint(Fraction(1))
	local vp_1 = layer:newVisualPoint(p_1)

	local note = Note(vp_1)
	layer.notes:addNote(note, "key", 1)

	layer:compute()

	return layer
end

function test.basic(t)
	local conv = MeasureInterval()
	local layer = create_layer()

	conv:convert(layer)
	---@cast layer -ncdk2.MeasureLayer, +ncdk2.IntervalLayer

	local note = layer.notes.data.key[1][1]
	t:eq(note.visualPoint.visualTime, 4)
	t:eq(note.visualPoint.point.absoluteTime, 2)
end

return test
