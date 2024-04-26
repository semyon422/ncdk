local class = require("class")

---@class ncdk2.Signature
---@operator call: ncdk2.Signature
local Signature = class()

---@param signature ncdk.Fraction
function Signature:new(signature)
	self.signature = signature
end

---@param a ncdk2.Signature
---@return string
function Signature.__tostring(a)
	return ("Signature(%s)"):format(a.signature)
end

return Signature
