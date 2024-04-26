local class = require("class")
local Fraction = require("ncdk.Fraction")

---@class ncdk2.Measure
---@operator call: ncdk2.Measure
local Measure = class()

Measure.start = Fraction(0)

---@param start ncdk.Fraction?
function Measure:new(start)
	self.start = start
end

---@param a ncdk2.Measure
---@return string
function Measure.__tostring(a)
	return ("Measure(%s)"):format(a.start)
end

return Measure
