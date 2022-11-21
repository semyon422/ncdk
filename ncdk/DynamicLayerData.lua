local Fraction = require("ncdk.Fraction")
local TimePoint = require("ncdk.TimePoint")
local TempoData = require("ncdk.TempoData")
local StopData = require("ncdk.StopData")
local VelocityData = require("ncdk.VelocityData")
local ExpandData = require("ncdk.ExpandData")
local SignatureData = require("ncdk.SignatureData")
local NoteData = require("ncdk.NoteData")
local RangeTracker = require("ncdk.RangeTracker")

local DynamicLayerData = {}

local mt = {__index = DynamicLayerData}

function DynamicLayerData:new()
	local layerData = {}

	layerData.defaultSignature = Fraction:new(4)

	layerData.timePoints = {}
	layerData.tempoDatas = {}
	layerData.stopDatas = {}
	layerData.velocityDatas = {}
	layerData.expandDatas = {}
	layerData.signatureDatas = {}
	layerData.noteDatas = {}

	local timePointsRange = RangeTracker:new()
	layerData.timePointsRange = timePointsRange
	function timePointsRange:getObjectTime(object) return object.measureTime end

	local tempoDatasRange = RangeTracker:new()
	layerData.tempoDatasRange = tempoDatasRange
	function tempoDatasRange:getObjectTime(object) return object.timePoint.measureTime end

	local stopDatasRange = RangeTracker:new()
	layerData.stopDatasRange = stopDatasRange
	function stopDatasRange:getObjectTime(object) return object.timePoint.measureTime end

	local velocityDatasRange = RangeTracker:new()
	layerData.velocityDatasRange = velocityDatasRange
	function velocityDatasRange:getObjectTime(object) return object.timePoint.measureTime end

	local expandDatasRange = RangeTracker:new()
	layerData.expandDatasRange = expandDatasRange
	function expandDatasRange:getObjectTime(object) return object.timePoint.measureTime end

	local signatureDatasRange = RangeTracker:new()
	layerData.signatureDatasRange = signatureDatasRange
	function signatureDatasRange:getObjectTime(object) return object.timePoint.measureTime end

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

function DynamicLayerData:setSignatureMode(mode)
	assert(mode == "long" or mode == "short", "Wrong signature mode")
	self.signatureMode = mode
end

function DynamicLayerData:_setRange(startTime, endTime)
	self.timePointsRange:setRange(startTime, endTime)
	self.tempoDatasRange:setRange(startTime, endTime)
	self.stopDatasRange:setRange(startTime, endTime)
	self.velocityDatasRange:setRange(startTime, endTime)
	self.expandDatasRange:setRange(startTime, endTime)
	self.signatureDatasRange:setRange(startTime, endTime)
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

local function map(x, a, b, c, d)
	return (x - a) * (d - c) / (b - a) + c
end

function DynamicLayerData:getDynamicTimePoint(time, side)
	assert(self.mode, "Mode should be set")

	if type(time) == "number" then
		time = math.min(math.max(time, -2147483648), 2147483647)
	end

	self.dynamicTimePoint = self.dynamicTimePoint or TimePoint:new()
	local timePoint = self.dynamicTimePoint

	timePoint.side = side
	if self.mode == "absolute" then
		timePoint.absoluteTime = time
	elseif self.mode == "measure" then
		timePoint.measureTime = time
	end

	local t = time:tonumber()

	local a, b = self.timePointsRange:getInterp(timePoint)
	a = a or self:getTimePoint(Fraction:new(time:floor()), -1)
	b = b or self:getTimePoint(Fraction:new(time:ceil()), -1)

	if a == b then
		timePoint.absoluteTime = a.absoluteTime
		timePoint.zeroClearVisualTime = a.zeroClearVisualTime
	else
		local ta, tb = a.measureTime:tonumber(), b.measureTime:tonumber()
		timePoint.absoluteTime = map(t, ta, tb, a.absoluteTime, b.absoluteTime)
		timePoint.zeroClearVisualTime = map(t, ta, tb, a.zeroClearVisualTime, b.zeroClearVisualTime)
	end

	return timePoint
end

function DynamicLayerData:getTimePoint(time, side, visualSide)
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

	self.timePointsRange:insert(timePoint)
	self:compute()

	return timePoint
end

