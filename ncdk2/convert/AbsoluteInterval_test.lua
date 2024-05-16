local AbsoluteInterval = require("ncdk2.convert.AbsoluteInterval")
local AbsoluteLayer = require("ncdk2.layers.AbsoluteLayer")
local Tempo = require("ncdk2.to.Tempo")
local Fraction = require("ncdk.Fraction")

local test = {}

function test.basic(t)
	local conv = AbsoluteInterval({1, 2, 4}, 0.005)

	local layer = AbsoluteLayer()

	local p_0 = layer:getPoint(0)
	p_0._tempo = Tempo(120)
	local p_1 = layer:getPoint(1)
	local p_2 = layer:getPoint(2)
	p_2._tempo = Tempo(60)
	local p_3 = layer:getPoint(3)

	layer:compute()

	conv:convert(layer)
	---@cast layer -ncdk2.AbsoluteLayer, +ncdk2.IntervalLayer

	---@type ncdk2.IntervalPoint[]
	local points = layer:getPointList()

	t:eq(#points, 4)

	t:eq(points[1].time, Fraction(0))
	t:eq(points[2].time, Fraction(2))
	t:eq(points[3].time, Fraction(4))
	t:eq(points[4].time, Fraction(5))

	t:eq(points[1].absoluteTime, 0)
	t:eq(points[2].absoluteTime, 1)
	t:eq(points[3].absoluteTime, 2)
	t:eq(points[4].absoluteTime, 3)
end

function test.point_merge(t)
	local conv = AbsoluteInterval({1, 2, 4}, 0.005)

	local layer = AbsoluteLayer()

	local p_0 = layer:getPoint(0)
	p_0._tempo = Tempo(120)

	local p_1 = layer:getPoint(1)
	local vp_1 = layer.visual:newPoint(p_1)

	local p_2 = layer:getPoint(1.001)
	local vp_2 = layer.visual:newPoint(p_2)

	local p_3 = layer:getPoint(2)

	layer:compute()

	conv:convert(layer)
	---@cast layer -ncdk2.AbsoluteLayer, +ncdk2.IntervalLayer

	---@type ncdk2.IntervalPoint[]
	local points = layer:getPointList()

	t:eq(#points, 3)

	t:eq(points[1].time, Fraction(0))
	t:eq(points[2].time, Fraction(2))
	t:eq(points[3].time, Fraction(4))
	t:eq(points[1].absoluteTime, 0)
	t:eq(points[2].absoluteTime, 1)
	t:eq(points[3].absoluteTime, 2)

	t:eq(#layer.visual.points, 4)
	t:eq(layer.visual.points[1].point, points[1])
	t:eq(layer.visual.points[2].point, points[2])
	t:eq(layer.visual.points[3].point, points[2])
	t:eq(layer.visual.points[4].point, points[3])
end

function test.single_tempo_wrong_snap(t)
	local conv = AbsoluteInterval({1, 2, 4}, 0.005)

	local layer = AbsoluteLayer()

	local p_0 = layer:getPoint(0)
	p_0._tempo = Tempo(120)
	local p_1 = layer:getPoint(1)
	local p_2 = layer:getPoint(2.01)  -- wrong snap on last point

	layer:compute()

	conv:convert(layer)
	---@cast layer -ncdk2.AbsoluteLayer, +ncdk2.IntervalLayer

	---@type ncdk2.IntervalPoint[]
	local points = layer:getPointList()

	t:eq(#points, 3)

	t:eq(points[1].time, Fraction(0))
	t:eq(points[2].time, Fraction(2))
	t:eq(points[3].time, Fraction(4))

	t:eq(points[1].absoluteTime, 0)
	t:eq(points[2].absoluteTime, 1)
	t:eq(points[3].absoluteTime, 2)
end

function test.adjust_tempo_left(t)
	local conv = AbsoluteInterval({1, 2, 4}, 0.005)

	local layer = AbsoluteLayer()

	local p_0 = layer:getPoint(0)
	p_0._tempo = Tempo(120.1)  -- 4 * 60 / 120.1 = 1.998334721
	local p_1 = layer:getPoint(2)
	p_1._tempo = Tempo(1)

	layer:compute()

	conv:convert(layer)
	---@cast layer -ncdk2.AbsoluteLayer, +ncdk2.IntervalLayer

	---@type ncdk2.IntervalPoint[]
	local points = layer:getPointList()

	t:eq(#points, 2)
	t:eq(points[1]._interval:getTempo(), 120)
	t:eq(points[2].time, Fraction(4))
end

function test.adjust_tempo_right(t)
	local conv = AbsoluteInterval({1, 2, 4}, 0.005)

	local layer = AbsoluteLayer()

	local p_0 = layer:getPoint(0)
	p_0._tempo = Tempo(119.9)  -- 4 * 60 / 119.9 = 2.001668057
	local p_1 = layer:getPoint(2)
	p_1._tempo = Tempo(1)

	layer:compute()

	conv:convert(layer)
	---@cast layer -ncdk2.AbsoluteLayer, +ncdk2.IntervalLayer

	---@type ncdk2.IntervalPoint[]
	local points = layer:getPointList()

	t:eq(#points, 2)
	t:eq(points[1]._interval:getTempo(), 120)
	t:eq(points[2].time, Fraction(4))
end

function test.auxiliary_interval_int(t)
	local conv = AbsoluteInterval({1, 2, 4}, 0.005)

	local layer = AbsoluteLayer()

	local p_0 = layer:getPoint(0)
	p_0._tempo = Tempo(121)  -- 4 * 60 / 121 = 1.983471074
	local p_1 = layer:getPoint(2)
	p_1._tempo = Tempo(1)

	layer:compute()

	conv:convert(layer)
	---@cast layer -ncdk2.AbsoluteLayer, +ncdk2.IntervalLayer

	---@type ncdk2.IntervalPoint[]
	local points = layer:getPointList()

	t:eq(#points, 3)
	t:eq(points[1]._interval:getTempo(), 121)
	t:eq(points[2].time, Fraction(4))
	t:eq(points[3].time, Fraction(5))
	t:eq(points[2].absoluteTime, 4 * 60 / 121)
	t:eq(points[3].absoluteTime, 2)
end

function test.auxiliary_interval_frac(t)
	local conv = AbsoluteInterval({1, 2, 4}, 0.005)

	local layer = AbsoluteLayer()

	local p_0 = layer:getPoint(0)
	p_0._tempo = Tempo(140)  -- 4.5 * 60 / 140 = 1.928571429
	local p_1 = layer:getPoint(2)
	p_1._tempo = Tempo(1)

	layer:compute()

	conv:convert(layer)
	---@cast layer -ncdk2.AbsoluteLayer, +ncdk2.IntervalLayer

	---@type ncdk2.IntervalPoint[]
	local points = layer:getPointList()

	t:eq(#points, 3)
	t:eq(points[1]._interval:getTempo(), 140)
	t:eq(points[2].time, Fraction(9, 2))
	t:eq(points[3].time, Fraction(5))
	t:eq(points[2].absoluteTime, 60 / 140 * 4.5)
	t:eq(points[3].absoluteTime, 2)
end

function test.auxiliary_interval_frac_right_point(t)
	local conv = AbsoluteInterval({1, 2, 4}, 0.005)

	local layer = AbsoluteLayer()

	local p_0 = layer:getPoint(0)
	-- 4.5 * 60 / 140 = 1.928571429
	-- 4.75 * 60 / 140 = 2.035714286
	p_0._tempo = Tempo(140)

	-- near to 4.75, which does not exists, will be merged into p_2
	local p_1 = layer:getPoint(2.01)
	local p_2 = layer:getPoint(2.02)
	p_2._tempo = Tempo(1)

	local vp_1 = layer.visual:newPoint(p_1)

	layer:compute()

	conv:convert(layer)
	---@cast layer -ncdk2.AbsoluteLayer, +ncdk2.IntervalLayer

	---@type ncdk2.IntervalPoint[]
	local points = layer:getPointList()

	t:eq(#points, 3)

	t:eq(vp_1.point.absoluteTime, 2.02)
	t:eq(vp_1.point, points[3])
	t:eq(points[3].time, Fraction(5))

	t:eq(points[1]._interval:getTempo(), 140)
	t:eq(points[2].time, Fraction(9, 2))
	t:eq(points[2].absoluteTime, 60 / 140 * 4.5)
end

return test
