local Layer = require("chartedit.Layer")
local Interval = require("chartedit.Interval")
local Fraction = require("ncdk.Fraction")

local test = {}

function test.basic(t)
	local layer = Layer()

	local interval = Interval(0, 1)

	local p_1 = layer:getPoint(interval, Fraction(0))
	local p_1_ = layer:getPoint(interval, Fraction(0))
	local p_2 = layer:getPoint(interval, Fraction(1))

	t:assert(p_1 == p_1_)
	t:assert(rawequal(p_1, p_1_))
	t:assert(p_1 ~= p_2)
	t:assert(not rawequal(p_1, p_2))
end

return test
