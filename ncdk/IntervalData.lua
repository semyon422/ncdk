local IntervalData = {}

local mt = {__index = IntervalData}

function IntervalData:new(beats)
	local intervalData = {}

	assert(type(beats) == "number" and beats >= 0 and beats % 1 == 0, "invalid beats: " .. beats)
	intervalData.beats = beats

	return setmetatable(intervalData, mt)
end

function IntervalData:set(beats)
	local _beats = self.beats
	self.beats = beats
	return _beats ~= beats
end

function IntervalData:start()
	return self.timePoint.time % 1
end

function IntervalData:_end()
	return self.next:start() + self.beats
end

function IntervalData:getDuration()
	return self.next:start() - self:start() + self.beats
end

function IntervalData:getBeatDuration()
	local a, b = self, self.next
	local _a, _b = a.timePoint, b.timePoint
	return (_b.absoluteTime - _a.absoluteTime) / self:getDuration()
end

function IntervalData:getTempo()
	return 60 / self:getBeatDuration()
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
	return time .. "," .. a:start() .. "+" .. a.beats
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
