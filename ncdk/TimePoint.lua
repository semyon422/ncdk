local TimePoint = {}

function TimePoint:new()
	local timePoint = {}
	timePoint.ptr = tonumber((("%p"):format(timePoint)):sub(3, -1), 16)
	self.__index = self
	return setmetatable(timePoint, self)
end

function TimePoint:getVisualTime(timePoint)
	local globalSpeed = timePoint.velocityData and timePoint.velocityData.globalSpeed or 1
	local localSpeed = self.velocityData and self.velocityData.localSpeed or 1
	return (self.visualTime - timePoint.visualTime) * globalSpeed * localSpeed + timePoint.absoluteTime
end

return TimePoint
