local TimePoint = {}

local mt = {__index = TimePoint}

function TimePoint:new()
	return setmetatable({}, mt)
end

function TimePoint:compute()
	self.absoluteTime = self.timeData:getAbsoluteTime(self.measureTime, self.side)
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
