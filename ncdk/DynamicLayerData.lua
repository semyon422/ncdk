local Fraction = require("ncdk.Fraction")
local TimePoint = require("ncdk.TimePoint")
local SignatureTable = require("ncdk.SignatureTable")
local RangeTracker = require("ncdk.RangeTracker")

local DynamicLayerData = {}

local mt = {__index = DynamicLayerData}

function DynamicLayerData:new()
	local layerData = {}

	layerData.signatureTable = SignatureTable:new(Fraction:new(4))
	layerData.timePoints = {}
	layerData.noteDatas = {}

	local timePointsRange = RangeTracker:new()
	layerData.timePointsRange = timePointsRange
	function timePointsRange:getObjectTime(object) return object.measureTime end

	local tempoDatasRange = RangeTracker:new()
	layerData.tempoDatasRange = tempoDatasRange
	function tempoDatasRange:getObjectTime(object) return object.time end

	return setmetatable(layerData, mt)
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
	self.timePointsRange:setRange(time, time)
	self.tempoDatasRange:setRange(time, time)
	self.zeroTimePoint = self:getTimePoint(time, -1)
end

function DynamicLayerData:setRange(startTime, endTime)
	self.timePointsRange:setRange(startTime, endTime, function() self:computeTimePoints() end)
	self.tempoDatasRange:setRange(startTime, endTime, function() self:computeTimePoints() end)
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

	self.timePointsRange:insert(timePoint)
	self:computeTimePoints()

	return timePoint
end

function DynamicLayerData:computeTimePoints()
	assert(self.mode, "Mode should be set")

	local isMeasure = self.mode == "measure"

	local tempoData = self.tempoDatasRange.startObject
	local velocityData = nil
	-- local velocityData = self.startTimePoint.velocityData

	local timePoint = self.timePointsRange.startObject
	local endTimePoint = self.timePointsRange.endObject

	local time = timePoint.absoluteTime or 0
	local visualTime = timePoint.zeroClearVisualTime or 0
	local currentTime = timePoint.measureTime
	local currentAbsoluteTime = time
	while timePoint and timePoint <= endTimePoint do
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
			-- timePoint.tempoData = tempoData
			-- timePoint.velocityData = velocityData

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
	-- print("zeroTime", zeroTime)

	local t = self.timePointsRange.firstObject
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

	self.tempoDatasRange:insert(tempoData)
	self:computeTimePoints()
end

function DynamicLayerData:removeTempoData(tempoData)
	self.tempoDatasRange:remove(tempoData)
	tempoData.leftTimePoint.tempoData = nil
	tempoData.rightTimePoint.tempoData = nil
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
