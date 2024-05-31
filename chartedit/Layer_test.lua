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

function test.split_middle(t)
	local layer = Layer()
	layer:init()

	layer:interpolateAbsolute(16, 0.5)
	local p = layer:saveSearchPoint()

	layer:splitInterval(p)
	t:eq(p.interval.offset, 0.5)
	t:eq(p.time, Fraction(1, 2))
	t:eq(p.absoluteTime, 0.5)

	t:eq(p.interval.prev.offset, 0)
	t:eq(p.interval.next.offset, 1)
end

function test.split_before(t)
	local layer = Layer()
	layer:init()

	layer:interpolateAbsolute(16, -0.5)
	local p = layer:saveSearchPoint()

	layer:splitInterval(p)
	t:eq(p.interval.offset, -0.5)
	t:eq(p.time, Fraction(1, 2))
	t:eq(p.absoluteTime, -0.5)
	t:eq(p.prev, nil)
	t:eq(p.next, p.interval.next.point)

	t:eq(p.interval.prev, nil)
	t:eq(p.interval.next.offset, 0)
end

function test.split_after(t)
	local layer = Layer()
	layer:init()

	layer:interpolateAbsolute(16, 1.5)
	local p = layer:saveSearchPoint()

	layer:splitInterval(p)
	t:eq(p.interval.offset, 1.5)
	t:eq(p.time, Fraction(1, 2))
	t:eq(p.absoluteTime, 1.5)
	t:eq(p.prev, p.interval.prev.point)
	t:eq(p.next, nil)

	t:eq(p.interval.prev.offset, 1)
	t:eq(p.interval.next, nil)
end

return test
