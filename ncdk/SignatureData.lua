local SignatureData = {}

local mt = {__index = SignatureData}

function SignatureData:new(signature)
	local expandData = {}

	expandData.signature = signature

	return setmetatable(expandData, mt)
end

function SignatureData:set(signature)
	local _signature = self.signature
	self.signature = signature
	return _signature ~= signature
end

function mt.__tostring(a)
	return tostring(a.timePoint) .. "," .. a.signature
end

function mt.__eq(a, b)
	return a.timePoint == b.timePoint
end
function mt.__lt(a, b)
	return a.timePoint < b.timePoint
end
function mt.__le(a, b)
	return a.timePoint <= b.timePoint
end

return SignatureData
