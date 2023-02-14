local Fraction = require("ncdk.Fraction")

local MeasureData = {}

local mt = {__index = MeasureData}

MeasureData.start = Fraction:new(0)

function MeasureData:new(start)
	return setmetatable({start = start}, mt)
end

function MeasureData:set(start)
	local _start = self.start
	self.start = start
	return _start ~= start
end

function mt.__tostring(a)
	return tostring(a.timePoint) .. "," .. a.time
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

return MeasureData
