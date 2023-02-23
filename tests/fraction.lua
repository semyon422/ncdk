local ncdk = require("ncdk")

local Fraction = ncdk.Fraction

assert(Fraction(0) == Fraction())
assert(Fraction:new(0) == Fraction:new())
assert(Fraction:new(0, 1) == Fraction:new(0, 2))
assert(Fraction:new(2, 1) == Fraction:new(2))
assert(Fraction:new(-1, 1) == Fraction:new(1, -1))
assert(Fraction:new(15, 9) == Fraction:new(5, 3))
assert(Fraction:new(Fraction:new(15), Fraction:new(9)) == Fraction:new(5, 3))
assert(Fraction:new(15, Fraction:new(9)) == Fraction:new(5, 3))
assert(Fraction:new(Fraction:new(15), 9) == Fraction:new(5, 3))

assert(Fraction:new(1) < Fraction:new(2))
assert(Fraction:new(1) <= Fraction:new(2))
assert(Fraction:new(2) <= Fraction:new(2))
assert(Fraction:new(2) > Fraction:new(1))
assert(Fraction:new(2) >= Fraction:new(1))
assert(Fraction:new(2) >= Fraction:new(2))

assert(-Fraction:new(2) == Fraction:new(-2))

assert(Fraction:new(1, 2):tonumber() == 1 / 2)
assert(Fraction:new(5, 4) % 1 == Fraction:new(1, 4))
assert(Fraction:new(-5, 4) % 1 == Fraction:new(3, 4))
assert(8 % Fraction:new(3) == 2)
print(math.abs(1.1 % Fraction:new(1001, 1000) - 0.099) < 1e-6)

-- __mod(a, b) return a - b * (a / b):floor() end
-- for i = -10, 10 do for j = -10, 10 do for k = -10, 10 do for l = -10, 10 do
-- 	if j * k * l ~= 0 then
-- 		assert(
-- 			math.abs(((i + 1e-9) / j) % (k / l) - Fraction(i, j) % Fraction(k, l)) < 1e-6 or
-- 			math.abs(((i - 1e-9) / j) % (k / l) - Fraction(i, j) % Fraction(k, l)) < 1e-6
-- 		)
-- 	end
-- end end end end

assert(tostring(Fraction:new()) == "0.0/1")
assert(tostring(Fraction:new(1, 2)) == "0.1/2")
assert(tostring(Fraction:new(1)) == "1.0/1")
assert(tostring(Fraction:new(-3, 2)) == "-1.1/2")
assert(tostring(Fraction:new(-5, 3)) == "-1.2/3")
assert(tostring(Fraction:new(-1, 3)) == "-0.1/3")

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
assert(Fraction:new(-1.234, 1, true) == Fraction:new(-1, 1))
assert(Fraction:new(1.234, 10, true) == Fraction:new(12, 10))
assert(Fraction:new(1.234, 100, true) == Fraction:new(123, 100))

assert(Fraction:new(1.234, 1, false) == Fraction:new(1, 1))
assert(Fraction:new(-1.234, 1, false) == Fraction:new(-1, 1))
assert(Fraction:new(1.234, 10, false) == Fraction:new(11, 9))
assert(Fraction:new(1.234, 100, false) == Fraction:new(58, 47))
