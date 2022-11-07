local TimePoint = {}

local mt = {__index = TimePoint}

function TimePoint:new()
	return setmetatable({}, mt)
end

function TimePoint:computeZeroClearVisualTime()
	self.zeroClearVisualTime
		= (self.absoluteTime - self.velocityData.timePoint.absoluteTime)
		* self.velocityData.currentSpeed
		+ self.velocityData.timePoint.zeroClearVisualTime
end

function TimePoint:computeVisualTime(timePoint)
	self.currentVisualTime
		= (self.zeroClearVisualTime - timePoint.zeroClearVisualTime)
		* timePoint.velocityData.globalSpeed
		* self.velocityData.localSpeed
		+ timePoint.absoluteTime
end

local format = "%s%s"
function mt.__tostring(a)
	local time = a.absoluteTime
	if a.measureTime then
		time = a.measureTime
	end
	return format:format(time, a.side == -1 and "<-" or "->")
end

function mt.__eq(a, b)
	if a.measureTime and b.measureTime then
		return a.measureTime == b.measureTime and a.side == b.side
	else
		return a.absoluteTime == b.absoluteTime and a.side == b.side
	end
end

function mt.__lt(a, b)
	if a.measureTime and b.measureTime then
		return a.measureTime < b.measureTime or (a.measureTime == b.measureTime and a.side < b.side)
	else
		return a.absoluteTime < b.absoluteTime or (a.absoluteTime == b.absoluteTime and a.side < b.side)
	end
end

function mt.__le(a, b)
	if a.measureTime and b.measureTime then
		return a.measureTime < b.measureTime or (a.measureTime == b.measureTime and a.side == b.side)
	else
		return a.absoluteTime < b.absoluteTime or (a.absoluteTime == b.absoluteTime and a.side == b.side)
	end
end

return TimePoint
