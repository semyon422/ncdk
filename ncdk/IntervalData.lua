local IntervalData = {}

local mt = {__index = IntervalData}

function IntervalData:new(intervals)
	local intervalData = {}

	intervalData.intervals = intervals

	return setmetatable(intervalData, mt)
end

function IntervalData:set(intervals)
	local _intervals = self.intervals
	self.intervals = intervals
	return _intervals ~= intervals
end

function mt.__tostring(a)
	return tostring(a.timePoint) .. "," .. a.intervals
end

-- prevent stackoverflow
function mt.__eq(a, b)
	return a.timePoint.absoluteTime == b.timePoint.absoluteTime
end
function mt.__lt(a, b)
	return a.timePoint.absoluteTime < b.timePoint.absoluteTime
end
function mt.__le(a, b)
	return a.timePoint.absoluteTime <= b.timePoint.absoluteTime
end

return IntervalData