function DynamicLayerData:compute()
	assert(self.mode, "Mode should be set")

	local isMeasure = self.mode == "measure"
	local isLong = self.signatureMode == "long"

	local tempoData = self.tempoDatasRange.startObject
	local velocityData = self.velocityDatasRange.startObject

	local timePoint = self.timePointsRange.startObject
	local endTimePoint = self.timePointsRange.endObject

	local signatureData = self.signatureDatasRange.startObject
	if signatureData and signatureData.timePoint > timePoint then
		signatureData = nil
	end

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
			isAtTimePoint = timePoint.measureTime == targetTime

			local signature = self.defaultSignature
			if signatureData and (isLong or measureIndex == signatureData.timePoint.measureTime:tonumber()) then
				signature = signatureData.signature
			end

			if tempoData then
				local duration = tempoData:getBeatDuration() * signature
				time = time + duration * (targetTime - currentTime)
			end
			currentTime = targetTime

			if isAtTimePoint then
				local nextTempoData = timePoint._tempoData
				if nextTempoData then
					tempoData = nextTempoData
				end

				local nextSignatureData = timePoint._signatureData
				if nextSignatureData then
					signatureData = nextSignatureData
				end

				local stopData = timePoint._stopData
				if stopData then
					stopData.tempoData = tempoData
					time = time + stopData.duration:tonumber() * tempoData:getBeatDuration()
				end
			end
		else
			time = timePoint.absoluteTime
		end

		local currentSpeed = velocityData and velocityData.currentSpeed or 1
		visualTime = visualTime + (time - currentAbsoluteTime) * currentSpeed
		currentAbsoluteTime = time

		if isAtTimePoint then
			local nextVelocityData = timePoint._velocityData
			if nextVelocityData then
				velocityData = nextVelocityData
			end

			local expandData = timePoint._expandData
			if expandData then
				expandData.velocityData = velocityData
				local duration = expandData.duration
				if isMeasure then
					duration = expandData.duration:tonumber() * tempoData:getBeatDuration() * currentSpeed
				end
				visualTime = visualTime + duration
			end

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

	local t = self.timePointsRange.firstObject
	while t do
		t.absoluteTime = t.absoluteTime - zeroTime
		t.zeroClearVisualTime = t.zeroClearVisualTime - zeroVisualTime
		t = t.next
	end
end

function DynamicLayerData:getTimingObject(timePoint, name, class, ...)
	local objects = self[name .. "s"]
	local key = tostring(timePoint)

	local object = objects[key]
	if object then
		if select("#", ...) > 0 and object:set(...) then
			self:compute()
		end
		return object
	end

	object = class:new(...)
	objects[key] = object

	timePoint["_" .. name] = object
	object.timePoint = timePoint

	self[name .. "sRange"]:insert(object)
	self:compute()

	return object
end

function DynamicLayerData:removeTimingObject(timePoint, name)
	local objects = self[name .. "s"]
	local key = tostring(timePoint)
	local object = assert(objects[key], name .. " not found")
	objects[key] = nil

	self[name .. "sRange"]:remove(object)

	object.timePoint["_" .. name] = nil
	object.timePoint = nil

	self:compute()
end

function DynamicLayerData:getTempoData(time, ...)
	return self:getTimingObject(self:getTimePoint(time), "tempoData", TempoData, ...)
end
function DynamicLayerData:removeTempoData(time)
	return self:removeTimingObject(self:getTimePoint(time), "tempoData")
end

function DynamicLayerData:getStopData(time, ...)
	local stopData = self:getTimingObject(self:getTimePoint(time, 1), "stopData", StopData, ...)
	stopData.leftTimePoint = self:getTimePoint(time, -1)  -- for time point interpolation
	return stopData
end
function DynamicLayerData:removeStopData(time)
	return self:removeTimingObject(self:getTimePoint(time, 1), "stopData")
end

function DynamicLayerData:getVelocityData(time, side, ...)
	return self:getTimingObject(self:getTimePoint(time, side), "velocityData", VelocityData, ...)
end
function DynamicLayerData:removeVelocityData(time, side)
	return self:removeTimingObject(self:getTimePoint(time, side), "velocityData")
end

function DynamicLayerData:getExpandData(time, side, ...)
	local expandData = self:getTimingObject(self:getTimePoint(time, side, 1), "expandData", ExpandData, ...)
	expandData.leftTimePoint = self:getTimePoint(time, side, -1)  -- for time point interpolation
	return expandData
end
function DynamicLayerData:removeExpandData(time, side)
	return self:removeTimingObject(self:getTimePoint(time, side, 1), "expandData")
end

function DynamicLayerData:getSignatureData(measureIndex, ...)
	assert(self.signatureMode, "Signature mode should be set")
	local timePoint = self:getTimePoint(Fraction:new(measureIndex))
	self:getTimePoint(Fraction:new(measureIndex + 1))  -- for time point interpolation
	return self:getTimingObject(timePoint, "signatureData", SignatureData, ...)
end
function DynamicLayerData:removeSignatureData(measureIndex)
	local timePoint = self:getTimePoint(Fraction:new(measureIndex))
	return self:removeTimingObject(timePoint, "signatureData")
end

function DynamicLayerData:getSignature(measureIndex)
	local mode = self.signatureMode
	assert(mode, "Signature mode should be set")

	local range = self.signatureDatasRange
	local signatureData = range.startObject
	if not signatureData or measureIndex < signatureData.timePoint.measureTime:floor() then
		return self.defaultSignature
	end

	local endSignatureData = range.endObject
	while signatureData and signatureData <= endSignatureData do
		local time = signatureData.timePoint.measureTime:floor()
		if mode == "short" and time == measureIndex or mode == "long" and time <= measureIndex then
			return signatureData.signature
		end
		signatureData = signatureData.next
	end
	return self.defaultSignature
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
