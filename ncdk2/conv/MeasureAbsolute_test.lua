local MeasureAbsolute = require("ncdk2.conv.MeasureAbsolute")
local MeasureTimePoint = require("ncdk2.tp.MeasureTimePoint")
local TempoData = require("ncdk2.to.TempoData")
local Fraction = require("ncdk.Fraction")

local test = {}

---@param n number
---@return ncdk2.MeasureTimePoint
local function newtp(n)
	return MeasureTimePoint(Fraction(n, 1000, true))
end

function test.basic(t)
	local conv = MeasureAbsolute()

	local timePoints = {
		newtp(0),
		newtp(1),
	}

	timePoints[1]._tempoData = TempoData(timePoints[1], 60)

	conv:convert(timePoints)

	t:eq(timePoints[1].absoluteTime, 0)
	t:eq(timePoints[2].absoluteTime, 4)
end

return test
