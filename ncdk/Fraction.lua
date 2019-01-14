local Fraction = {}

local Fraction_metatable = {}
Fraction_metatable.__index = Fraction

Fraction.new = function(self, numerator, denominator)
	local fraction = {}
	
	numerator = numerator or 0
	denominator = denominator or 1
	
	if numerator % 1 ~= 0 or denominator % 1 ~= 0 or denominator == 0 then
		error(
			("\ninvalid fraction: %s(%s) / %s(%s)"):format(
				type(numerator), tostring(numerator),
				type(denominator), tostring(denominator)
			)
		)
	end
	
	fraction.numerator = tonumber(numerator)
	fraction.denominator = tonumber(denominator)
	fraction.number = fraction.numerator / fraction.denominator
	
	setmetatable(fraction, Fraction_metatable)
	
	fraction:reduce()
	
	return fraction
end

Fraction.fromString = function(self, line)
	local numerator, denominator
	if line:find("/") then
		numerator, denominator = line:match("^([%-%+]?%d+)/(%d+)$")
	else
		numerator = line:match("^([%-%+]?%d+)$"), 1
	end
	
	if not numerator then
		error(("\ninvalid fraction: %s(%s)"):format(line))
	end
	
	return Fraction:new(tonumber(numerator), tonumber(denominator))
end

Fraction.fromNumber = function(self, number, accuracy)
	return Fraction:new(math.floor(number * accuracy), accuracy)
end

local gcd
gcd = function(a, b)
	local a, b = math.abs(a), math.abs(b)
	a, b = math.max(a, b), math.min(a, b)
	
	if a == b then
		return a
	end
	if a == 1 or b == 1 or a == 0 or b == 0 then
		return 1
	end
	if a % b == 0 then
		return b
	end
	
	return gcd(b, a % b)
end

Fraction.reduce = function(self)
	if self.numerator * self.denominator > 0 and self.numerator < 0 then
		self.numerator = -self.numerator
		self.denominator = -self.denominator
	end
	if self.denominator < 0 and self.numerator > 0 then
		self.numerator = -self.numerator
		self.denominator = -self.denominator
	end
	if self.numerator == 0 then
		self.numerator = 0
		self.denominator = 1
		return
	end
	
	local reduceFactor = gcd(self.numerator, self.denominator)
	
	self.numerator = self.numerator / reduceFactor
	self.denominator = self.denominator / reduceFactor
end

Fraction.floor = function(self)
	return Fraction:new(math.floor(self.numerator / self.denominator))
end

Fraction.ceil = function(self)
	return Fraction:new(math.ceil(self.numerator / self.denominator))
end

Fraction.tonumber = function(self)
	return self.number
end

Fraction.tostring = function(self)
	if self.denominator == 1 then
		return tostring(self.numerator)
	else
		return self.numerator .. "/" .. self.denominator
	end
end

Fraction_metatable.__tostring = function(self)
	return self:tostring()
end

Fraction_metatable.__unm = function(fa)
	return Fraction:new(
		-fa.numerator,
		fa.denominator
	)
end

local fraction = function(n)
	return type(n) ~= "table" and n % 1 == 0 and Fraction:new(tonumber(n)) or n
end

local add = function(a, b)
	return Fraction:new(
		a.numerator * b.denominator + a.denominator * b.numerator,
		a.denominator * b.denominator
	)
end
Fraction_metatable.__add = function(a, b)
	if type(a) == "number" then
		return a + b:tonumber()
	end
	
	return add(a, fraction(b))
end

local sub = function(a, b)
	return Fraction:new(
		a.numerator * b.denominator - a.denominator * b.numerator,
		a.denominator * b.denominator
	)
end
Fraction_metatable.__sub = function(a, b)
	if type(a) == "number" then
		return a - b:tonumber()
	end
	
	return sub(a, fraction(b))
end

local mul = function(a, b)
	return Fraction:new(
		a.numerator * b.numerator,
		a.denominator * b.denominator
	)
end
Fraction_metatable.__mul = function(a, b)
	if type(a) == "number" then
		return a * b:tonumber()
	end
	
	return mul(a, fraction(b))
end

local div = function(a, b)
	return Fraction:new(
		a.numerator * b.denominator,
		a.denominator * b.numerator
	)
end
Fraction_metatable.__div = function(a, b)
	if type(a) == "number" then
		return a / b:tonumber()
	end
	
	return div(a, fraction(b))
end

Fraction_metatable.__mod = function(a, b)
end

Fraction_metatable.__pow = function(a, b)
end

Fraction_metatable.__concat = function(a, b)	
	return tostring(a) .. tostring(b)
end

Fraction_metatable.__eq = function(a, b)
	return a.numerator * b.denominator == a.denominator * b.numerator
end

Fraction_metatable.__lt = function(a, b)
	return a.numerator * b.denominator < a.denominator * b.numerator
end

Fraction_metatable.__le = function(a, b)
	return a.numerator * b.denominator <= a.denominator * b.numerator
end

return Fraction
