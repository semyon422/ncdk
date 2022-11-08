local SpaceData = {}

local mt = {__index = SpaceData}

function SpaceData:new()
	local spaceData = {}

	spaceData.velocityDatas = {}

	return setmetatable(spaceData, mt)
end

function SpaceData:getVelocityDataVisualDuration(velocityDataIndex, startTime, endTime)
	local sign = 1
	if startTime > endTime then
		sign = -1
		startTime, endTime = endTime, startTime
	end

	local velocityData = self:getVelocityData(velocityDataIndex)
	local nextVelocityData = self:getVelocityData(velocityDataIndex + 1)

	local _startTime = velocityData.timePoint.absoluteTime
	local _endTime = nextVelocityData and nextVelocityData.timePoint and nextVelocityData.timePoint.absoluteTime

	if _endTime and startTime >= _endTime or velocityDataIndex > 1 and endTime <= _startTime then
		return 0
	end

	if velocityData.visualEndTimePoint then
		return velocityData.visualEndTimePoint.absoluteTime - velocityData.timePoint.absoluteTime
	end

	if velocityDataIndex == 1 or startTime > _startTime then
		_startTime = startTime
	end
	if not _endTime or endTime < _endTime then
		_endTime = endTime
	end

	return (_endTime - _startTime) * velocityData.currentSpeed * sign
end

function SpaceData:getVisualTime(targetTimePoint, currentTimePoint, clear)
	if targetTimePoint == currentTimePoint then
		return currentTimePoint.absoluteTime
	end

	local globalSpeed, localSpeed = 1, 1
	if not clear then
		local currentVelocityData = currentTimePoint.velocityData
		local targetVelocityData = targetTimePoint.velocityData

		globalSpeed = currentVelocityData.globalSpeed
		localSpeed = targetVelocityData.localSpeed
	end

	local duration = 0
	for i = 1, self:getVelocityDataCount() do
		duration = duration + self:getVelocityDataVisualDuration(i, currentTimePoint.absoluteTime, targetTimePoint.absoluteTime)
	end

	return currentTimePoint.absoluteTime + duration * localSpeed * globalSpeed
end

function SpaceData:computeTimePoints()
	local timePointList = self.timeData.timePointList

	local timePointIndex = 1
	local timePoint = timePointList[timePointIndex]

	local velocityDataIndex = 1
	local velocityData = self:getVelocityData(velocityDataIndex)

	local time = 0
	local currentTime = timePoint.absoluteTime
	while timePoint do
		time = time + (timePoint.absoluteTime - currentTime) * velocityData.currentSpeed
		currentTime = timePoint.absoluteTime

		local nextVelocityData = self:getVelocityData(velocityDataIndex + 1)
		if nextVelocityData and nextVelocityData.timePoint == timePoint then
			velocityData = nextVelocityData
			velocityDataIndex = velocityDataIndex + 1
		end

		timePoint.velocityData = velocityData
		timePoint.zeroClearVisualTime = time
		timePointIndex = timePointIndex + 1
		timePoint = timePointList[timePointIndex]
	end

	local zeroTime = self.timeData.zeroTimePoint.zeroClearVisualTime
	for _, t in ipairs(timePointList) do
		t.zeroClearVisualTime = t.zeroClearVisualTime - zeroTime
	end
end

function SpaceData:addVelocityData(velocityData) table.insert(self.velocityDatas, velocityData) end
function SpaceData:removeLastVelocityData() return table.remove(self.velocityDatas) end
function SpaceData:getVelocityData(i) return self.velocityDatas[i] end
function SpaceData:getVelocityDataCount() return #self.velocityDatas end

function SpaceData:sort()
	table.sort(self.velocityDatas, function(a, b) return a.timePoint < b.timePoint end)
end

return SpaceData
