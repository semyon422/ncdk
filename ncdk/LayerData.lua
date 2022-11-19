local Fraction = require("ncdk.Fraction")
local TimePoint = require("ncdk.TimePoint")
local SignatureTable = require("ncdk.SignatureTable")

local LayerData = {}

local mt = {__index = LayerData}

function LayerData:new()
	local layerData = {}

	layerData.signatureTable = SignatureTable:new(Fraction:new(4))
	layerData.timePoints = {}

	layerData.tempoDatas = {}
	layerData.stopDatas = {}
	layerData.velocityDatas = {}
	layerData.expandDatas = {}
	layerData.noteDatas = {}

	return setmetatable(layerData, mt)
end

function LayerData:compute()
	table.sort(self.tempoDatas, function(a, b) return a.time < b.time end)
	table.sort(self.stopDatas, function(a, b) return a.time < b.time end)
	table.sort(self.velocityDatas, function(a, b) return a.timePoint < b.timePoint end)
	table.sort(self.noteDatas, function(a, b)
		if a.timePoint == b.timePoint then
			return a.id < b.id
		end
		return a.timePoint < b.timePoint
	end)

	self:computeTimePoints()
end

function LayerData:setTimeMode(mode)
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

function LayerData:getTempoDataDuration(tempoDataIndex, startTime, endTime)
	local sign = 1
	if startTime > endTime then
		sign = -1
		startTime, endTime = endTime, startTime
	end

	local tempoData = self:getTempoData(tempoDataIndex)
	local nextTempoData = self:getTempoData(tempoDataIndex + 1)

	local _startTime = tempoData.time
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

	local beatDuration = tempoData:getBeatDuration()

	local time = 0
	for i = startIndex, endIndex do
		local left = i == startIndex and _startTime or i
		local right = i == endIndex and _endTime or i + 1

		time = time + (right - left) * beatDuration * self:getSignature(i)
	end

	return time * sign
end

function LayerData:getStopDataDuration(stopDataIndex, startTime, endTime, startSide, endSide)
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
	local time = stopData.time

	if
		startSide == -1 and endSide == -1 and time >= startTime and time < endTime or
		startSide == 1 and endSide == 1 and time > startTime and time <= endTime or
		startSide == -1 and endSide == 1 and time >= startTime and time <= endTime or
		startSide == 1 and endSide == -1 and time > startTime and time < endTime
	then
		return stopData:getDuration() * stopData.tempoData:getBeatDuration() * sign
	end

	return 0
end

function LayerData:getAbsoluteDuration(startTime, endTime, startSide, endSide)
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
function LayerData:getAbsoluteTime(measureTime, side)
	return self:getAbsoluteDuration(zeroMeasureTime, measureTime, -1, side)
end

function LayerData:getVelocityDataVisualDuration(velocityDataIndex, startTime, endTime)
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

	if velocityDataIndex == 1 or startTime > _startTime then
		_startTime = startTime
	end
	if not _endTime or endTime < _endTime then
		_endTime = endTime
	end

	return (_endTime - _startTime) * velocityData.currentSpeed * sign
end

function LayerData:getVisualTime(targetTimePoint, currentTimePoint, clear)
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

function LayerData:getTimePoint(time, side, visualSide)
	assert(self.mode, "Mode should be set")

	if type(time) == "number" then
		time = math.min(math.max(time, -2147483648), 2147483647)
	end

	side = side or -1
	visualSide = visualSide or -1
	local timePoints = self.timePoints
	local key = time .. "," .. side .. "," .. visualSide
	local timePoint = timePoints[key]
	if timePoint then
		return timePoint
	end

	timePoint = TimePoint:new()
	timePoint.side = side
	timePoint.visualSide = visualSide
	timePoints[key] = timePoint

	if self.mode == "absolute" then
		timePoint.absoluteTime = time
	elseif self.mode == "measure" then
		timePoint.measureTime = time
	end

	return timePoint
end

