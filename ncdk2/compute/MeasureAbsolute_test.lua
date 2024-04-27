local MeasureAbsolute = require("ncdk2.compute.MeasureAbsolute")
local MeasurePoint = require("ncdk2.tp.MeasurePoint")
local Tempo = require("ncdk2.to.Tempo")
local Fraction = require("ncdk.Fraction")

local test = {}

---@param n number
---@return ncdk2.MeasurePoint
local function newp(n)
	return MeasurePoint(Fraction(n, 1000, true))
end

function test.basic(t)
	local conv = MeasureAbsolute()

	local points = {
		newp(0),
		newp(1),
	}

	points[1]._tempo = Tempo(60)

	conv:convert(points)

	t:eq(points[1].absoluteTime, 0)
	t:eq(points[2].absoluteTime, 4)
end

return test
