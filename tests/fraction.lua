local ncdk = require("ncdk")

local Fraction = ncdk.Fraction

assert(Fraction:new(nil) == Fraction(0))
assert(Fraction() + nil == Fraction(0))

assert(Fraction(0) == Fraction())
assert(Fraction:new(0) == Fraction())
assert(Fraction:new(0, 1) == Fraction(0, 2))
assert(Fraction:new(2, 1) == Fraction(2))
assert(Fraction:new(-1, 1) == Fraction(1, -1))
assert(Fraction:new(15, 9) == Fraction(5, 3))
assert(Fraction:new(Fraction:new(15), Fraction:new(9)) == Fraction(5, 3))
assert(Fraction:new(15, Fraction:new(9)) == Fraction(5, 3))
assert(Fraction:new(Fraction:new(15), 9) == Fraction(5, 3))

assert(Fraction:new(1) < Fraction:new(2))
assert(Fraction:new(1) <= Fraction(2))
assert(Fraction:new(2) <= Fraction(2))
assert(Fraction:new(2) > Fraction:new(1))
assert(Fraction:new(2) >= Fraction(1))
assert(Fraction:new(2) >= Fraction(2))

assert(-Fraction:new(2) == Fraction(-2))

assert(Fraction:new(1, 2):tonumber() == 1 / 2)
assert(Fraction:new(5, 4) % 1 == Fraction(1, 4))
assert(Fraction:new(-5, 4) % 1 == Fraction(3, 4))
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

assert(tostring(Fraction()) == "0.0/1")
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

assert(Fraction:new(1, 2) + 1 == Fraction(3, 2))
assert(1 + Fraction:new(1, 2) == 3 / 2)

assert(Fraction:new(1, 2) + 0 == Fraction(1, 2))
assert(Fraction:new(1, 2) + Fraction:new(2, 3) == Fraction(7, 6))
assert(Fraction:new(1, 2) - Fraction:new(2, 3) == -Fraction:new(1, 6))

assert(Fraction:new(1, 2) * 1 == Fraction(1, 2))
assert(Fraction:new(5, 3) * Fraction:new(7, 11) == Fraction(35, 33))
assert(Fraction:new(5, 3) / Fraction:new(7, 11) == Fraction(55, 21))

assert(Fraction:new(3, 2):ceil() == 2)
assert(Fraction:new(3, 2):floor() == 1)
assert(Fraction:new(-3, 2):ceil() == -1)
assert(Fraction:new(-3, 2):floor() == -2)

assert(Fraction:new(1.234, 1, true) == Fraction(1, 1))
assert(Fraction:new(-1.234, 1, true) == Fraction(-1, 1))
assert(Fraction:new(1.234, 10, true) == Fraction(12, 10))
assert(Fraction:new(1.234, 100, true) == Fraction(123, 100))

assert(Fraction:new(1.234, 1, false) == Fraction(1, 1))
assert(Fraction:new(-1.234, 1, false) == Fraction(-1, 1))
assert(Fraction:new(1.234, 10, false) == Fraction(11, 9))
assert(Fraction:new(1.234, 100, false) == Fraction(58, 47))

collectgarbage("stop")
assert(("%p"):format(Fraction:new(99, 101)) == ("%p"):format(Fraction:new(100, 101) - Fraction:new(1, 101)))
collectgarbage("restart")

-- local p = ("%p"):format(Fraction:new(99, 101))
-- assert(p ~= ("%p"):format(Fraction:new(99, 101)))
