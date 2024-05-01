local TempoConnector = require("ncdk2.convert.TempoConnector")
local Fraction = require("ncdk.Fraction")

local test = {}

function test.basic(t)
	local tc = TempoConnector(4, 0.005)

	t:eq(tc:connect(0, 1, 2.001), Fraction(2))
	t:eq(tc:connect(0, 1, 1.501), Fraction(3, 2))
	t:eq(tc:connect(0, 1, 2.006), Fraction(2))
	t:eq(tc:connect(0, 1, 1.994), Fraction(7, 4))
end

return test
