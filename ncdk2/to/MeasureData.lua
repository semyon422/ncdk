local class = require("class")
local Fraction = require("ncdk.Fraction")

---@class ncdk2.MeasureData
---@operator call: ncdk2.MeasureData
local MeasureData = class()

MeasureData.start = Fraction(0)

---@param start ncdk.Fraction?
function MeasureData:new(start)
	self.start = start
end

---@param a ncdk.MeasureData
---@return string
function MeasureData.__tostring(a)
	return ("MeasureData(%s)"):format(a.start)
end

return MeasureData
