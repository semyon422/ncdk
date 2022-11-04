local SignatureTable = require("ncdk.SignatureTable")
local Fraction = require("ncdk.Fraction")

local function F(n)
	return Fraction:new(n, 1000, true)
end

do
	local st = SignatureTable:new(F(4))
	st:setMode("short")

	st:setSignature(0, F(8))

	assert(st:getSignature(0) == F(8))
	assert(st:getSignature(-1) == F(4))
	assert(st:getSignature(1) == F(4))
end

do
	local st = SignatureTable:new(F(4))
	st:setMode("long")

	st:setSignature(0, F(8))

	assert(st:getSignature(0) == F(8))
	assert(st:getSignature(-1) == F(4))
	assert(st:getSignature(1) == F(8))
end
