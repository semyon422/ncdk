local IntervalAbsolute = require("ncdk2.convert.IntervalAbsolute")
local IntervalLayer = require("ncdk2.layers.IntervalLayer")
local Interval = require("ncdk2.to.Interval")
local Fraction = require("ncdk.Fraction")

local test = {}

function test.basic(t)
	local conv = IntervalAbsolute()

	local layer = IntervalLayer()

	local p0 = layer:getPoint(Fraction(0))
	local p1 = layer:getPoint(Fraction(1, 4))
	local p2 = layer:getPoint(Fraction(5, 4))
	local p3 = layer:getPoint(Fraction(2))

	p0._interval = Interval(0)
	p1._interval = Interval(0.25)
	p2._interval = Interval(1.25)

	layer:compute()

	conv:convert(layer)

	t:eq(p0:getBeatModulo(), 0)
	t:eq(p1:getBeatModulo(), 0.25)
	t:eq(p2:getBeatModulo(), 0.25)
	t:eq(p3:getBeatModulo(), 0)
end

return test
