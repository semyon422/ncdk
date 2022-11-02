local VelocityDataSequence = require("ncdk.VelocityDataSequence")

local SpaceData = {}

local mt = {__index = SpaceData}

function SpaceData:new()
	local spaceData = {}

	spaceData.velocityDataSequence = VelocityDataSequence:new()
	spaceData.velocityDataSequence.spaceData = spaceData

	return setmetatable(spaceData, mt)
end

function SpaceData:getVelocityDataVisualDuration(velocityDataIndex, startEdgeTimePoint, endEdgeTimePoint)
	local currentVelocityData = self.velocityDataSequence:getVelocityData(velocityDataIndex)
	local nextVelocityData = self.velocityDataSequence:getVelocityData(velocityDataIndex + 1)

	local mainStartTimePoint = currentVelocityData.timePoint
	local mainEndTimePoint
	if nextVelocityData then
		mainEndTimePoint = nextVelocityData.timePoint
	end

	if (startEdgeTimePoint and nextVelocityData and (startEdgeTimePoint >= mainEndTimePoint)) or
	   (endEdgeTimePoint and velocityDataIndex > 1 and (endEdgeTimePoint <= mainStartTimePoint)) then
		return 0
	end

	if velocityDataIndex == 1 or (startEdgeTimePoint and (startEdgeTimePoint > mainStartTimePoint)) then
		mainStartTimePoint = startEdgeTimePoint
	end
	if not nextVelocityData or (endEdgeTimePoint and (endEdgeTimePoint < mainEndTimePoint)) then
		mainEndTimePoint = endEdgeTimePoint
	end

	local visualDuration = (mainEndTimePoint.absoluteTime - mainStartTimePoint.absoluteTime) * currentVelocityData.currentSpeed
	if visualDuration ~= 0 or not currentVelocityData.visualEndTimePoint then
		return visualDuration
	else
		return currentVelocityData.visualEndTimePoint.absoluteTime - currentVelocityData.timePoint.absoluteTime
	end
end

function SpaceData:getVisualTime(targetTimePoint, currentTimePoint, clear)
	local deltaTime = 0

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

	for currentVelocityDataIndex = 1, self.velocityDataSequence:getVelocityDataCount() do
		if targetTimePoint > currentTimePoint then
			deltaTime = deltaTime + self:getVelocityDataVisualDuration(currentVelocityDataIndex, currentTimePoint, targetTimePoint)
		elseif targetTimePoint < currentTimePoint then
			deltaTime = deltaTime - self:getVelocityDataVisualDuration(currentVelocityDataIndex, targetTimePoint, currentTimePoint)
		end
	end

	return currentTimePoint.absoluteTime + deltaTime * localSpeed * globalSpeed
end

function SpaceData:sort()
	return self.velocityDataSequence:sort()
end

function SpaceData:computeTimePoints()
	local timePointList = self.layerData.timeData.timePointList
	local zeroTimePoint = self.layerData.timeData:getZeroTimePoint()

	local firstTimePoint = timePointList[1]

	local globalTime = 0
	local targetTimePointIndex = 1
	local targetTimePoint = timePointList[targetTimePointIndex]
	local leftTimePoint = firstTimePoint

	for currentVelocityDataIndex = 1, self:getVelocityDataCount() do
		local currentVelocityData = self:getVelocityData(currentVelocityDataIndex)
		local nextVelocityData = self:getVelocityData(currentVelocityDataIndex + 1)

		while targetTimePointIndex <= #timePointList do
			if not nextVelocityData or targetTimePoint < nextVelocityData.timePoint then
				targetTimePoint.velocityData = currentVelocityData
				targetTimePoint.zeroClearVisualTime = globalTime + self:getVelocityDataVisualDuration(currentVelocityDataIndex, leftTimePoint, targetTimePoint)
				targetTimePointIndex = targetTimePointIndex + 1
				targetTimePoint = timePointList[targetTimePointIndex]
			else
				break
			end
		end

		if nextVelocityData then
			globalTime = globalTime + self:getVelocityDataVisualDuration(
				currentVelocityDataIndex,
				leftTimePoint,
				nextVelocityData.timePoint
			)
			leftTimePoint = currentVelocityData.timePoint
		end
	end

	local baseZeroClearVisualTime = zeroTimePoint.zeroClearVisualTime
	for _, timePoint in ipairs(timePointList) do
		timePoint.zeroClearVisualTime = timePoint.zeroClearVisualTime - baseZeroClearVisualTime
	end
end

function SpaceData:addVelocityData(...) return self.velocityDataSequence:addVelocityData(...) end
function SpaceData:removeLastVelocityData(...) return self.velocityDataSequence:removeLastVelocityData(...) end
function SpaceData:getVelocityData(...) return self.velocityDataSequence:getVelocityData(...) end
function SpaceData:getVelocityDataCount() return self.velocityDataSequence:getVelocityDataCount() end
function SpaceData:getVelocityDataByTimePoint(...) return self.velocityDataSequence:getVelocityDataByTimePoint(...) end

return SpaceData
