local Fraction = require("ncdk.Fraction")
local TimePoint = require("ncdk.TimePoint")
local SignatureTable = require("ncdk.SignatureTable")

local DynamicLayerData = {}

local mt = {__index = DynamicLayerData}

function DynamicLayerData:new()
	local layerData = {}

	layerData.signatureTable = SignatureTable:new(Fraction:new(4))
	layerData.timePoints = {}
	layerData.noteDatas = {}

	return setmetatable(layerData, mt)
end

local function addAfter(a, b)
	b.prev = a
	b.tempoData = a.tempoData
	if a.next then
		b.next = a.next
		a.next.prev = b
	end
	a.next = b
end

local function addBefore(a, b)
	a.next = b
	a.tempoData = b.tempoData
	if b.prev then
		a.tempoData = b.prev.tempoData
		a.prev = b.prev
		b.prev.next = a
	end
	b.prev = a
end

function DynamicLayerData:compute()
	table.sort(self.noteDatas, function(a, b)
		if a.timePoint == b.timePoint then
			return a.id < b.id
		end
		return a.timePoint < b.timePoint
	end)

	self:computeTimePoints()
end

function DynamicLayerData:setTimeMode(mode)
	local time
	if mode == "absolute" then
		time = 0
	elseif mode == "measure" then
		time = Fraction:new(0)
	else
		error("Wrong time mode")
	end
	self.mode = mode
	self.startTime = time
	self.endTime = time
	self.zeroTimePoint = self:getTimePoint(time, -1)
end

function DynamicLayerData:setRange(startTime, endTime)
	if startTime > self.endTime then
		self.startTime, self.endTime = self.endTime, endTime
		self:updateRange()
	end
	self.startTime, self.endTime = startTime, endTime
	self:updateRange()
end

function DynamicLayerData:getTimePoint(time, side)
	assert(self.mode, "Mode should be set")

	if type(time) == "number" then
		time = math.min(math.max(time, -2147483648), 2147483647)
	end

	local timePoints = self.timePoints
	local key = time .. "," .. side
	local timePoint = timePoints[key]
	if timePoint then
		-- local inRange = timePoint.measureTime >= self.startTime and timePoint.measureTime <= self.endTime
		-- assert(inRange, "attempt to get a time point out of range")
		return timePoint
	end

	timePoint = TimePoint:new()
	timePoint.side = side
	timePoints[key] = timePoint

	if self.mode == "absolute" then
		timePoint.absoluteTime = time
	elseif self.mode == "measure" then
		timePoint.measureTime = time
	end

	self:insertTimePoint(timePoint)

	return timePoint
end

function DynamicLayerData:printRanges()
	print("start", self.startTimePoint)
	print("end", self.endTimePoint)
	print("first", self.firstTimePoint)
	print("last", self.lastTimePoint)
end

function DynamicLayerData:insertTimePoint(timePoint)
	if not self.startTimePoint then
		self.startTimePoint = timePoint
		self.firstTimePoint = timePoint
		self.endTimePoint = timePoint
		self.lastTimePoint = timePoint
		self:updateRange()
		return
	end

	if self.startTimePoint ~= self.firstTimePoint then
		assert(timePoint > self.startTimePoint)
	end
	if self.endTimePoint ~= self.lastTimePoint then
		assert(timePoint < self.endTimePoint)
	end

	if timePoint < self.firstTimePoint then
		assert(timePoint.measureTime >= self.startTime, "attempt to get a time point out of range")
		addBefore(timePoint, self.firstTimePoint)
		self.firstTimePoint = timePoint
		self:updateRange()
		return
	end
	if timePoint > self.lastTimePoint then
		assert(timePoint.measureTime <= self.endTime, "attempt to get a time point out of range")
		addAfter(self.lastTimePoint, timePoint)
		self.lastTimePoint = timePoint
		self:updateRange()
		return
	end

	local currentTimePoint = self.startTimePoint
	while currentTimePoint <= self.endTimePoint do
		local next = currentTimePoint.next
		if not next or timePoint > currentTimePoint and timePoint < next then
			addAfter(currentTimePoint, timePoint)
			break
		end
		currentTimePoint = next
	end
	self:updateRange()
end

function DynamicLayerData:updateRange()
	local currentTimePoint = self.startTimePoint
	while currentTimePoint.measureTime > self.startTime do
		self.startTimePoint = currentTimePoint
		local prev = currentTimePoint.prev
		if not prev then break end
		currentTimePoint = prev
	end
	while currentTimePoint.measureTime <= self.startTime do
		self.startTimePoint = currentTimePoint
		local next = currentTimePoint.next
		if not next or next.measureTime >= self.startTime then break end
		currentTimePoint = next
	end

	currentTimePoint = self.endTimePoint
	while currentTimePoint.measureTime > self.endTime do
		self.endTimePoint = currentTimePoint
		local prev = currentTimePoint.prev
		if not prev or prev.measureTime <= self.endTime then break end
		currentTimePoint = prev
	end
	while currentTimePoint.measureTime <= self.endTime do
		self.endTimePoint = currentTimePoint
		local next = currentTimePoint.next
		if not next then break end
		currentTimePoint = next
	end

	self:computeTimePoints()
