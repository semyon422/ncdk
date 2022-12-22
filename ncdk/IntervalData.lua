local IntervalData = {}

local mt = {__index = IntervalData}

function IntervalData:new(intervals)
	local intervalData = {}

	assert(intervals > 0, "intervals should be greater than 0")
	intervalData.intervals = intervals

	return setmetatable(intervalData, mt)
end

function IntervalData:set(intervals)
	local _intervals = self.intervals
	self.intervals = intervals
	return _intervals ~= intervals
end

function IntervalData:getPair()
	local a = self
	local n = a.next
	if n then
		return a, n
	end
	local p = a.prev
	if not p then
		return
	end
	return p, a, true
end

function IntervalData:getBeatLength()
	local intervalData, nextIntervalData = self:getPair()
	if not intervalData then
		return
	end
	local _a, _b = intervalData.timePoint, nextIntervalData.timePoint
	return (_b.absoluteTime - _a.absoluteTime) / intervalData.intervals
end

function mt.__tostring(a)
	return a.timePoint.absoluteTime .. "," .. a.intervals
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
