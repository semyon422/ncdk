local ncdk = require("ncdk")

local Fraction = ncdk.Fraction

assert(Fraction(0) == Fraction())
assert(Fraction:new(0) == Fraction:new())
assert(Fraction:new(0, 1) == Fraction:new(0, 2))
assert(Fraction:new(2, 1) == Fraction:new(2))
assert(Fraction:new(-1, 1) == Fraction:new(1, -1))
assert(Fraction:new(15, 9) == Fraction:new(5, 3))

assert(Fraction:new(1) < Fraction:new(2))
assert(Fraction:new(1) <= Fraction:new(2))
assert(Fraction:new(2) <= Fraction:new(2))
assert(Fraction:new(2) > Fraction:new(1))
assert(Fraction:new(2) >= Fraction:new(1))
assert(Fraction:new(2) >= Fraction:new(2))

assert(-Fraction:new(2) == Fraction:new(-2))

assert(Fraction:new(1, 2):tonumber() == 1 / 2)
assert(tostring(Fraction:new(1, 2)) == "1/2")
assert(tostring(Fraction:new(1)) == "1/1")

assert(type(Fraction:new(1) + 1) == "table")
assert(type(Fraction:new(1) - 1) == "table")
assert(type(Fraction:new(1) * 1) == "table")
assert(type(Fraction:new(1) / 1) == "table")
assert(type(1 + Fraction:new(1)) == "number")
assert(type(1 - Fraction:new(1)) == "number")
assert(type(1 * Fraction:new(1)) == "number")
assert(type(1 / Fraction:new(1)) == "number")

assert(Fraction:new(1, 2) + 1 == Fraction:new(3, 2))
assert(1 + Fraction:new(1, 2) == 3 / 2)

assert(Fraction:new(1, 2) + 0 == Fraction:new(1, 2))
assert(Fraction:new(1, 2) + Fraction:new(2, 3) == Fraction:new(7, 6))
assert(Fraction:new(1, 2) - Fraction:new(2, 3) == -Fraction:new(1, 6))

assert(Fraction:new(1, 2) * 1 == Fraction:new(1, 2))
assert(Fraction:new(5, 3) * Fraction:new(7, 11) == Fraction:new(35, 33))
assert(Fraction:new(5, 3) / Fraction:new(7, 11) == Fraction:new(55, 21))

assert(Fraction:new(3, 2):ceil() == 2)
assert(Fraction:new(3, 2):floor() == 1)
assert(Fraction:new(-3, 2):ceil() == -1)
assert(Fraction:new(-3, 2):floor() == -2)

assert(Fraction:new(1.234, 1, true) == Fraction:new(1, 1))
assert(Fraction:new(-1.234, 1, true) == Fraction:new(-2, 1))
assert(Fraction:new(1.234, 10, true) == Fraction:new(12, 10))
assert(Fraction:new(1.234, 100, true) == Fraction:new(123, 100))

assert(Fraction:new(1.234, 1, false) == Fraction:new(1, 1))
assert(Fraction:new(-1.234, 1, false) == Fraction:new(-1, 1))
assert(Fraction:new(1.234, 10, false) == Fraction:new(11, 9))
assert(Fraction:new(1.234, 100, false) == Fraction:new(58, 47))
