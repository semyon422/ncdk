local IntervalAbsolute = require("ncdk2.conv.IntervalAbsolute")
local IntervalTimePoint = require("ncdk2.tp.IntervalTimePoint")
local IntervalData = require("ncdk2.to.IntervalData")
local Fraction = require("ncdk.Fraction")

local test = {}

---@param n number
---@return ncdk2.IntervalTimePoint
local function newtp(n)
	local tp = IntervalTimePoint()
	tp.time = Fraction(n, 1000, true)
	return tp
end

function test.basic2(t)
	local conv = IntervalAbsolute()

	local timePoints = {
		newtp(0),
		newtp(1),
		newtp(2),
		newtp(3),
		newtp(4),
		newtp(5),
	}

	timePoints[1]._intervalData = IntervalData(0)
	timePoints[5]._intervalData = IntervalData(4)

	conv:convert(timePoints)

	t:eq(timePoints[1].absoluteTime, 0)
	t:eq(timePoints[2].absoluteTime, 1)
	t:eq(timePoints[5].absoluteTime, 4)
	t:eq(timePoints[6].absoluteTime, 5)
end

return test
