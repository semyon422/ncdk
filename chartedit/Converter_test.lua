local stbl = require("stbl")
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
- =0
- =1
]]

	local dec = ChartDecoder()
	local chart = dec:decode(s)[1]

	local nlayer = chart.layers.main
	local layer = Converter:loadLayer(nlayer, {})
	local _nlayer = Converter:saveLayer(layer, {})
	_nlayer.visual.p2vp = nil
	nlayer.visual.p2vp = nil
	_nlayer.visual.points_map = nil
	nlayer.visual.points_map = nil
	t:tdeq(_nlayer, nlayer)
end

function test.sph_early_int(t)
	local s = [[
# metadata
input 4key

# notes
1000
-
- =0
- =1
]]

	local dec = ChartDecoder()
	local chart = dec:decode(s)[1]

	local nlayer = chart.layers.main
	local layer = Converter:loadLayer(nlayer, {})
	local _nlayer = Converter:saveLayer(layer, {})
	_nlayer.visual.p2vp = nil
	nlayer.visual.p2vp = nil
	_nlayer.visual.points_map = nil
	nlayer.visual.points_map = nil
	t:tdeq(_nlayer, nlayer)
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
- +1/8 =1
1000
]]

	local dec = ChartDecoder()
	local chart = dec:decode(s)[1]

	local nlayer = chart.layers.main
	local layer = Converter:loadLayer(nlayer, {})
	local _nlayer = Converter:saveLayer(layer, {})
	_nlayer.visual.p2vp = nil
	nlayer.visual.p2vp = nil
	_nlayer.visual.points_map = nil
	nlayer.visual.points_map = nil
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
	_nlayer.visual.p2vp = nil
	nlayer.visual.p2vp = nil
	_nlayer.visual.points_map = nil
	nlayer.visual.points_map = nil
	t:tdeq(_nlayer, nlayer)
end

return test
