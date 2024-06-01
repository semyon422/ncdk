local Layer = require("chartedit.Layer")
local Fraction = require("ncdk.Fraction")

local test = {}

function test.int_abs(t)
	local layer = Layer()
	layer:init()

	local p = layer:interpolateAbsolute(16, 0.5)
	t:eq(p.interval.offset, 0)
	t:eq(p.time, Fraction(1, 2))
	t:eq(p.absoluteTime, 0.5)
	t:eq(p.prev, p.interval.point)
	t:eq(p.next, p.interval.next.point)

	p = layer:interpolateAbsolute(16, -0.5)
	t:eq(p.interval.offset, 0)
	t:eq(p.time, Fraction(-1, 2))
	t:eq(p.absoluteTime, -0.5)
	t:eq(p.prev, nil)
	t:eq(p.next, p.interval.point)

	p = layer:interpolateAbsolute(16, 1.5)
	t:eq(p.interval.offset, 1)
	t:eq(p.time, Fraction(1, 2))
	t:eq(p.absoluteTime, 1.5)
	t:eq(p.prev, p.interval.point)
	t:eq(p.next, nil)
end

function test.new_points(t)
	local layer = Layer()
	layer:init()

	local p0 = layer:getFirstPoint()
	local p10 = p0.next

	layer:interpolateAbsolute(10, 0.5)
	local p5 = layer:saveSearchPoint()

	t:eq(p0.next, p5)
	t:eq(p10.prev, p5)
	t:eq(p5.next, p10)
	t:eq(p5.prev, p0)

	layer:interpolateAbsolute(10, 0.2)
	local p2 = layer:saveSearchPoint()

	t:eq(p0.next, p2)
	t:eq(p5.prev, p2)
	t:eq(p2.next, p5)
	t:eq(p2.prev, p0)
end

function test.split_middle(t)
	local layer = Layer()
	layer:init()

	layer:interpolateAbsolute(16, 0.25)
	local p1 = layer:saveSearchPoint()

	layer:interpolateAbsolute(16, 0.75)
	local p2 = layer:saveSearchPoint()

	layer:interpolateAbsolute(16, 0.5)
	local p = layer:saveSearchPoint()

	layer:splitInterval(p)
	t:eq(p.interval.offset, 0.5)
	t:eq(p.time, Fraction(1, 2))
	t:eq(p.absoluteTime, 0.5)

	t:eq(p.interval.prev.offset, 0)
	t:eq(p.interval.next.offset, 1)

	t:eq(p1.interval.offset, 0)
	t:eq(p2.interval.offset, 0.5)

	layer:mergeInterval(p)

	t:eq(p1.interval.offset, 0)
	t:eq(p2.interval.offset, 0)
end

function test.split_before(t)
	local layer = Layer()
	layer:init()

	layer:interpolateAbsolute(16, -0.75)
	local p1 = layer:saveSearchPoint()

	layer:interpolateAbsolute(16, -0.25)
	local p2 = layer:saveSearchPoint()

	layer:interpolateAbsolute(16, -0.5)
	local p = layer:saveSearchPoint()

	layer:splitInterval(p)
	t:eq(p.interval.offset, -0.5)
	t:eq(p.time, Fraction(1, 2))
	t:eq(p.absoluteTime, -0.5)
	t:eq(p.prev, p1)
	t:eq(p.next, p2)

	t:eq(p.interval.prev, nil)
	t:eq(p.interval.next.offset, 0)

	t:eq(p1.interval.offset, -0.5)
	t:eq(p2.interval.offset, -0.5)

	layer:mergeInterval(p)

	t:eq(p1.interval.offset, 0)
	t:eq(p2.interval.offset, 0)
end

function test.split_after(t)
	local layer = Layer()
	layer:init()

	layer:interpolateAbsolute(16, 1.25)
	local p1 = layer:saveSearchPoint()

	layer:interpolateAbsolute(16, 1.75)
	local p2 = layer:saveSearchPoint()

	layer:interpolateAbsolute(16, 1.5)
	local p = layer:saveSearchPoint()

	layer:splitInterval(p)
	t:eq(p.interval.offset, 1.5)
	t:eq(p.time, Fraction(1, 2))
	t:eq(p.absoluteTime, 1.5)
	t:eq(p.prev, p1)
	t:eq(p.next, p2)

	t:eq(p.interval.prev.offset, 1)
	t:eq(p.interval.next, nil)

	t:eq(p1.interval.offset, 1)
	t:eq(p2.interval.offset, 1.5)

	layer:mergeInterval(p)

	t:eq(p1.interval.offset, 1)
	t:eq(p2.interval.offset, 1)
end

return test
