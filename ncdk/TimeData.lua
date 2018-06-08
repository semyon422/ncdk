ncdk.TimeData = {}
local TimeData = ncdk.TimeData

ncdk.TimeData_metatable = {}
local TimeData_metatable = ncdk.TimeData_metatable
TimeData_metatable.__index = TimeData

TimeData.Modes = {
	Absolute = 0,
	Measure = 1
}

TimeData.new = function(self)
	local timeData = {}
	
	timeData.mode = TimeData.Modes.Measure
	timeData.timePoints = {}
	
	timeData.signatureTable = ncdk.SignatureTable:new(ncdk.Fraction:new(4))
	timeData.tempoDataSequence = ncdk.TempoDataSequence:new()
	timeData.stopDataSequence = ncdk.StopDataSequence:new()
	
	setmetatable(timeData, TimeData_metatable)
	
	return timeData
end

TimeData.getTempoDataDuration = function(self, tempoDataIndex, startEdgeM_Time, endEdgeM_Time)
	local currentTempoData = self:getTempoData(tempoDataIndex)
	local nextTempoData = self:getTempoData(tempoDataIndex + 1)
	
	local mainStartM_Time = currentTempoData.measureTime
	local mainEndM_Time
	if nextTempoData then
		mainEndM_Time = nextTempoData.measureTime
	end
	
	if (startEdgeM_Time and nextTempoData and (startEdgeM_Time >= mainEndM_Time)) or
	   (endEdgeM_Time and tempoDataIndex > 1 and (endEdgeM_Time <= mainStartM_Time)) then
		return 0
	end
	
	if tempoDataIndex == 1 or (startEdgeM_Time and (startEdgeM_Time > mainStartM_Time)) then
		mainStartM_Time = startEdgeM_Time
	end
	if not nextTempoData or (endEdgeM_Time and (endEdgeM_Time < mainEndM_Time)) then
		mainEndM_Time = endEdgeM_Time
	end
	
	local startM_Index = math.min(mainStartM_Time:floor(), mainEndM_Time:floor())
	local endM_Index = math.max(mainStartM_Time:floor(), mainEndM_Time:floor())
	
	local time = 0
	for _M_Index = startM_Index, endM_Index do
		local startTime = ((_M_Index == startM_Index) and mainStartM_Time:tonumber()) or _M_Index
		local endTime = ((_M_Index == endM_Index) and mainEndM_Time:tonumber()) or _M_Index + 1
		local dedicatedDuration = self:getTempoData(tempoDataIndex):getBeatDuration() * self:getSignature(_M_Index):tonumber()
		
		time = time + (endTime - startTime) * dedicatedDuration
	end
	
	return time
end

TimeData.getStopDataDuration  = function(self, stopDataIndex, startEdgeM_Time, endEdgeM_Time, side)
	local currentStopData = self:getStopData(stopDataIndex)
	
	if side == -1 and currentStopData.measureTime >= startEdgeM_Time and currentStopData.measureTime < endEdgeM_Time then
		return currentStopData.duration
	elseif side == 1 and currentStopData.measureTime > startEdgeM_Time and currentStopData.measureTime <= endEdgeM_Time then
		return currentStopData.duration
	end
	
	return 0
end

TimeData.getAbsoluteTime = function(self, measureTime, side)
	local time = 0
	local zeroMeasureTime = ncdk.Fraction:new(0)
	
	if measureTime == ncdk.Fraction:new(0) then
		return time
	end
	for currentTempoDataIndex = 1, self.tempoDataSequence:getTempoDataCount() do
		if measureTime > zeroMeasureTime then
			time = time + self:getTempoDataDuration(currentTempoDataIndex, zeroMeasureTime, measureTime)
		elseif measureTime < zeroMeasureTime then
			time = time - self:getTempoDataDuration(currentTempoDataIndex, measureTime, zeroMeasureTime)
		end
	end
	for currentStopDataIndex = 1, self.stopDataSequence:getStopDataCount() do
		if measureTime > zeroMeasureTime then
			time = time + self:getStopDataDuration(currentStopDataIndex, zeroMeasureTime, measureTime, side)
		elseif measureTime < zeroMeasureTime then
			time = time - self:getStopDataDuration(currentStopDataIndex, measureTime, zeroMeasureTime, side)
		end
	end
	
	return time
end

TimeData.setMode = function(self, mode)
	self.mode = mode
end

TimeData.getTimePoint = function(self, time, side)
	local timePoint
	local side = side or 1
	local timePointString = (time or 0) .. "," .. side
	
	if not time then
		timePoint = ncdk.TimePoint:new(self)
	
		timePoint.timeData = self
		timePoint.side = side
	elseif self.mode == self.Modes.Absolute then
		if self.timePoints[timePointString] then
			return self.timePoints[timePointString]
		end
		
		timePoint = ncdk.TimePoint:new(self)
	
		timePoint.timeData = self
		timePoint.absoluteTime = time
		timePoint.side = side
		timePoint.timePointString = timePointString
		
		self.timePoints[timePointString] = timePoint
	elseif self.mode == self.Modes.Measure then
		if self.timePoints[timePointString] then
			return self.timePoints[timePointString]
		end
		
		timePoint = ncdk.TimePoint:new(self)
	
		timePoint.timeData = self
		timePoint.measureTime = time
		timePoint.side = side
		timePoint.timePointString = timePointString
		
		self.timePoints[timePointString] = timePoint
	end
		
	return timePoint
end

TimeData.sort = function(self)
	self.tempoDataSequence:sort()
	self.stopDataSequence:sort()
end

TimeData.setSignature = function(self, ...) self.signatureTable:setSignature(...) end
TimeData.getSignature = function(self, ...) return self.signatureTable:getSignature(...) end
TimeData.setSignatureTable = function(self, ...) self.signatureTable = ... end
TimeData.addTempoData = function(self, ...) self.tempoDataSequence:addTempoData(...) end
TimeData.getTempoData = function(self, ...) return self.tempoDataSequence:getTempoData(...) end
TimeData.addStopData = function(self, ...) self.stopDataSequence:addStopData(...) end
TimeData.getStopData = function(self, ...) return self.stopDataSequence:getStopData(...) end
