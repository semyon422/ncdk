local TimedObject = require("ncdk2.to.TimedObject")

---@class ncdk2.SignatureData: ncdk2.TimedObject
---@operator call: ncdk2.SignatureData
local SignatureData = TimedObject + {}

---@param timePoint ncdk2.TimePoint
---@param signature ncdk.Fraction
function SignatureData:new(timePoint, signature)
	TimedObject.new(self, timePoint)
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

SignatureData.__eq = TimedObject.__eq
SignatureData.__lt = TimedObject.__lt
SignatureData.__le = TimedObject.__le

return SignatureData
