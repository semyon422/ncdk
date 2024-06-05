local Intervals = require("chartedit.Intervals")
local Points = require("chartedit.Points")
local Fraction = require("ncdk.Fraction")

local test = {}

function test.split_middle(t)
	local points = Points()
	points:initDefault()
	local intervals = Intervals(points)

	points:interpolateAbsolute(16, 0.25)
	local p1 = points:saveSearchPoint()

	points:interpolateAbsolute(16, 0.75)
	local p2 = points:saveSearchPoint()

	points:interpolateAbsolute(16, 0.5)
	local p = points:saveSearchPoint()

	intervals:splitInterval(p)
	t:eq(p.interval.offset, 0.5)
	t:eq(p.time, Fraction(1, 2))
	t:eq(p.absoluteTime, 0.5)

	t:eq(p.interval.prev.offset, 0)
	t:eq(p.interval.next.offset, 1)

	t:eq(p1.interval.offset, 0)
	t:eq(p2.interval.offset, 0.5)

	intervals:mergeInterval(p)

	t:eq(p1.interval.offset, 0)
	t:eq(p2.interval.offset, 0)
end

function test.split_before(t)
	local points = Points()
	points:initDefault()
	local intervals = Intervals(points)

	points:interpolateAbsolute(16, -0.75)
	local p1 = points:saveSearchPoint()

	points:interpolateAbsolute(16, -0.25)
	local p2 = points:saveSearchPoint()

	points:interpolateAbsolute(16, -0.5)
	local p = points:saveSearchPoint()

	intervals:splitInterval(p)
	t:eq(p.interval.offset, -0.5)
	t:eq(p.time, Fraction(1, 2))
	t:eq(p.absoluteTime, -0.5)
	t:eq(p.prev, p1)
	t:eq(p.next, p2)

	t:eq(p.interval.prev, nil)
	t:eq(p.interval.next.offset, 0)

	t:eq(p1.interval.offset, -0.5)
	t:eq(p2.interval.offset, -0.5)

	intervals:mergeInterval(p)

	t:eq(p1.interval.offset, 0)
	t:eq(p2.interval.offset, 0)
end

function test.split_after(t)
	local points = Points()
	points:initDefault()
	local intervals = Intervals(points)

	points:interpolateAbsolute(16, 1.25)
	local p1 = points:saveSearchPoint()

	points:interpolateAbsolute(16, 1.75)
	local p2 = points:saveSearchPoint()

	points:interpolateAbsolute(16, 1.5)
	local p = points:saveSearchPoint()

	intervals:splitInterval(p)
	t:eq(p.interval.offset, 1.5)
	t:eq(p.time, Fraction(1, 2))
	t:eq(p.absoluteTime, 1.5)
	t:eq(p.prev, p1)
	t:eq(p.next, p2)

	t:eq(p.interval.prev.offset, 1)
	t:eq(p.interval.next, nil)

	t:eq(p1.interval.offset, 1)
	t:eq(p2.interval.offset, 1.5)

	intervals:mergeInterval(p)

	t:eq(p1.interval.offset, 1)
	t:eq(p2.interval.offset, 1)
end

return test
