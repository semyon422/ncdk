local function gcd(a, b)
	a, b = math.abs(a), math.abs(b)
	a, b = math.max(a, b), math.min(a, b)

	if a == 1 or b == 1 or a == 0 or b == 0 then
		return 1
	end
	if a == b then
		return a
	end
	if a % b == 0 then
		return b
	end

	return gcd(b, a % b)
end

local function reduce(n, d)
	if n == 0 then
		return 0, 1
	end
	if n * d > 0 and n < 0 or d < 0 and n > 0 then
		n, d = -n, -d
	end

	local r = gcd(n, d)
	return n / r, d / r
end

-- https://stackoverflow.com/questions/4385580/finding-the-closest-integer-fraction-to-a-given-random-real-between-0-1-given
local function closest(R, limit)
	local int, r = math.floor(R), R - math.floor(R)

	local a_num, a_den = 0, 1
	local b_num, b_den = 1, 1

	while true do
		local n, d = a_num + b_num, a_den + b_den

		if d > limit then
			if r - a_num / a_den < b_num / b_den - r then
				return a_num + int * a_den, a_den
			else
				return b_num + int * b_den, b_den
			end
		end

		if n / d < r then
			a_num, a_den = n, d
		else
			b_num, b_den = n, d
		end
	end
end

local Fraction = {}

local mt = {__index = Fraction}

function Fraction:new(n, d, decimal)
	local _n = type(n) == "number" and n or 0
	local _d = type(d) == "number" and d or 1
	if type(n) == "table" then
		_n, _d = n[1], _d * n[2]
	end
	if type(d) == "table" then
		_n, _d = _n * d[2], _d * d[1]
	end
	n, d = _n, _d

	assert(d % 1 == 0 and d ~= 0, ("invalid denominator: %s"):format(d))

	if decimal == true then
		n = math.floor(n * d)
	elseif decimal == false then
		n, d = closest(n, d)
	end

	assert(n % 1 == 0, ("invalid numerator: %s"):format(n))

	return setmetatable({reduce(n, d)}, mt)
end

setmetatable(Fraction, {__call = Fraction.new})

local function fraction(n, d, decimal)
	if type(n) ~= "table" then
		return Fraction:new(n, d, decimal)
	elseif getmetatable(n) ~= mt then
		return Fraction:new(n[1], n[2])
	end
	return n
end

function Fraction:floor()
	return math.floor(self[1] / self[2])
end

function Fraction:ceil()
	return math.ceil(self[1] / self[2])
end

function Fraction:tonumber()
	return self[1] / self[2]
end

function Fraction:integral()
	local n, d = self[1], self[2]
	return (n - n % d) / d
end

function Fraction:fractional()
	local n, d = self[1], self[2]
	return Fraction:new(n % d, d)
end

function mt.__tostring(a)
	local n, d = math.abs(a[1]), a[2]
	return ("%s%d.%d/%d"):format(a[1] < 0 and "-" or "", math.floor(n / d), n % d, d)
end

function mt.__concat(a, b)
	return tostring(a) .. tostring(b)
end

function mt.__unm(a)
	return fraction(-a[1], a[2])
end

local function add(a, b)
	return fraction(a[1] * b[2] + a[2] * b[1], a[2] * b[2])
end
local function sub(a, b)
	return fraction(a[1] * b[2] - a[2] * b[1], a[2] * b[2])
end
local function mul(a, b)
	return fraction(a[1] * b[1], a[2] * b[2])
end
local function div(a, b)
	return fraction(a[1] * b[2], a[2] * b[1])
end

function mt.__add(a, b)
	return type(a) == "number" and a + b:tonumber() or add(a, fraction(b))
end
function mt.__sub(a, b)
	return type(a) == "number" and a - b:tonumber() or sub(a, fraction(b))
end
function mt.__mul(a, b)
	return type(a) == "number" and a * b:tonumber() or mul(a, fraction(b))
end
function mt.__div(a, b)
	return type(a) == "number" and a / b:tonumber() or div(a, fraction(b))
end

function mt.__eq(a, b)
	return a[1] * b[2] == a[2] * b[1]
end
function mt.__lt(a, b)
	return a[1] * b[2] < a[2] * b[1]
end
function mt.__le(a, b)
	return a[1] * b[2] <= a[2] * b[1]
end

return Fraction
