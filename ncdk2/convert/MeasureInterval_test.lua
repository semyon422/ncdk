local MeasureInterval = require("ncdk2.convert.MeasureInterval")
local MeasureLayer = require("ncdk2.layers.MeasureLayer")
local Tempo = require("ncdk2.to.Tempo")
local Stop = require("ncdk2.to.Stop")
local Fraction = require("ncdk.Fraction")

local test = {}

-- function test.basic(t)
-- 	local conv = MeasureInterval()

-- 	local layer = MeasureLayer()

-- 	local p_0 = layer:getPoint(Fraction(0))
-- 	p_0._tempo = Tempo(120)

-- 	local p_1 = layer:getPoint(Fraction(1))

-- 	layer:compute()

-- 	conv:convert(layer)
-- 	---@cast insertncdk2.MeasureLayer, +ncdk2.IntervalLayer

-- 	---@type ncdk2.IntervalPoint[]
-- 	local points = layer:getPointList()

-- 	t:eq(#points, 2)
-- 	t:eq(points[1].absoluteTime, 0)
-- 	t:eq(points[2].absoluteTime, 2)
-- 	t:eq(points[1]._interval.offset, 0)
-- 	t:eq(points[2]._interval.offset, 2)
-- end

function test.stop(t)
	local conv = MeasureInterval()

	local layer = MeasureLayer()

	local p_0 = layer:getPoint(Fraction(0))
	p_0._tempo = Tempo(60)

	local p_1 = layer:getPoint(Fraction(1, 8))  -- 1/2
	local p_2 = layer:getPoint(Fraction(1, 8), true)
	p_2._stop = Stop(Fraction(1, 4))

	local p_3 = layer:getPoint(Fraction(1))

	layer:compute()

	conv:convert(layer)
	---@cast layer -ncdk2.MeasureLayer, +ncdk2.IntervalLayer

	---@type ncdk2.IntervalPoint[]
	local points = layer:getPointList()

	t:eq(#points, 4)

	t:eq(points[1].absoluteTime, 0)
	t:eq(points[2].absoluteTime, 0.5)
	t:eq(points[3].absoluteTime, 0.75)
	t:eq(points[4].absoluteTime, 4.25)

	t:eq(points[1].time, Fraction(0))
	t:eq(points[2].time, Fraction(1, 2))
	t:eq(points[3].time, Fraction(3, 2))
	t:eq(points[4].time, Fraction(5))
end

return test