end

function DynamicLayerData:computeTimePoints()
	assert(self.mode, "Mode should be set")

	local isMeasure = self.mode == "measure"

	local tempoData = self.startTimePoint.tempoData
	local velocityData = self.startTimePoint.velocityData

	local timePoint = self.startTimePoint

	local time = timePoint.absoluteTime or 0
	local visualTime = timePoint.zeroClearVisualTime or 0
	local currentTime = timePoint.measureTime
	local currentAbsoluteTime = time
	while timePoint and timePoint <= self.endTimePoint do
		local isAtTimePoint = not isMeasure
		if isMeasure then
			local measureIndex = currentTime:floor()

			local targetTime = Fraction:new(measureIndex + 1)
			if timePoint.measureTime < targetTime then
				targetTime = timePoint.measureTime
			end

			local nextTempoData = timePoint.tempoData
			if nextTempoData and nextTempoData.time == currentTime and currentTime == targetTime then
				tempoData = nextTempoData
			elseif tempoData then
				local duration = tempoData:getBeatDuration() * self:getSignature(measureIndex)
				time = time + duration * (targetTime - currentTime)
			end

			local stopData = timePoint.stopData
			if stopData and stopData.time == currentTime and currentTime == targetTime then
				time = time + stopData:getDuration() * tempoData:getBeatDuration()
			end

			currentTime = targetTime
			isAtTimePoint = timePoint.measureTime == targetTime
		else
			time = timePoint.absoluteTime
		end

		local currentSpeed = velocityData and velocityData.currentSpeed or 1
		visualTime = visualTime + (time - currentAbsoluteTime) * currentSpeed

		local nextVelocityData = timePoint.velocityData
		if nextVelocityData and nextVelocityData.timePoint == timePoint then
			velocityData = nextVelocityData
		end

		currentAbsoluteTime = time

		if isAtTimePoint then
			timePoint.tempoData = tempoData
			timePoint.velocityData = velocityData

			timePoint.absoluteTime = time
			timePoint.zeroClearVisualTime = visualTime

			timePoint = timePoint.next
		end
	end

	local zeroTimePoint = self.zeroTimePoint
	if not zeroTimePoint then
		return
	end

	local zeroTime = zeroTimePoint.absoluteTime
	local zeroVisualTime = zeroTimePoint.zeroClearVisualTime

	local t = self.firstTimePoint
	while t do
		t.absoluteTime = t.absoluteTime - zeroTime
		t.zeroClearVisualTime = t.zeroClearVisualTime - zeroVisualTime
		t = t.next
	end
end

function DynamicLayerData:addTempoData(tempoData)
	local a = self:getTimePoint(tempoData.time, -1)
	local b = self:getTimePoint(tempoData.time, 1)

	a.tempoData = tempoData
	b.tempoData = tempoData
	tempoData.leftTimePoint = a
	tempoData.rightTimePoint = b

	if not self.firstTempoData or tempoData.time < self.firstTempoData.time then
		self.firstTempoData = tempoData
	end
	self:computeTimePoints()
end

function DynamicLayerData:addStopData(stopData)
	local a = self:getTimePoint(stopData.time, -1)
	local b = self:getTimePoint(stopData.time, 1)

	a.stopData = stopData
	b.stopData = stopData
	stopData.leftTimePoint = a
	stopData.rightTimePoint = b
end

function DynamicLayerData:setSignatureMode(...) return self.signatureTable:setMode(...) end
function DynamicLayerData:setSignature(...) return self.signatureTable:setSignature(...) end
function DynamicLayerData:getSignature(...) return self.signatureTable:getSignature(...) end

function DynamicLayerData:addVelocityData(velocityData)
	if not self.firstVelocityData or velocityData.timePoint < self.firstVelocityData.timePoint then
		self.firstVelocityData = velocityData
	end
end

function DynamicLayerData:addNoteData(noteData)
	local noteDatas = self.noteDatas
	table.insert(noteDatas, noteData)
	noteData.id = #noteDatas

	self.noteChart:increaseInputCount(noteData.inputType, noteData.inputIndex, 1)
end

function DynamicLayerData:getNoteData(i) return self.noteDatas[i] end
function DynamicLayerData:getNoteDataCount() return #self.noteDatas end

return DynamicLayerData
