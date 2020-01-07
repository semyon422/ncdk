local Fraction = require("ncdk.Fraction")
local TimePoint = require("ncdk.TimePoint")
local SignatureTable = require("ncdk.SignatureTable")
local TempoDataSequence = require("ncdk.TempoDataSequence")
local StopDataSequence = require("ncdk.StopDataSequence")

local TimeData = {}

local TimeData_metatable = {}
TimeData_metatable.__index = TimeData

TimeData.new = function(self)
	local timeData = {}
	
	timeData.timePoints = {}
	
	timeData.signatureTable = SignatureTable:new(Fraction:new(4))
	timeData.tempoDataSequence = TempoDataSequence:new()
	timeData.stopDataSequence = StopDataSequence:new()
	
	timeData.signatureTable.timeData = timeData
	timeData.tempoDataSequence.timeData = timeData
	timeData.stopDataSequence.timeData = timeData
	
	setmetatable(timeData, TimeData_metatable)
	
	return timeData
end

TimeData.getTempoDataDuration = function(self, tempoDataIndex, startEdgeM_Time, endEdgeM_Time)
	local currentTempoData = self:getTempoData(tempoDataIndex)
	local nextTempoData = self:getTempoData(tempoDataIndex + 1)
	
	local mainStartM_Time = currentTempoData.time
	local mainEndM_Time
	if nextTempoData then
		mainEndM_Time = nextTempoData.time
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
	
	local startM_Index = math.min(mainStartM_Time:floor():tonumber(), mainEndM_Time:floor():tonumber())
	local endM_Index = math.max(mainStartM_Time:floor():tonumber(), mainEndM_Time:floor():tonumber())
	
	local time = 0
	for _M_Index = startM_Index, endM_Index do
		local startTime = ((_M_Index == startM_Index) and mainStartM_Time:tonumber()) or _M_Index
		local endTime = ((_M_Index == endM_Index) and mainEndM_Time:tonumber()) or _M_Index + 1
		local dedicatedDuration = self:getTempoData(tempoDataIndex):getBeatDuration() * self:getSignature(_M_Index):tonumber()
		
		time = time + (endTime - startTime) * dedicatedDuration
	end
	
	return time
end

TimeData.getStopDataDuration = function(self, stopDataIndex, startEdgeM_Time, endEdgeM_Time, side)
	local currentStopData = self:getStopData(stopDataIndex)
	currentStopData.duration
		= currentStopData.measureDuration:tonumber()
		* currentStopData.tempoData:getBeatDuration()
		* currentStopData.signature:tonumber()
	
	if side == -1 and currentStopData.measureTime >= startEdgeM_Time and currentStopData.measureTime < endEdgeM_Time then
		return currentStopData.duration
	elseif side == 1 and currentStopData.measureTime > startEdgeM_Time and currentStopData.measureTime <= endEdgeM_Time then
		return currentStopData.duration
	end
	
	return 0
end

TimeData.getAbsoluteTime = function(self, measureTime, side)
	local time = 0
	local zeroMeasureTime = Fraction:new(0)
	
	if measureTime == Fraction:new(0) then
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
	if mode ~= "measure" and mode ~= "absolute" then
		error("Wrong time mode")
	end
	self.mode = mode
	
	self:createZeroTimePoint()
end

TimeData.getTimePoint = function(self, time, side)
	local timePoint
	local fixedTime
	if type(time) == "number" then
		fixedTime = math.min(math.max(time, -2147483648), 2147483647)
	elseif type(time) == "table" then
		fixedTime = time
	elseif not time then
		side = -1
	end
	local timePointString = (fixedTime or 0) .. "," .. side
	
	if not time then
		timePoint = TimePoint:new(self)
		
		timePoint.timeData = self
		timePoint.side = side
	elseif self.mode == "absolute" then
		if self.timePoints[timePointString] then
			return self.timePoints[timePointString]
		end
		
		timePoint = TimePoint:new(self)
	
		timePoint.timeData = self
		timePoint.absoluteTime = fixedTime
		timePoint.side = side
		timePoint.timePointString = timePointString
		
		self.timePoints[timePointString] = timePoint
	elseif self.mode == "measure" then
		if self.timePoints[timePointString] then
			return self.timePoints[timePointString]
		end
		
		timePoint = TimePoint:new(self)
	
		timePoint.timeData = self
		timePoint.measureTime = fixedTime
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

