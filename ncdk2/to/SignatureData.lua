local class = require("class")

---@class ncdk2.SignatureData
---@operator call: ncdk2.SignatureData
local SignatureData = class()

---@param signature ncdk.Fraction
function SignatureData:new(signature)
	self.signature = signature
end

---@param a ncdk.SignatureData
---@return string
function SignatureData.__tostring(a)
	return ("SignatureData(%s)"):format(a.signature)
end

return SignatureData
