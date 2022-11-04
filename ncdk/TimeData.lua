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

function TimeData:getTempoDataDuration(tempoDataIndex, startTime, endTime)
	local sign = 1
	if startTime > endTime then
		sign = -1
		startTime, endTime = endTime, startTime
	end

	local currentTempoData = self:getTempoData(tempoDataIndex)
	local nextTempoData = self:getTempoData(tempoDataIndex + 1)

	local _startTime = currentTempoData.time
	local _endTime = nextTempoData and nextTempoData.time

	if _endTime and startTime >= _endTime or tempoDataIndex > 1 and endTime <= _startTime then
		return 0
	end

	if tempoDataIndex == 1 or startTime > _startTime then
		_startTime = startTime
	end
	if not _endTime or endTime < _endTime then
		_endTime = endTime
	end

	local startIndex, endIndex = _startTime:floor(), _endTime:floor()
	_startTime, _endTime = _startTime:tonumber(), _endTime:tonumber()

	local beatDuration = currentTempoData:getBeatDuration()

	local time = 0
	for i = startIndex, endIndex do
		local left = i == startIndex and _startTime or i
		local right = i == endIndex and _endTime or i + 1

		time = time + (right - left) * beatDuration * self:getSignature(i)
	end

	return time * sign
end

function TimeData:getStopDataDuration(stopDataIndex, startTime, endTime, side)
	local sign = 1
	if startTime > endTime then
		sign = -1
		startTime, endTime = endTime, startTime
	end

	local stopData = self:getStopData(stopDataIndex)
	local duration = stopData.tempoData:getBeatDuration() * stopData.duration * stopData.signature

	if
		side == -1 and stopData.time >= startTime and stopData.time < endTime or
		side == 1 and stopData.time > startTime and stopData.time <= endTime
	then
		return duration * sign
	end

	return 0
end

local zeroMeasureTime = Fraction:new(0)
function TimeData:getAbsoluteTime(measureTime, side)
	local time = 0

	if measureTime == zeroMeasureTime then
		return time
	end
	for currentTempoDataIndex = 1, self:getTempoDataCount() do
		time = time + self:getTempoDataDuration(currentTempoDataIndex, zeroMeasureTime, measureTime)
	end
	for currentStopDataIndex = 1, self:getStopDataCount() do
		time = time + self:getStopDataDuration(currentStopDataIndex, zeroMeasureTime, measureTime, side)
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
	table.sort(self.stopDatas, function(a, b) return a.time < b.time end)
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
			if not nextStopData or targetTimePoint.measureTime < nextStopData.time then
				targetTimePoint.stopDuration = globalTime + self:getStopDataDuration(currentStopDataIndex, leftMeasureTime, targetTimePoint.measureTime, targetTimePoint.side)
				targetTimePointIndex = targetTimePointIndex + 1
				targetTimePoint = timePointList[targetTimePointIndex]
			else
				break
			end
		end
		globalTime = globalTime + self:getStopDataDuration(currentStopDataIndex, leftMeasureTime, currentStopData.time, 1)
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
	stopData.leftTimePoint = self:getTimePoint(stopData.time, -1)
	stopData.rightTimePoint = self:getTimePoint(stopData.time, 1)

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
