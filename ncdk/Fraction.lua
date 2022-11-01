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

local Fraction = {}

local mt = {__index = Fraction}

function Fraction:new(n, d, decimal)
	n, d = n or 0, d or 1
	assert(type(n) == "number" and type(d) == "number", "numbers expected")

	if decimal then
		n = math.floor(n * d)
	end

	assert(n % 1 == 0, ("invalid numerator: %s"):format(n))
	assert(d % 1 == 0 and d ~= 0, ("invalid denominator: %s"):format(d))

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

function mt.__tostring(a)
	return ("%d/%d"):format(a[1], a[2])
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
