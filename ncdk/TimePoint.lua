local TimePoint = {}

TimePoint.visualTime = 0
TimePoint.visualSection = 0

function TimePoint:new()
	local timePoint = {}
	timePoint.ptr = tonumber((("%p"):format(timePoint)):sub(3, -1), 16)
	self.__index = self
	return setmetatable(timePoint, self)
end

local ignoredKeys = {"ptr"}
for _, k in ipairs(ignoredKeys) do
	ignoredKeys[k] = true
end
function TimePoint:clone(timePoint)
	timePoint = timePoint or TimePoint:new()
	for k, v in pairs(self) do
		if not ignoredKeys[k] then
			timePoint[k] = v
		end
	end
	return timePoint
end

function TimePoint:getVisualTime(timePoint)
	if self.visualSection ~= timePoint.visualSection then
		return (self.visualSection - timePoint.visualSection) / 0
	end
	local globalSpeed = timePoint.velocityData and timePoint.velocityData.globalSpeed or 1
	local localSpeed = self.velocityData and self.velocityData.localSpeed or 1
	return (self.visualTime - timePoint.visualTime) * globalSpeed * localSpeed + timePoint.absoluteTime
end

function TimePoint:compare(timePoint, mode)
	assert(mode, "missing mode")
	if mode == "visual" then
		if self.visualSection == timePoint.visualSection then
			return self.visualTime < timePoint.visualTime
		end
		return self.visualSection < timePoint.visualSection
	elseif mode == "absolute" then
		return self.absoluteTime < timePoint.absoluteTime
	end
end

return TimePoint
