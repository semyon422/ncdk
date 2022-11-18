local TimePoint = {}

local mt = {__index = TimePoint}

TimePoint.side = -1
TimePoint.visualSide = -1

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

local format = "%s%s%s"
function mt.__tostring(a)
	local time = a.absoluteTime
	if a.measureTime then
		time = a.measureTime
	end
	return format:format(time, a.side == -1 and "<-" or "->", a.visualSide == -1 and "<-" or "->")
end

local function getTimes(a, b)
	if a.measureTime and b.measureTime then
		return a.measureTime, b.measureTime
	end
	return a.absoluteTime, b.absoluteTime
end

function mt.__eq(a, b)
	local at, bt = getTimes(a, b)
	return at == bt and a.side == b.side and a.visualSide == b.visualSide
end

function mt.__lt(a, b)
	local at, bt = getTimes(a, b)
	return at < bt or (at == bt and a.side < b.side) or (at == bt and a.side == b.side and a.visualSide < b.visualSide)
end

function mt.__le(a, b)
	local at, bt = getTimes(a, b)
	return at < bt or (at == bt and a.side < b.side) or (at == bt and a.side == b.side and a.visualSide <= b.visualSide)
end

return TimePoint
