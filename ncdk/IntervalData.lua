local class = require("class")

local IntervalData = class()

function IntervalData:new(beats)
	assert(type(beats) == "number" and beats >= 0 and beats % 1 == 0, "invalid beats: " .. beats)
	self.beats = beats
end

function IntervalData:set(beats)
	local _beats = self.beats
	self.beats = beats
	return _beats ~= beats
end

function IntervalData:start()
	return self.timePoint.time % 1
end

function IntervalData:startn()
	return self.timePoint.time:tonumber() % 1
end

function IntervalData:_end()
	return self.next:start() + self.beats
end

function IntervalData:getDuration()
	local duration = self.next:startn() - self:startn() + self.beats
	if duration <= 0 then
		error("zero interval duration found: " .. tostring(self) .. ", " .. tostring(self.next))
	end
	return duration
end

function IntervalData:getBeatDuration()
	local a, b = self:getPair()
	if not a then
		return math.huge
	end
	local _a, _b = a.timePoint, b.timePoint
	return (_b.absoluteTime - _a.absoluteTime) / a:getDuration()
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

function IntervalData.__tostring(a)
	local time = a.timePoint:getAbsoluteTimeKey()
	return time .. "," .. a:start() .. "+" .. a.beats
end

-- prevent stackoverflow
function IntervalData.__eq(a, b)
	return a.timePoint.absoluteTime == b.timePoint.absoluteTime
end
function IntervalData.__lt(a, b)
	return a.timePoint.absoluteTime < b.timePoint.absoluteTime
end
function IntervalData.__le(a, b)
	return a.timePoint.absoluteTime <= b.timePoint.absoluteTime
end

return IntervalData