TimeData.createTimePointList = function(self)
	local timePointList = {}
	for _, timePoint in pairs(self.timePoints) do
		timePointList[#timePointList + 1] = timePoint
	end
	table.sort(timePointList)
	local firstTimePoint = timePointList[1]
	local lastTimePoint = timePointList[#timePointList]
	for i = 1, #timePointList do
		timePointList[i].firstTimePoint = firstTimePoint
		timePointList[i].lastTimePoint = lastTimePoint
	end
	self.timePointList = timePointList
end

TimeData.computeTimePoints = function(self)
	self:createTimePointList()
	
	if self.mode == "absolute" then
		return self.timePointList
	end
	
	local timePointList = self.timePointList
	local zeroTimePoint = self:getZeroTimePoint()
	
	local lastMeasureTime = timePointList[#timePointList].measureTime
	
	local currentTempoDataIndex = 1
	local currentTempoData = self:getTempoData(currentTempoDataIndex)
	local globalTime = 0
	
	local targetTimePointIndex = 1
	local targetTimePoint = timePointList[targetTimePointIndex]
	
	local currentMeasureTime = timePointList[1].measureTime
	local targetMeasureTime
	while true do
		local nextTempoDataIndex = currentTempoDataIndex + 1
		local nextTempoData = self:getTempoData(nextTempoDataIndex)
		while nextTempoData and nextTempoData.time <= currentMeasureTime do
			currentTempoDataIndex = nextTempoDataIndex
			currentTempoData = nextTempoData
			nextTempoDataIndex = currentTempoDataIndex + 1
			nextTempoData = self:getTempoData(nextTempoDataIndex)
		end
		
		targetMeasureTime = currentMeasureTime:floor() + 1
		if targetTimePoint and targetTimePoint.measureTime >= currentMeasureTime and targetTimePoint.measureTime < targetMeasureTime then
			targetMeasureTime = targetTimePoint.measureTime
		end
		if nextTempoData and nextTempoData.time >= currentMeasureTime and nextTempoData.time < targetMeasureTime then
			targetMeasureTime = targetMeasureTime
		end
		
		if targetMeasureTime > lastMeasureTime then
			break
		end
		
		local dedicatedDuration = currentTempoData:getBeatDuration() * self:getSignature(currentMeasureTime:floor():tonumber())
		globalTime = globalTime + dedicatedDuration * (targetMeasureTime - currentMeasureTime)
		
		if targetTimePoint and targetTimePoint.measureTime == targetMeasureTime then
			targetTimePoint.tempoData = currentTempoData
			targetTimePoint.absoluteTime = globalTime
			
			targetTimePointIndex = targetTimePointIndex + 1
			targetTimePoint = timePointList[targetTimePointIndex]
		end
		
		currentMeasureTime = targetMeasureTime
	end
	
	local globalTime = 0
	local targetTimePointIndex = 1
	local targetTimePoint = timePointList[targetTimePointIndex]
	local leftMeasureTime = timePointList[1].measureTime
	for currentStopDataIndex = 1, self.stopDataSequence:getStopDataCount() do
		local currentStopData = self:getStopData(currentStopDataIndex)
		local nextStopData = self:getStopData(currentStopDataIndex + 1)
		
		while targetTimePointIndex <= #timePointList do
			if not nextStopData or targetTimePoint.measureTime < nextStopData.measureTime then
				targetTimePoint.stopDuration = globalTime + self:getStopDataDuration(currentStopDataIndex, leftMeasureTime, targetTimePoint.measureTime, targetTimePoint.side)
				targetTimePointIndex = targetTimePointIndex + 1
				targetTimePoint = timePointList[targetTimePointIndex]
			else
				break
			end
		end
		globalTime = globalTime + self:getStopDataDuration(currentStopDataIndex, leftMeasureTime, currentStopData.measureTime, 1)
	end
	
	local baseZeroTime = zeroTimePoint.absoluteTime
	local baseZeroStopDuration = zeroTimePoint.stopDuration or 0
	for _, timePoint in ipairs(timePointList) do
		timePoint.absoluteTime
			= timePoint.absoluteTime
			+ (timePoint.stopDuration or 0)
			- baseZeroTime
			- baseZeroStopDuration
	end
	
	return timePointList
end

TimeData.createZeroTimePoint = function(self)
	local time
	if self.mode == "absolute" then
		time = 0
	elseif self.mode == "measure" then
		time = Fraction:new(0)
	end
	
	self.zeroTimePoint = self:getTimePoint(time, -1)
end

TimeData.getZeroTimePoint = function(self)
	return self.zeroTimePoint
end

TimeData.addTempoData = function(self, ...)
	for _, tempoData in ipairs({...}) do
		tempoData.leftTimePoint = self:getTimePoint(tempoData.time, -1)
		tempoData.rightTimePoint = self:getTimePoint(tempoData.time, 1)
	end
	
	return self.tempoDataSequence:addTempoData(...)
end

TimeData.addStopData = function(self, ...)
	for _, stopData in ipairs({...}) do
		stopData.leftTimePoint = self:getTimePoint(stopData.measureTime, -1)
		stopData.rightTimePoint = self:getTimePoint(stopData.measureTime, 1)
	end
	
	return self.stopDataSequence:addStopData(...)
end

TimeData.setSignatureMode = function(self, ...) return self.signatureTable:setMode(...) end
TimeData.setSignature = function(self, ...) return self.signatureTable:setSignature(...) end
TimeData.getSignature = function(self, ...) return self.signatureTable:getSignature(...) end
TimeData.setSignatureTable = function(self, ...) self.signatureTable = ... end
TimeData.getTempoData = function(self, ...) return self.tempoDataSequence:getTempoData(...) end
TimeData.getTempoDataCount = function(self) return self.tempoDataSequence:getTempoDataCount() end
TimeData.getStopData = function(self, ...) return self.stopDataSequence:getStopData(...) end
TimeData.getStopDataCount = function(self) return self.stopDataSequence:getStopDataCount() end

return TimeData
