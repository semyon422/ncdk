local class = require("class")

---@class ncdk.SignatureData
---@operator call: ncdk.SignatureData
local SignatureData = class()

---@param signature ncdk.Fraction
function SignatureData:new(signature)
	self:set(signature)
end

---@param signature ncdk.Fraction
---@return boolean
function SignatureData:set(signature)
	local _signature = self.signature
	self.signature = signature
	return _signature ~= signature
end

---@param a ncdk.SignatureData
---@return string
function SignatureData.__tostring(a)
	return tostring(a.timePoint) .. "," .. a.signature
end

---@param a ncdk.SignatureData
---@param b ncdk.SignatureData
---@return boolean
function SignatureData.__eq(a, b)
	return a.timePoint == b.timePoint
end

---@param a ncdk.SignatureData
---@param b ncdk.SignatureData
---@return boolean
function SignatureData.__lt(a, b)
	return a.timePoint < b.timePoint
end

---@param a ncdk.SignatureData
---@param b ncdk.SignatureData
---@return boolean
function SignatureData.__le(a, b)
	return a.timePoint <= b.timePoint
end

return SignatureData
