local stbl = require("stbl")
local Converter = require("chartedit.Converter")
local Layer = require("chartedit.Layer")
local IntervalLayer = require("ncdk2.layers.IntervalLayer")
local ChartDecoder = require("sph.ChartDecoder")
local ChartEncoder = require("sph.ChartEncoder")

local test = {}

function test.empty_load_save(t)
	local nlayer = IntervalLayer()
	local layer = Converter:load(nlayer)
	local _nlayer = Converter:save(layer)
	t:tdeq(_nlayer, nlayer)
end

function test.empty_save_load(t)
	local layer = Layer()
	local nlayer = Converter:save(layer)
	local _layer = Converter:load(nlayer)
	t:eq(stbl.encode(_layer), stbl.encode(layer))
end

function test.sph_1(t)
	local s = [[
# metadata
input 4key

# notes
- =0
- =1
]]

	local dec = ChartDecoder()
	local chart = dec:decode(s)[1]

	local nlayer = chart.layers.main
	local layer = Converter:load(nlayer)
	local _nlayer = Converter:save(layer)
	-- t:tdeq(_nlayer, nlayer)
	-- t:eq(stbl.encode(_nlayer), stbl.encode(nlayer))

	-- local enc = ChartEncoder()

	-- t:eq(enc:encode(dec:decode(s)), s)
end


return test
