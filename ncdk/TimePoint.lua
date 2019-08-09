local TimePoint = {}

local TimePoint_metatable = {}
TimePoint_metatable.__index = TimePoint

TimePoint.new = function(self)
	local timePoint = {}
	
	setmetatable(timePoint, TimePoint_metatable)
	
	return timePoint
end

TimePoint.compute = function(self)
	self.absoluteTime = self.timeData:getAbsoluteTime(self.measureTime, self.side)
end

TimePoint.computeZeroClearVisualTime = function(self)
	self.zeroClearVisualTime
		= (self.absoluteTime - self.velocityData.timePoint.absoluteTime)
		* self.velocityData.currentSpeed:tonumber()
		+ self.velocityData.timePoint.zeroClearVisualTime
end

TimePoint.computeVisualTime = function(self, timePoint)
	self.currentVisualTime
		= (self.zeroClearVisualTime - timePoint.zeroClearVisualTime)
		* timePoint.velocityData.globalSpeed:tonumber()
		* self.velocityData.localSpeed:tonumber()
		+ timePoint.absoluteTime
end

TimePoint_metatable.__eq = function(tpa, tpb)
	if tpa.measureTime and tpb.measureTime then
		return tpa.measureTime.number == tpb.measureTime.number and tpa.side == tpb.side
	else
		return tpa.absoluteTime == tpb.absoluteTime and tpa.side == tpb.side
	end
end

TimePoint_metatable.__lt = function(tpa, tpb)
	if tpa.measureTime and tpb.measureTime then
		return tpa.measureTime.number < tpb.measureTime.number or (tpa.measureTime.number == tpb.measureTime.number and tpa.side < tpb.side)
	else
		return tpa.absoluteTime < tpb.absoluteTime or (tpa.absoluteTime == tpb.absoluteTime and tpa.side < tpb.side)
	end
end

TimePoint_metatable.__le = function(tpa, tpb)
	if tpa.measureTime and tpb.measureTime then
		return tpa.measureTime.number < tpb.measureTime.number or (tpa.measureTime.number == tpb.measureTime.number and tpa.side == tpb.side)
	else
		return tpa.absoluteTime < tpb.absoluteTime or (tpa.absoluteTime == tpb.absoluteTime and tpa.side == tpb.side)
	end
end

return TimePoint
