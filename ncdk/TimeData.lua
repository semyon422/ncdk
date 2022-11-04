local Fraction = require("ncdk.Fraction")
local TimePoint = require("ncdk.TimePoint")
local SignatureTable = require("ncdk.SignatureTable")

local TimeData = {}

local mt = {__index = TimeData}

function TimeData:new()
	local timeData = {}

	timeData.timePoints = {}

	timeData.signatureTable = SignatureTable:new(Fraction:new(4))
	timeData.tempoDatas = {}
	timeData.stopDatas = {}

	return setmetatable(timeData, mt)
end

function TimeData:getTempoDataDuration(tempoDataIndex, startEdgeM_Time, endEdgeM_Time)
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

function TimeData:getStopDataDuration(stopDataIndex, startEdgeM_Time, endEdgeM_Time, side)
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

function TimeData:getAbsoluteTime(measureTime, side)
	local time = 0
	local zeroMeasureTime = Fraction:new(0)

	if measureTime == Fraction:new(0) then
		return time
	end
	for currentTempoDataIndex = 1, self:getTempoDataCount() do
		if measureTime > zeroMeasureTime then
			time = time + self:getTempoDataDuration(currentTempoDataIndex, zeroMeasureTime, measureTime)
		elseif measureTime < zeroMeasureTime then
			time = time - self:getTempoDataDuration(currentTempoDataIndex, measureTime, zeroMeasureTime)
		end
	end
	for currentStopDataIndex = 1, self:getStopDataCount() do
		if measureTime > zeroMeasureTime then
			time = time + self:getStopDataDuration(currentStopDataIndex, zeroMeasureTime, measureTime, side)
		elseif measureTime < zeroMeasureTime then
			time = time - self:getStopDataDuration(currentStopDataIndex, measureTime, zeroMeasureTime, side)
		end
	end

	return time
end

function TimeData:setMode(mode)
	local time
	if mode == "absolute" then
		time = 0
	elseif mode == "measure" then
		time = Fraction:new(0)
	else
		error("Wrong time mode")
	end
	self.mode = mode
	self.zeroTimePoint = self:getTimePoint(time, -1)
end

function TimeData:getTimePoint(time, side)
	assert(self.mode, "Mode should be set")

	if type(time) == "number" then
		time = math.min(math.max(time, -2147483648), 2147483647)
	end

	local timePoints = self.timePoints
	local key = time .. "," .. side
	if timePoints[key] then
		return timePoints[key]
	end

	local timePoint = TimePoint:new()
	timePoint.side = side
	timePoints[key] = timePoint

	if self.mode == "absolute" then
		timePoint.absoluteTime = time
	elseif self.mode == "measure" then
		timePoint.measureTime = time
	end

	return timePoint
end

function TimeData:sort()
	table.sort(self.tempoDatas, function(a, b) return a.time < b.time end)
	table.sort(self.stopDatas, function(a, b) return a.measureTime < b.measureTime end)
end

function TimeData:createTimePointList()
	local timePointList = {}
	for _, timePoint in pairs(self.timePoints) do
		timePointList[#timePointList + 1] = timePoint
	end
	table.sort(timePointList)
	self.timePointList = timePointList
end

function TimeData:computeTimePoints()
	assert(self.mode, "Mode should be set")

	self:createTimePointList()

	if self.mode == "absolute" then
		return self.timePointList
	end

	local timePointList = self.timePointList

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

		targetMeasureTime = Fraction:new(currentMeasureTime:floor() + 1)
		if targetTimePoint and targetTimePoint.measureTime >= currentMeasureTime and targetTimePoint.measureTime < targetMeasureTime then
			targetMeasureTime = targetTimePoint.measureTime
		end
		if nextTempoData and nextTempoData.time >= currentMeasureTime and nextTempoData.time < targetMeasureTime then
			targetMeasureTime = targetMeasureTime
		end

		if targetMeasureTime > lastMeasureTime then
			break
		end

		local dedicatedDuration = currentTempoData:getBeatDuration() * self:getSignature(currentMeasureTime:floor())
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
	for currentStopDataIndex = 1, self:getStopDataCount() do
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

	local zeroTimePoint = self.zeroTimePoint
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

function TimeData:addTempoData(tempoData)
	tempoData.leftTimePoint = self:getTimePoint(tempoData.time, -1)
	tempoData.rightTimePoint = self:getTimePoint(tempoData.time, 1)

	return table.insert(self.tempoDatas, tempoData)
end

function TimeData:addStopData(stopData)
	stopData.leftTimePoint = self:getTimePoint(stopData.measureTime, -1)
	stopData.rightTimePoint = self:getTimePoint(stopData.measureTime, 1)

	return table.insert(self.stopDatas, stopData)
end

function TimeData:setSignatureMode(...) return self.signatureTable:setMode(...) end
function TimeData:setSignature(...) return self.signatureTable:setSignature(...) end
function TimeData:getSignature(...) return self.signatureTable:getSignature(...) end

function TimeData:getTempoData(i) return self.tempoDatas[i] end
function TimeData:getTempoDataCount() return #self.tempoDatas end

function TimeData:getStopData(i) return self.stopDatas[i] end
function TimeData:getStopDataCount() return #self.stopDatas end

return TimeData