function LayerData:createTimePointList()
	local timePointList = {}
	for _, timePoint in pairs(self.timePoints) do
		timePointList[#timePointList + 1] = timePoint
	end
	table.sort(timePointList)
	self.timePointList = timePointList
end

function LayerData:computeTimePoints()
	assert(self.mode, "Mode should be set")

	self:createTimePointList()

	local isMeasure = self.mode == "measure"
	local timePointList = self.timePointList

	local tempoData = self:getTempoData(1)
	local velocityData = self:getVelocityData(1)

	local timePointIndex = 1
	local timePoint = timePointList[timePointIndex]

	local time = 0
	local visualTime = 0
	local currentTime = timePoint.measureTime
	local currentAbsoluteTime = 0
	while timePoint do
		local isAtTimePoint = not isMeasure
		if isMeasure then
			local measureIndex = currentTime:floor()

			local targetTime = Fraction:new(measureIndex + 1)
			if timePoint.measureTime < targetTime then
				targetTime = timePoint.measureTime
			end

			if tempoData then
				local duration = tempoData:getBeatDuration() * self:getSignature(measureIndex)
				time = time + duration * (targetTime - currentTime)
			end

			local nextTempoData = timePoint._tempoData
			if nextTempoData then
				tempoData = nextTempoData
			end

			local stopData = timePoint._stopData
			if stopData then
				time = time + stopData:getDuration() * tempoData:getBeatDuration()
			end

			currentTime = targetTime
			isAtTimePoint = timePoint.measureTime == targetTime
		else
			time = timePoint.absoluteTime
		end

		local currentSpeed = velocityData and velocityData.currentSpeed or 1
		visualTime = visualTime + (time - currentAbsoluteTime) * currentSpeed
		currentAbsoluteTime = time

		local nextVelocityData = timePoint._velocityData
		if nextVelocityData then
			velocityData = nextVelocityData
		end

		local expandData = timePoint._expandData
		if expandData then
			local duration = expandData.duration
			if isMeasure then
				duration = expandData.duration:tonumber() * tempoData:getBeatDuration() * currentSpeed
			end
			visualTime = visualTime + duration
		end

		if isAtTimePoint then
			timePoint.tempoData = tempoData
			timePoint.velocityData = velocityData

			timePoint.absoluteTime = timePoint.absoluteTime or time
			timePoint.zeroClearVisualTime = visualTime

			timePointIndex = timePointIndex + 1
			timePoint = timePointList[timePointIndex]
		end
	end

	local zeroTime = self.zeroTimePoint.absoluteTime
	local zeroVisualTime = self.zeroTimePoint.zeroClearVisualTime
	for _, t in ipairs(timePointList) do
		t.absoluteTime = t.absoluteTime - zeroTime
		t.zeroClearVisualTime = t.zeroClearVisualTime - zeroVisualTime
	end
end

function LayerData:addTempoData(tempoData)
	local a = self:getTimePoint(tempoData.time, -1)
	local b = self:getTimePoint(tempoData.time, 1)

	b._tempoData = tempoData
	tempoData.leftTimePoint = a
	tempoData.rightTimePoint = b

	return table.insert(self.tempoDatas, tempoData)
end

function LayerData:addStopData(stopData)
	local a = self:getTimePoint(stopData.time, -1)
	local b = self:getTimePoint(stopData.time, 1)

	b._stopData = stopData
	stopData.leftTimePoint = a
	stopData.rightTimePoint = b

	return table.insert(self.stopDatas, stopData)
end

function LayerData:addExpandData(expandData)
	local timePoint = expandData.timePoint
	local time = timePoint.measureTime or timePoint.absoluteTime
	timePoint = self:getTimePoint(time, timePoint.side, -1)
	table.insert(self.expandDatas, expandData)
end

function LayerData:setSignatureMode(...) return self.signatureTable:setMode(...) end
function LayerData:setSignature(...) return self.signatureTable:setSignature(...) end
function LayerData:getSignature(...) return self.signatureTable:getSignature(...) end

function LayerData:getTempoData(i) return self.tempoDatas[i] end
function LayerData:getTempoDataCount() return #self.tempoDatas end

function LayerData:getStopData(i) return self.stopDatas[i] end
function LayerData:getStopDataCount() return #self.stopDatas end

function LayerData:addVelocityData(velocityData)
	local timePoint = velocityData.timePoint
	local time = timePoint.measureTime or timePoint.absoluteTime
	timePoint = self:getTimePoint(time, timePoint.side, -1)
	table.insert(self.velocityDatas, velocityData)
end

function LayerData:removeLastVelocityData() return table.remove(self.velocityDatas) end
function LayerData:getVelocityData(i) return self.velocityDatas[i] end
function LayerData:getVelocityDataCount() return #self.velocityDatas end

function LayerData:addNoteData(noteData)
	local noteDatas = self.noteDatas
	table.insert(noteDatas, noteData)
	noteData.id = #noteDatas

	self.noteChart:increaseInputCount(noteData.inputType, noteData.inputIndex, 1)
end

function LayerData:getNoteData(i) return self.noteDatas[i] end
function LayerData:getNoteDataCount() return #self.noteDatas end

return LayerData
