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
	local vp_1 = layer:newVisualPoint(p_1)

	local p_2 = layer:getPoint(1.001)
	local vp_2 = layer:newVisualPoint(p_2)

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

	t:eq(#layer.visualPoints, 2)
	t:eq(layer.visualPoints[1].point, points[2])
	t:eq(layer.visualPoints[2].point, points[2])
end

return test
