local table_util = require("table_util")
local Fraction = require("ncdk.Fraction")
local Converter = require("chartedit.Converter")
local Layer = require("chartedit.Layer")
local IntervalLayer = require("ncdk2.layers.IntervalLayer")
local ChartDecoder = require("sph.ChartDecoder")

local test = {}

function test.empty_load_save(t)
	local nlayer = IntervalLayer()
	local layer = Converter:loadLayer(nlayer, {})
	local _nlayer = Converter:saveLayer(layer, {})
	t:tdeq(_nlayer, nlayer)
end

function test.empty_save_load(t)
	local layer = Layer()
	local nlayer = Converter:saveLayer(layer, {})
	local _layer = Converter:loadLayer(nlayer, {})
	-- t:eq(stbl.encode(_layer), stbl.encode(layer))
end

function test.sph_early_frac(t)
	local s = [[
# metadata
input 4key

# notes
1000 +1/2
-
-
-
- =0
- =1
]]

	local dec = ChartDecoder()

	do
		local chart = dec:decode(s)[1]

		local _layers, _notes = Converter:load(chart)

		local _note = _notes:iter()()
		local _p = _note.visualPoint.point
		---@cast _p chartedit.Point
		t:eq(_p.time, Fraction(-7, 2))

		chart = Converter:save(_layers, _notes)

		local note = chart.notes:getNotes()[1]
		local p = note.visualPoint.point
		---@cast p ncdk2.IntervalPoint
		t:eq(p.time, Fraction(-7, 2))
	end

	do
		local chart = dec:decode(s)[1]

		local nlayer = chart.layers.main
		local layer = Converter:loadLayer(nlayer, {})
		local _nlayer = Converter:saveLayer(layer, {})
		_nlayer.visuals = {}
		nlayer.visuals = {}
		t:tdeq(_nlayer, nlayer)
	end
end

function test.sph_early_int(t)
	local s = [[
# metadata
input 4key

# notes
1000
-
-
-
- =0
- =1
]]

	local dec = ChartDecoder()

	do
		local chart = dec:decode(s)[1]

		local _layers, _notes = Converter:load(chart)

		local _note = _notes:iter()()
		local _p = _note.visualPoint.point
		---@cast _p chartedit.Point
		t:eq(_p.time, Fraction(-4))

		chart = Converter:save(_layers, _notes)

		local note = chart.notes:getNotes()[1]
		local p = note.visualPoint.point
		---@cast p ncdk2.IntervalPoint
		t:eq(p.time, Fraction(-4))
	end

	do
		local chart = dec:decode(s)[1]

		local nlayer = chart.layers.main
		local layer = Converter:loadLayer(nlayer, {})
		local _nlayer = Converter:saveLayer(layer, {})
		_nlayer.visuals = {}
		nlayer.visuals = {}
		t:tdeq(_nlayer, nlayer)
	end
end

function test.sph_frac_offset(t)
	local s = [[
# metadata
input 4key

# notes
1000
- +1/2 =0
1000
- +1/4 =1
1000
- +1/8 =2
1000
]]

	local dec = ChartDecoder()
	local chart = dec:decode(s)[1]

	local nlayer = chart.layers.main
	local layer = Converter:loadLayer(nlayer, {})
	local _nlayer = Converter:saveLayer(layer, {})
	_nlayer.visuals = {}
	nlayer.visuals = {}
	t:tdeq(_nlayer, nlayer)
end

function test.sph_sv(t)
	local s = [[
# metadata
input 4key

# notes
1000 =0 x1
0100 v x2
0010 v e3
-
- =1
]]

	local dec = ChartDecoder()
	local chart = dec:decode(s)[1]

	local nlayer = chart.layers.main
	local layer = Converter:loadLayer(nlayer, {})
	local _nlayer = Converter:saveLayer(layer, {})
	_nlayer.visuals = {}
	nlayer.visuals = {}
	t:tdeq(_nlayer, nlayer)
end

return test
