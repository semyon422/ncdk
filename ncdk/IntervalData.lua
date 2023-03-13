local Fraction = require("ncdk.Fraction")

local IntervalData = {}

local mt = {__index = IntervalData}

IntervalData.start = Fraction:new(0)

function IntervalData:new(beats, start)
	local intervalData = {}

	assert(type(beats) == "number" and beats >= 0 and beats % 1 == 0)
	intervalData.beats = beats

	assert(not start or type(start) == "table" and start[1] >= 0 and start[1] < start[2])
	intervalData.start = start

	return setmetatable(intervalData, mt)
end

function IntervalData:set(start, beats)
	local _start, _beats = self.start, self.beats
	self.start = start
	self.beats = beats
	return _start ~= start or _beats ~= beats
end

function IntervalData:_end()
	return self.next.start + self.beats
end

function IntervalData:getDuration()
	return self.next.start - self.start + self.beats
end

function IntervalData:getBeatDuration()
	local a, b = self, self.next
	local _a, _b = a.timePoint, b.timePoint
	return (_b.absoluteTime - _a.absoluteTime) / self:getDuration()
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

function mt.__tostring(a)
	local time = a.timePoint:getAbsoluteTimeKey()
	if rawget(a, "start") then
		return time .. "," .. a.start .. "+" .. a.beats
	end
	return time .. "," .. a.beats
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
