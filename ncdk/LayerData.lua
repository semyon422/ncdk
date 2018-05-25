ncdk.LayerData = {}
local LayerData = ncdk.LayerData

ncdk.LayerData_metatable = {}
local LayerData_metatable = ncdk.LayerData_metatable
LayerData_metatable.__index = LayerData

LayerData.new = function(self)
	local layerData = {}
	
	layerData.timeData = ncdk.TimeData:new()
	layerData.spaceData = ncdk.SpaceData:new()
	layerData.noteDataSequence = ncdk.NoteDataSequence:new()
	
	layerData.timeData.layerData = layerData
	layerData.spaceData.layerData = layerData
	layerData.noteDataSequence.layerData = layerData
	
	setmetatable(layerData, LayerData_metatable)
	
	return layerData
end

LayerData.compute = function(self)
	self:updateZeroTimePoint()
	self:computeTimePoints()
	self:computeNoteData()
end

LayerData.computeTimePoints = function(self)
	local zeroTimePoint = self:getZeroTimePoint()
	
	self.positiveTimePoints = {}
	self.negativeTimePoints = {}
	for _, timePoint in pairs(self.timeData.timePoints) do
		if timePoint >= zeroTimePoint then
			table.insert(self.positiveTimePoints, timePoint)
		else
			table.insert(self.negativeTimePoints, timePoint)
		end
	end
	table.sort(self.positiveTimePoints, function(a, b) return a < b end)
	table.sort(self.negativeTimePoints, function(a, b) return a > b end)
	
	local globalTime = 0
	local targetTimePointIndex = 1
	local targetTimePoint = self.positiveTimePoints[targetTimePointIndex]
	local leftTargetTimePoint = zeroTimePoint
	local rightTargetTimePoint = zeroTimePoint
	for currentVelocityDataIndex = zeroTimePoint.velocityDataIndex, self.spaceData:getVelocityDataCount() do
		local currentVelocityData = self.spaceData:getVelocityData(currentVelocityDataIndex)
		local nextVelocityData = self.spaceData:getVelocityData(currentVelocityDataIndex + 1)
		
		if currentVelocityData.timePoint >= zeroTimePoint then
			globalTime = globalTime + self.spaceData:getVelocityDataVisualDuration(
				currentVelocityDataIndex == 1 and 1 or currentVelocityDataIndex - 1,
				leftTargetTimePoint or zeroTimePoint,
				currentVelocityData.timePoint
			)
			leftTargetTimePoint = currentVelocityData.timePoint
			rightTargetTimePoint = nextVelocityData and nextVelocityData.timePoint
		end
		
		while targetTimePointIndex <= #self.positiveTimePoints do
			if
				not nextVelocityData or
				nextVelocityData and
				(targetTimePoint < rightTargetTimePoint or 
				targetTimePoint <= leftTargetTimePoint)
			then
				targetTimePoint.velocityData = currentVelocityData
				
				local targetDeltaTime = self.spaceData:getVelocityDataVisualDuration(currentVelocityDataIndex, leftTargetTimePoint, targetTimePoint)
				targetTimePoint.zeroClearVisualTime = globalTime + targetDeltaTime
				targetTimePointIndex = targetTimePointIndex + 1
				targetTimePoint = self.positiveTimePoints[targetTimePointIndex]
			else
				break
			end
		end
	end
	
	local globalTime = 0
	local targetTimePointIndex = 1
	local targetTimePoint = self.negativeTimePoints[targetTimePointIndex]
	local leftTargetTimePoint = zeroTimePoint
	local rightTargetTimePoint = zeroTimePoint
	for currentVelocityDataIndex = zeroTimePoint.velocityDataIndex, 1, -1 do
		local currentVelocityData = self.spaceData:getVelocityData(currentVelocityDataIndex)
		local nextVelocityData = self.spaceData:getVelocityData(currentVelocityDataIndex - 1)
		
		if currentVelocityData.timePoint < zeroTimePoint then
			globalTime = globalTime - self.spaceData:getVelocityDataVisualDuration(
				currentVelocityDataIndex,
				rightTargetTimePoint,
				zeroTimePoint
			)
			rightTargetTimePoint = leftTargetTimePoint
			leftTargetTimePoint = currentVelocityData.timePoint
		end
		
		while targetTimePointIndex <= #self.negativeTimePoints do
			if
				not nextVelocityData or
				nextVelocityData and
				(targetTimePoint >= leftTargetTimePoint)
			then
				targetTimePoint.velocityData = currentVelocityData
				print(targetTimePoint:getAbsoluteTime())
				local targetDeltaTime = self.spaceData:getVelocityDataVisualDuration(currentVelocityDataIndex, targetTimePoint, rightTargetTimePoint)
				targetTimePoint.zeroClearVisualTime = globalTime - targetDeltaTime
				targetTimePointIndex = targetTimePointIndex + 1
				targetTimePoint = self.negativeTimePoints[targetTimePointIndex]
			else
				break
			end
		end
	end
end

LayerData.computeNoteData = function(self)
	self.noteDataSequence:sort()
	for noteDataIndex = 1, self.noteDataSequence:getNoteDataCount() do
		local noteData = self.noteDataSequence:getNoteData(noteDataIndex)
		
		noteData.zeroClearVisualTime = noteData.timePoint.zeroClearVisualTime
		noteData.currentVisualTime = noteData.zeroClearVisualTime
	end
end

LayerData.setSignature = function(self, ...) self.timeData:setSignature(...) end
LayerData.getSignature = function(self, ...) return self.timeData:getSignature(...) end
LayerData.setSignatureTable = function(self, ...) self.timeData:setSignatureTable(...) end
LayerData.addTempoData = function(self, ...) self.timeData:addTempoData(...) end
LayerData.getTempoData = function(self, ...) return self.timeData:getTempoData(...) end
LayerData.addStopData = function(self, ...) self.timeData:addStopData(...) end
LayerData.getStopData = function(self, ...) return self.timeData:getStopData(...) end
LayerData.getTimePoint = function(self, ...) return self.timeData:getTimePoint(...) end

LayerData.addVelocityData = function(self, ...) self.spaceData:addVelocityData(...) end
LayerData.getVelocityDataByTimePoint = function(self, ...) return self.spaceData:getVelocityDataByTimePoint(...) end
LayerData.getVisualMeasureTime = function(self, ...) return self.spaceData:getVisualMeasureTime(...) end
LayerData.getVisualTime = function(self, ...) return self.spaceData:getVisualTime(...) end
LayerData.computeVisualTime = function(self, ...) return self.spaceData:computeVisualTime(...) end
LayerData.updateZeroTimePoint = function(self) return self.spaceData:updateZeroTimePoint() end
LayerData.getZeroTimePoint = function(self) return self.spaceData:getZeroTimePoint() end

LayerData.getColumnCount = function(self) return self.noteDataSequence:getColumnCount() end
LayerData.addNoteData = function(self, ...) return self.noteDataSequence:addNoteData(...) end
LayerData.getNoteData = function(self, ...) return self.noteDataSequence:getNoteData(...) end
LayerData.getNoteDataCount = function(self) return self.noteDataSequence:getNoteDataCount() end
