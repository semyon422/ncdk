local class = require("class")

local SignatureData = class()

function SignatureData:new(signature)
	self:set(signature)
end

function SignatureData:set(signature)
	local _signature = self.signature
	self.signature = signature
	return _signature ~= signature
end

function SignatureData.__tostring(a)
	return tostring(a.timePoint) .. "," .. a.signature
end

function SignatureData.__eq(a, b)
	return a.timePoint == b.timePoint
end
function SignatureData.__lt(a, b)
	return a.timePoint < b.timePoint
end
function SignatureData.__le(a, b)
	return a.timePoint <= b.timePoint
end

return SignatureData
