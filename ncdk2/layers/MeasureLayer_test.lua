local MeasureLayer = require("ncdk2.layers.MeasureLayer")
local NoteData = require("ncdk2.notes.NoteData")
local TempoData = require("ncdk2.to.TempoData")
local VelocityData = require("ncdk2.visual.VelocityData")
local Fraction = require("ncdk.Fraction")

local test = {}

function test.basic(t)
	local layer = MeasureLayer()

	local tp_0 = layer:getTimePoint(Fraction(0))
	tp_0._tempoData = TempoData(120)
	local vtp_0 = layer:newVisualTimePoint(tp_0)
	vtp_0._velocityData = VelocityData(2)

	local tp_1 = layer:getTimePoint(Fraction(1))
	local vtp_1 = layer:newVisualTimePoint(tp_1)

	local noteData = NoteData(vtp_1)
	layer.noteDatas:addNoteData(noteData, "key", 1)

	layer:compute()

	t:eq(noteData.visualTimePoint.visualTime, 4)
	t:eq(noteData.visualTimePoint.timePoint.absoluteTime, 2)
end

return test
