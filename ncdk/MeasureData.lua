local class = require("class")
local Fraction = require("ncdk.Fraction")

---@class ncdk.MeasureData
---@operator call: ncdk.MeasureData
local MeasureData = class()

MeasureData.start = Fraction(0)

---@param start ncdk.Fraction
function MeasureData:new(start)
	self:set(start)
end

---@param start ncdk.Fraction
---@return boolean
function MeasureData:set(start)
	local _start = self.start
	self.start = start
	return _start ~= start
end

---@param a ncdk.MeasureData
---@return string
function MeasureData.__tostring(a)
	return tostring(a.timePoint) .. "," .. a.start
end

---@param a ncdk.MeasureData
---@param b ncdk.MeasureData
---@return boolean
function MeasureData.__eq(a, b)
	return a.timePoint == b.timePoint
end

---@param a ncdk.MeasureData
---@param b ncdk.MeasureData
---@return boolean
function MeasureData.__lt(a, b)
	return a.timePoint < b.timePoint
end

---@param a ncdk.MeasureData
---@param b ncdk.MeasureData
---@return boolean
function MeasureData.__le(a, b)
	return a.timePoint <= b.timePoint
end

return MeasureData
