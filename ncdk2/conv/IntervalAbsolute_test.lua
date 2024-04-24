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

---@param n number
---@param beats number
---@param offset number
---@return ncdk2.IntervalTimePoint
local function newitp(n, beats, offset)
	local time = Fraction(n, 1000, true)
	local tp = IntervalTimePoint()
	tp.absoluteTime = offset
	tp.time = time
	tp.intervalData = IntervalData(beats)
	tp.intervalData.timePoint = tp
	return tp
end

function test.basic(t)
	local conv = IntervalAbsolute()

	local timePoints = {
		newitp(0, 4, 0),
		newtp(1),
		newtp(2),
		newtp(3),
		newitp(0, 1, 4),
		newtp(1),
	}

	timePoints[1].intervalData.next = timePoints[5].intervalData
	timePoints[5].intervalData.prev = timePoints[1].intervalData

	timePoints[2].intervalData = timePoints[1].intervalData
	timePoints[3].intervalData = timePoints[1].intervalData
	timePoints[4].intervalData = timePoints[1].intervalData
	timePoints[6].intervalData = timePoints[5].intervalData

	conv:convert(timePoints)

	t:eq(timePoints[1].absoluteTime, 0)
	t:eq(timePoints[2].absoluteTime, 1)
	t:eq(timePoints[5].absoluteTime, 4)
	t:eq(timePoints[6].absoluteTime, 5)
end

return test
