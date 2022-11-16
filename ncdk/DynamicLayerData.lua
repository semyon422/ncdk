local Fraction = require("ncdk.Fraction")
local TimePoint = require("ncdk.TimePoint")
local TempoData = require("ncdk.TempoData")
local StopData = require("ncdk.StopData")
local VelocityData = require("ncdk.VelocityData")
local NoteData = require("ncdk.NoteData")
local SignatureTable = require("ncdk.SignatureTable")
local RangeTracker = require("ncdk.RangeTracker")

local DynamicLayerData = {}

local mt = {__index = DynamicLayerData}

function DynamicLayerData:new()
	local layerData = {}

	layerData.signatureTable = SignatureTable:new(Fraction:new(4))
	layerData.timePoints = {}
	layerData.tempoDatas = {}
	layerData.stopDatas = {}
	layerData.velocityDatas = {}
	layerData.noteDatas = {}

	local timePointsRange = RangeTracker:new()
	layerData.timePointsRange = timePointsRange
	function timePointsRange:getObjectTime(object) return object.measureTime end

	local tempoDatasRange = RangeTracker:new()
	layerData.tempoDatasRange = tempoDatasRange
	function tempoDatasRange:getObjectTime(object) return object.time end

	local stopDatasRange = RangeTracker:new()
	layerData.stopDatasRange = stopDatasRange
	function stopDatasRange:getObjectTime(object) return object.time end

	local velocityDatasRange = RangeTracker:new()
	layerData.velocityDatasRange = velocityDatasRange
	function velocityDatasRange:getObjectTime(object) return object.timePoint.measureTime end

	return setmetatable(layerData, mt)
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
	self:_setRange(time, time)
	self.zeroTimePoint = self:getTimePoint(time, -1)
end

function DynamicLayerData:_setRange(startTime, endTime)
	self.timePointsRange:setRange(startTime, endTime)
	self.tempoDatasRange:setRange(startTime, endTime)
	self.stopDatasRange:setRange(startTime, endTime)
	self.velocityDatasRange:setRange(startTime, endTime)
end

function DynamicLayerData:setRange(startTime, endTime)
	if self.endTime and startTime > self.endTime then
		self.startTime, self.endTime = self.endTime, endTime
		self:_setRange(self.startTime, self.endTime)
		self:compute()
	end
	self.startTime, self.endTime = startTime, endTime
	self:_setRange(self.startTime, self.endTime)
	self:compute()
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
	self:compute()

	return timePoint
end

function DynamicLayerData:compute()
	assert(self.mode, "Mode should be set")

	local isMeasure = self.mode == "measure"

	local tempoData = self.tempoDatasRange.startObject
	local velocityData = self.velocityDatasRange.startObject

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

function DynamicLayerData:getTempoData(time, tempo)
	local tempoDatas = self.tempoDatas
	local key = tostring(time)
	local tempoData = tempoDatas[key]
	if tempoData then
		if tempoData.tempo ~= tempo then
			tempoData.tempo = tempo
			self:compute()
		end
		return tempoData
	end

	tempoData = TempoData:new(time, tempo)
	tempoDatas[key] = tempoData

	local a = self:getTimePoint(time, -1)
	local b = self:getTimePoint(time, 1)

	a.tempoData = tempoData
	b.tempoData = tempoData
	tempoData.leftTimePoint = a
	tempoData.rightTimePoint = b

	self.tempoDatasRange:insert(tempoData)
	self:compute()

	return tempoData
end

function DynamicLayerData:removeTempoData(time)
	local tempoDatas = self.tempoDatas
	local key = tostring(time)
	local tempoData = assert(tempoDatas[key], "tempo data not found")
	tempoDatas[key] = nil

	self.tempoDatasRange:remove(tempoData)

	tempoData.leftTimePoint.tempoData = nil
	tempoData.rightTimePoint.tempoData = nil

	self:compute()
end

function DynamicLayerData:getStopData(time, duration, signature)
	signature = signature or Fraction:new(4)

	local stopDatas = self.stopDatas
	local key = tostring(time)
	local stopData = stopDatas[key]
	if stopData then
		if stopData.duration ~= duration or stopData.signature ~= signature then
			stopData.duration = duration
			stopData.signature = signature
			self:compute()
		end
		return stopData
	end

	stopData = StopData:new(time, duration, signature)
	stopDatas[key] = stopData

	local a = self:getTimePoint(time, -1)
	local b = self:getTimePoint(time, 1)

	a.stopData = stopData
	b.stopData = stopData
	stopData.leftTimePoint = a
	stopData.rightTimePoint = b

	self.stopDatasRange:insert(stopData)
	self:compute()

	return stopData
end

function DynamicLayerData:removeStopData(time)
	local stopDatas = self.stopDatas
	local key = tostring(time)
	local stopData = assert(stopDatas[key], "stop data not found")
	stopDatas[key] = nil

	self.stopDatasRange:remove(stopData)

	stopData.leftTimePoint.stopData = nil
	stopData.rightTimePoint.stopData = nil

	self:compute()
end

function DynamicLayerData:setSignatureMode(...) return self.signatureTable:setMode(...) end
function DynamicLayerData:setSignature(...) return self.signatureTable:setSignature(...) end
function DynamicLayerData:getSignature(...) return self.signatureTable:getSignature(...) end

function DynamicLayerData:getVelocityData(timePoint, currentSpeed, localSpeed, globalSpeed)
	local velocityDatas = self.velocityDatas
	local key = timePoint
	local velocityData = velocityDatas[key]
	if velocityData then
		if velocityData.currentSpeed ~= currentSpeed then
			velocityData.currentSpeed = currentSpeed
			self:compute()
		end
		return velocityData
	end

	velocityData = VelocityData:new(timePoint, currentSpeed, localSpeed, globalSpeed)
	velocityDatas[key] = velocityData

	self.velocityDatasRange:insert(velocityData)
	self:compute()

	return velocityData
end

function DynamicLayerData:removeVelocityData(timePoint)
	local velocityDatas = self.velocityDatas
	local key = timePoint
	local velocityData = assert(velocityDatas[key], "velocity data not found")
	velocityDatas[key] = nil

	self.velocityDatasRange:remove(velocityData)

	velocityData:delete()

	self:compute()
end

function DynamicLayerData:getNoteData(timePoint, inputType, inputIndex)
	local noteData = NoteData:new(timePoint, inputType, inputIndex)
	timePoint.noteDatas = timePoint.noteDatas or {}
	table.insert(timePoint.noteDatas, noteData)

	return noteData
end

function DynamicLayerData:removeNoteData(noteData)
	local noteDatas = noteData.timePoint.noteDatas
	for i, v in ipairs(noteDatas) do
		if v == noteData then
			table.remove(noteDatas, i)
			break
		end
	end
end

return DynamicLayerData
