ncdk.SpaceData = {}
local SpaceData = ncdk.SpaceData

ncdk.SpaceData_metatable = {}
local SpaceData_metatable = ncdk.SpaceData_metatable
SpaceData_metatable.__index = SpaceData

SpaceData.new = function(self)
	local spaceData = {}
	
	spaceData.velocityDataSequence = ncdk.VelocityDataSequence:new()
	spaceData.velocityDataSequence.spaceData = spaceData
	
	setmetatable(spaceData, SpaceData_metatable)
	
	return spaceData
end

SpaceData.getVelocityDataVisualMeasureDuration = function(self, velocityDataIndex, startEdgeTimePoint, endEdgeTimePoint)
	local currentVelocityData = self.velocityDataSequence:getVelocityData(velocityDataIndex)
	local nextVelocityData = self.velocityDataSequence:getVelocityData(velocityDataIndex + 1)
	
	local mainStartTimePoint = currentVelocityData.timePoint
	local mainEndTimePoint
	if nextVelocityData then
		mainEndTimePoint = nextVelocityData.timePoint
	end
	
	if (startEdgeTimePoint and nextVelocityData and (startEdgeTimePoint >= mainEndTimePoint)) or
	   (endEdgeTimePoint and velocityDataIndex > 1 and (endEdgeTimePoint <= mainStartTimePoint)) then
		return ncdk.Fraction:new(0)
	end
	
	if velocityDataIndex == 1 or (startEdgeTimePoint and (startEdgeTimePoint > mainStartTimePoint)) then
		mainStartTimePoint = startEdgeTimePoint
	end
	if not nextVelocityData or (endEdgeTimePoint and (endEdgeTimePoint < mainEndTimePoint)) then
		mainEndTimePoint = endEdgeTimePoint
	end
	
	local visualMeasureDuration = (mainEndTimePoint.measureTime - mainStartTimePoint.measureTime) * currentVelocityData.currentSpeed
	if visualMeasureDuration ~= ncdk.Fraction:new(0) or not currentVelocityData.visualEndTimePoint then
		return visualMeasureDuration
	else
		return currentVelocityData.visualEndTimePoint.measureTime - currentVelocityData.timePoint.measureTime
	end
end

SpaceData.getVisualMeasureTime = function(self, targetMeasureTimePoint, currentMeasureTimePoint)
	local deltaTime = ncdk.Fraction:new(0)
	
	if targetMeasureTimePoint == currentMeasureTimePoint then
		return currentMeasureTimePoint.measureTime
	end
	
	local targetVelocityData = targetMeasureTimePoint.velocityData or self:getVelocityDataByTimePoint(targetMeasureTimePoint)
	local currentVelocityData = currentMeasureTimePoint.velocityData or self:getVelocityDataByTimePoint(currentMeasureTimePoint)
	
	local localSpeed = targetVelocityData.localSpeed
	local globalSpeed = currentVelocityData.globalSpeed
	
	for currentVelocityDataIndex = 1, self.velocityDataSequence:getVelocityDataCount() do
		if targetMeasureTimePoint > currentMeasureTimePoint then
			deltaTime = deltaTime + self:getVelocityDataVisualMeasureDuration(currentVelocityDataIndex, currentMeasureTimePoint, targetMeasureTimePoint)
		elseif targetMeasureTimePoint < currentMeasureTimePoint then
			deltaTime = deltaTime - self:getVelocityDataVisualMeasureDuration(currentVelocityDataIndex, targetMeasureTimePoint, currentMeasureTimePoint)
		end
	end
	
	return currentMeasureTimePoint.measureTime + deltaTime * localSpeed * globalSpeed
end

SpaceData.getVelocityDataVisualDuration = function(self, velocityDataIndex, startEdgeTimePoint, endEdgeTimePoint)
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
	
	local visualDuration = (mainEndTimePoint:getAbsoluteTime() - mainStartTimePoint:getAbsoluteTime()) * currentVelocityData.currentSpeed:tonumber()
	if visualDuration ~= 0 or not currentVelocityData.visualEndTimePoint then
		return visualDuration
	else
		return currentVelocityData.visualEndTimePoint:getAbsoluteTime() - currentVelocityData.timePoint:getAbsoluteTime()
	end
end

SpaceData.getVisualTime = function(self, targetTimePoint, currentTimePoint, clear)
	local deltaTime = 0
	
	if targetTimePoint == currentTimePoint then
		return currentTimePoint:getAbsoluteTime()
	end
	
	local globalSpeed, localSpeed = 1, 1
	if not clear then
		local currentVelocityData = currentTimePoint.velocityData
		local targetVelocityData = targetTimePoint.velocityData
		
		globalSpeed = currentVelocityData.globalSpeed:tonumber()
		localSpeed = targetVelocityData.localSpeed:tonumber()
	end
	
	for currentVelocityDataIndex = 1, self.velocityDataSequence:getVelocityDataCount() do
		if targetTimePoint > currentTimePoint then
			deltaTime = deltaTime + self:getVelocityDataVisualDuration(currentVelocityDataIndex, currentTimePoint, targetTimePoint)
		elseif targetTimePoint < currentTimePoint then
			deltaTime = deltaTime - self:getVelocityDataVisualDuration(currentVelocityDataIndex, targetTimePoint, currentTimePoint)
		end
	end
	
	return currentTimePoint:getAbsoluteTime() + deltaTime * localSpeed * globalSpeed
end

SpaceData.computeVisualTime = function(self, currentTimePoint)
	local currentClearVisualTime = self:getVisualTime(currentTimePoint, self.zeroTimePoint, true)
	local globalSpeed = currentTimePoint.velocityData.globalSpeed:tonumber()
	
	for noteDataIndex = 1, self.layerData.noteDataSequence:getNoteDataCount() do
		local noteData = self.layerData.noteDataSequence:getNoteData(noteDataIndex)
		
		local targetVelocityData = noteData.timePoint.velocityData
		local localSpeed = targetVelocityData.localSpeed:tonumber()
		
		noteData.currentClearVisualDeltaTime = noteData.zeroClearVisualTime - currentClearVisualTime
		
		noteData.currentClearVisualTime = noteData.currentClearVisualDeltaTime + currentTimePoint:getAbsoluteTime()
		noteData.currentVisualTime = noteData.currentClearVisualDeltaTime * globalSpeed * localSpeed + currentTimePoint:getAbsoluteTime()
	end
end

SpaceData.updateZeroTimePoint = function(self)
	self.zeroTimePoint = self.layerData:getTimePoint(ncdk.Fraction:new(0, 1), 1)
	self.zeroTimePoint.velocityData = self:getVelocityDataByTimePoint(self.zeroTimePoint)
end

SpaceData.getZeroTimePoint = function(self)
	return self.zeroTimePoint
end

SpaceData.addVelocityData = function(self, ...) self.velocityDataSequence:addVelocityData(...) end
SpaceData.getVelocityData = function(self, ...) return self.velocityDataSequence:getVelocityData(...) end
SpaceData.getVelocityDataCount = function(self) return self.velocityDataSequence:getVelocityDataCount() end
SpaceData.getVelocityDataByTimePoint = function(self, ...) return self.velocityDataSequence:getVelocityDataByTimePoint(...) end
