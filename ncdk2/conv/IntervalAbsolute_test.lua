local IntervalAbsolute = require("ncdk2.conv.IntervalAbsolute")
local IntervalPoint = require("ncdk2.tp.IntervalPoint")
local Interval = require("ncdk2.to.Interval")
local Fraction = require("ncdk.Fraction")

local test = {}

---@param n number
---@return ncdk2.IntervalPoint
local function newp(n)
	return IntervalPoint(Fraction(n, 1000, true))
end

function test.basic2(t)
	local conv = IntervalAbsolute()

	local points = {
		newp(0),
		newp(1),
		newp(2),
		newp(3),
		newp(4),
		newp(5),
	}

	points[1]._interval = Interval(0)
	points[5]._interval = Interval(4)

	conv:convert(points)

	t:eq(points[1].absoluteTime, 0)
	t:eq(points[2].absoluteTime, 1)
	t:eq(points[5].absoluteTime, 4)
	t:eq(points[6].absoluteTime, 5)
end

return test
