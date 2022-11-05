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

function TimeData:getStopDataDuration(stopDataIndex, startTime, endTime, startSide, endSide)
	assert(startTime, "Missing startTime")
	assert(endTime, "Missing endTime")
	assert(startSide, "Missing startSide")
	endSide = endSide or startSide
	local sign = 1
	if startTime > endTime then
		sign = -1
		startTime, endTime = endTime, startTime
		startSide, endSide = endSide, startSide
	end

	local stopData = self:getStopData(stopDataIndex)
	local duration = stopData.tempoData:getBeatDuration() * stopData.duration * stopData.signature

	local time = stopData.time

	if
		startSide == -1 and endSide == -1 and time >= startTime and time < endTime or
		startSide == 1 and endSide == 1 and time > startTime and time <= endTime or
		startSide == -1 and endSide == 1 and time >= startTime and time <= endTime or
		startSide == 1 and endSide == -1 and time > startTime and time < endTime
	then
		return duration * sign
	end

	return 0
end

function TimeData:getAbsoluteDuration(startTime, endTime, startSide, endSide)
	local time = 0

	for i = 1, self:getTempoDataCount() do
		time = time + self:getTempoDataDuration(i, startTime, endTime)
	end
	for i = 1, self:getStopDataCount() do
		time = time + self:getStopDataDuration(i, startTime, endTime, startSide, endSide)
	end

	return time
end

local zeroMeasureTime = Fraction:new(0)
function TimeData:getAbsoluteTime(measureTime, side)
	return self:getAbsoluteDuration(zeroMeasureTime, measureTime, -1, side)
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

	local tempoDataIndex = 1
	local tempoData = self:getTempoData(tempoDataIndex)

	local timePointIndex = 1
	local timePoint = timePointList[timePointIndex]

	local time = 0
	local currentMeasureTime = timePoint.measureTime
	local targetMeasureTime
	while true do
		local nextTempoData = self:getTempoData(tempoDataIndex + 1)
		while nextTempoData and nextTempoData.time <= currentMeasureTime do
			tempoDataIndex = tempoDataIndex + 1
			tempoData = nextTempoData
			nextTempoData = self:getTempoData(tempoDataIndex + 1)
		end

		local measureIndex = currentMeasureTime:floor()

		targetMeasureTime = Fraction:new(measureIndex + 1)
		if timePoint.measureTime < targetMeasureTime then
			targetMeasureTime = timePoint.measureTime
		end

		local duration = tempoData:getBeatDuration() * self:getSignature(measureIndex)
		time = time + duration * (targetMeasureTime - currentMeasureTime)
		currentMeasureTime = targetMeasureTime

		if timePoint.measureTime == targetMeasureTime then
			timePoint.tempoData = tempoData
			timePoint.absoluteTime = time

			timePointIndex = timePointIndex + 1
			timePoint = timePointList[timePointIndex]
			if not timePoint then
				break
			end
		end
	end

	time = 0
	timePointIndex = 1
	timePoint = timePointList[timePointIndex]
	local leftMeasureTime = timePoint.measureTime
	for stopDataIndex = 1, self:getStopDataCount() do
		local currentStopData = self:getStopData(stopDataIndex)
		local nextStopData = self:getStopData(stopDataIndex + 1)

		while timePoint and (not nextStopData or timePoint.measureTime < nextStopData.time) do
			timePoint.stopDuration = time + self:getStopDataDuration(stopDataIndex, leftMeasureTime, timePoint.measureTime, -1, timePoint.side)
			timePointIndex = timePointIndex + 1
			timePoint = timePointList[timePointIndex]
		end
		time = time + self:getStopDataDuration(stopDataIndex, leftMeasureTime, currentStopData.time, -1, 1)
	end

	local zeroTimePoint = self.zeroTimePoint
	local zeroDelta = zeroTimePoint.absoluteTime + (zeroTimePoint.stopDuration or 0)
	for _, t in ipairs(timePointList) do
		t.absoluteTime = t.absoluteTime + (t.stopDuration or 0) - zeroDelta
	end
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
