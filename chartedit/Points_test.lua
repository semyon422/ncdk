local Points = require("chartedit.Points")
local Fraction = require("ncdk.Fraction")

local test = {}

function test.int_abs(t)
	local points = Points()
	points:initDefault()

	local p = points:interpolateAbsolute(16, 0.5)
	t:eq(p.interval.offset, 0)
	t:eq(p.time, Fraction(1, 2))
	t:eq(p.absoluteTime, 0.5)
	t:eq(p.prev, p.interval.point)
	t:eq(p.next, p.interval.next.point)

	p = points:interpolateAbsolute(16, -0.5)
	t:eq(p.interval.offset, 0)
	t:eq(p.time, Fraction(-1, 2))
	t:eq(p.absoluteTime, -0.5)
	t:eq(p.prev, nil)
	t:eq(p.next, p.interval.point)

	p = points:interpolateAbsolute(16, 1.5)
	t:eq(p.interval.offset, 1)
	t:eq(p.time, Fraction(1, 2))
	t:eq(p.absoluteTime, 1.5)
	t:eq(p.prev, p.interval.point)
	t:eq(p.next, nil)
end

function test.new_points(t)
	local points = Points()
	points:initDefault()

	local p0 = points:getFirstPoint()
	local p10 = p0.next

	points:interpolateAbsolute(10, 0.5)
	local p5 = points:saveSearchPoint()

	t:eq(p0.next, p5)
	t:eq(p10.prev, p5)
	t:eq(p5.next, p10)
	t:eq(p5.prev, p0)

	points:interpolateAbsolute(10, 0.2)
	local p2 = points:saveSearchPoint()

	t:eq(p0.next, p2)
	t:eq(p5.prev, p2)
	t:eq(p2.next, p5)
	t:eq(p2.prev, p0)
end

function test.remove_point(t)
	local points = Points()
	points:initDefault()

	local p0 = points:getFirstPoint()
	local p10 = p0.next

	points:interpolateAbsolute(10, 0.5)
	local p5 = points:saveSearchPoint()

	points:removePoint(p5)

	t:eq(p0.next, p10)
	t:eq(p10.prev, p0)
end

function test.int_frac(t)
	local points = Points()
	points:initDefault()

	local ivl = points:getFirstPoint().interval

	local p = points:interpolateFraction(ivl, Fraction(1, 2))
	t:eq(p.absoluteTime, 0.5)

	p = points:interpolateFraction(ivl, Fraction(-1, 2))
	t:eq(p.absoluteTime, -0.5)

	p = points:interpolateFraction(ivl.next, Fraction(1, 2))
	t:eq(p.absoluteTime, 1.5)
end

return test
