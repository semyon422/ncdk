local MeasureAbsolute = require("ncdk2.compute.MeasureAbsolute")
local MeasurePoint = require("ncdk2.tp.MeasurePoint")
local Tempo = require("ncdk2.to.Tempo")
local Stop = require("ncdk2.to.Stop")
local Signature = require("ncdk2.to.Signature")
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
		newp(10),
	}

	points[1]._tempo = Tempo(60)

	conv:convert(points)

	t:eq(points[1].absoluteTime, 0)
	t:eq(points[2].absoluteTime, 4)
	t:eq(points[3].absoluteTime, 40)
end

function test.no_zero_point(t)
	local conv = MeasureAbsolute()

	local points = {
		newp(-1),
		newp(1),
	}

	points[1]._tempo = Tempo(60)

	conv:convert(points)

	t:eq(points[1].absoluteTime, -4)
	t:eq(points[2].absoluteTime, 4)
end

function test.no_zero_point_right(t)
	local conv = MeasureAbsolute()

	local points = {
		newp(1),
	}

	points[1]._tempo = Tempo(60)

	conv:convert(points)

	t:eq(points[1].absoluteTime, 4)
end

function test.stop(t)
	local conv = MeasureAbsolute()

	local points = {
		newp(0),
		newp(0),
		newp(1),
	}

	points[1]._tempo = Tempo(120)  -- use fraction beat time here to test stops
	points[2].isRightSide = true
	points[2]._stop = Stop(Fraction(1), false)  -- 1 beat

	conv:convert(points)

	t:eq(points[1].absoluteTime, 0)
	t:eq(points[2].absoluteTime, 0.5)
	t:eq(points[3].absoluteTime, 2.5)  -- default signature is 4
end

function test.signature(t)
	local conv = MeasureAbsolute()

	local points = {
		newp(0),
		newp(1),
		newp(2),
		newp(3),
		newp(4),
	}

	points[1]._tempo = Tempo(60)

	-- long mode
	points[2]._signature = Signature(Fraction(8))
	points[4]._signature = Signature(Fraction(2))

	conv:convert(points)

	t:eq(points[1].absoluteTime, 0)
	t:eq(points[2].absoluteTime, 4)
	t:eq(points[3].absoluteTime, 12)
	t:eq(points[4].absoluteTime, 20)
	t:eq(points[5].absoluteTime, 22)

	-- short mode
	points[3]._signature = Signature()
	points[5]._signature = Signature()

	conv:convert(points)

	t:eq(points[1].absoluteTime, 0)
	t:eq(points[2].absoluteTime, 4)
	t:eq(points[3].absoluteTime, 12)
	t:eq(points[4].absoluteTime, 16)
	t:eq(points[5].absoluteTime, 18)
end

return test
