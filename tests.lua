package.path = package.path .. ";./?.lua;./?/init.lua"

local ncdk = require("ncdk")

-- Fraction
local Fraction = ncdk.Fraction

assert(Fraction:new(0) == Fraction:new())
assert(Fraction:new(0, 1) == Fraction:new(0, 2))
assert(Fraction:new(2, 1) == Fraction:new(2))
assert(Fraction:new(-1, 1) == Fraction:new(1, -1))
assert(Fraction:new(15, 9) == Fraction:new(5, 3))

assert(Fraction:new(1, 2):tonumber() == 1 / 2)
assert(Fraction:new(1, 2):tostring() == "1/2")
assert(tostring(Fraction:new(1, 2)) == "1/2")
assert(tostring(Fraction:new(1)) == "1")

assert(type(Fraction:new(1) + 1) == "table")
assert(type(Fraction:new(1) - 1) == "table")
assert(type(Fraction:new(1) * 1) == "table")
assert(type(Fraction:new(1) / 1) == "table")
assert(type(1 + Fraction:new(1)) == "number")
assert(type(1 - Fraction:new(1)) == "number")
assert(type(1 * Fraction:new(1)) == "number")
assert(type(1 / Fraction:new(1)) == "number")

assert(Fraction:new(1, 2) + "1" == Fraction:new(3, 2))
assert(Fraction:new(1, 2) + 1 == Fraction:new(3, 2))
assert(1 + Fraction:new(1, 2) == 3 / 2)

assert(Fraction:new(1, 2) + 0 == Fraction:new(1, 2))
assert(Fraction:new(1, 2) + Fraction:new(2, 3) == Fraction:new(7, 6))
assert(Fraction:new(1, 2) - Fraction:new(2, 3) == -Fraction:new(1, 6))

assert(Fraction:new(1, 2) * 1 == Fraction:new(1, 2))
assert(Fraction:new(5, 3) * Fraction:new(7, 11) == Fraction:new(35, 33))
assert(Fraction:new(5, 3) / Fraction:new(7, 11) == Fraction:new(55, 21))

assert(Fraction:new(3, 2):ceil() == Fraction:new(2, 1))
assert(Fraction:new(3, 2):floor() == Fraction:new(1, 1))
assert(Fraction:new(-3, 2):ceil() == Fraction:new(-1, 1))
assert(Fraction:new(-3, 2):floor() == Fraction:new(-2, 1))

assert(Fraction:fromString("-1") == Fraction:new(-1, 1))
assert(Fraction:fromString("+1") == Fraction:new(1, 1))
assert(Fraction:fromString("1/2") == Fraction:new(1, 2))
assert(Fraction:fromNumber(1.234, 1) == Fraction:new(1, 1))
assert(Fraction:fromNumber(-1.234, 1) == Fraction:new(-2, 1))
assert(Fraction:fromNumber(1.234, 1e1) == Fraction:new(12, 10))
assert(Fraction:fromNumber(1.234, 1e2) == Fraction:new(123, 100))

print("Fraction: OK")
