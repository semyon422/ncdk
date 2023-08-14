local class = require("class")
local Fraction = require("ncdk.Fraction")

local MeasureData = class()

MeasureData.start = Fraction(0)

function MeasureData:new(start)
	self:set(start)
end

function MeasureData:set(start)
	local _start = self.start
	self.start = start
	return _start ~= start
end

function MeasureData.__tostring(a)
	return tostring(a.timePoint) .. "," .. a.start
end

function MeasureData.__eq(a, b)
	return a.timePoint == b.timePoint
end
function MeasureData.__lt(a, b)
	return a.timePoint < b.timePoint
end
function MeasureData.__le(a, b)
	return a.timePoint <= b.timePoint
end

return MeasureData
