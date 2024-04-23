local IntervalAbsolute = require("ncdk2.conv.IntervalAbsolute")
local IntervalTimePoint = require("ncdk2.tp.IntervalTimePoint")
local ReferenceIntervalTimePoint = require("ncdk2.tp.ReferenceIntervalTimePoint")
local IntervalData = require("ncdk2.to.IntervalData")
local Fraction = require("ncdk.Fraction")

local test = {}

---@param n number
---@return ncdk2.IntervalTimePoint
local function newtp(n)
	return IntervalTimePoint(Fraction(n, 1000, true))
end

---@param n number
---@param beats number
---@param offset number
---@return ncdk2.ReferenceIntervalTimePoint
local function newrtp(n, beats, offset)
	return ReferenceIntervalTimePoint(Fraction(n, 1000, true), beats, offset)
end

function test.basic(t)
	local conv = IntervalAbsolute()

	local timePoints = {
		newrtp(0, 4, 0),
		newtp(1),
		newtp(2),
		newtp(3),
		newrtp(0, 1, 4),
	}

	conv:convert(timePoints)

	t:eq(timePoints[1].absoluteTime, 0)
	t:eq(timePoints[2].absoluteTime, 1)
	t:eq(timePoints[5].absoluteTime, 4)
end

return test
