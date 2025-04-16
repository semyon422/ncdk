local RefChart = require("refchart.RefChart")
local Fraction = require("ncdk.Fraction")
local Chart = require("ncdk2.Chart")
local AbsoluteLayer = require("ncdk2.layers.AbsoluteLayer")
local Note = require("ncdk2.notes.Note")
local Tempo = require("ncdk2.to.Tempo")
local Measure = require("ncdk2.to.Measure")
local Visual = require("ncdk2.visual.Visual")
local Expand = require("ncdk2.visual.Expand")
local Velocity = require("ncdk2.visual.Velocity")
local Restorer = require("refchart.Restorer")

local test = {}

function test.basic(t)
	local chart = Chart()

	local layer = AbsoluteLayer()
	chart.layers.main = layer

	local visual = Visual()
	layer.visuals.main = visual

	local p = layer:getPoint(0)
	p._tempo = Tempo(120)
	p._measure = Measure(Fraction(1, 2))

	local vp = visual:getPoint(p)
	vp._velocity = Velocity(2, 3, 4)
	vp._expand = Expand(1)

	local note = Note(vp, "key1", "tap", 0)

	chart.notes:insert(note)

	chart.resources:add("sound", "audio.ogg", "audio_fallback.ogg")

	chart:compute()

	local test_refchart = {
		inputmode = {},
		layers = {
			main = {
				points = {
					{
						measure = {1, 2},
						tempo = 120,
						time = 0,
					},
				},
				visuals = {
					main = {
						{
							expand = 1,
							point = 1,
							velocity = {2, 3, 4},
						},
					},
				},
			},
		},
		notes = {{
			column = "key1",
			point = {
				index = 1,
				layer = "main",
				visual = "main",
			},
			type = "tap",
			weight = 0,
		}},
		resources = {
			{"sound", "audio.ogg", "audio_fallback.ogg"},
		}
	}

	local refchart = RefChart(chart)

	t:tdeq(refchart, test_refchart)

	local restorer = Restorer()
	local _chart = restorer:restore(refchart)

	t:tdeq(RefChart(_chart), test_refchart)
end

return test
