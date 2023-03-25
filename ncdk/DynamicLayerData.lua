local Fraction = require("ncdk.Fraction")
local TempoData = require("ncdk.TempoData")
local StopData = require("ncdk.StopData")
local VelocityData = require("ncdk.VelocityData")
local ExpandData = require("ncdk.ExpandData")
local IntervalData = require("ncdk.IntervalData")
local MeasureData = require("ncdk.MeasureData")
local SignatureData = require("ncdk.SignatureData")
local NoteData = require("ncdk.NoteData")
local RangeTracker = require("ncdk.RangeTracker")
local AbsoluteTimePoint = require("ncdk.AbsoluteTimePoint")
local IntervalTimePoint = require("ncdk.IntervalTimePoint")
local MeasureTimePoint = require("ncdk.MeasureTimePoint")

local DynamicLayerData = {}

DynamicLayerData.primaryTempo = 0
DynamicLayerData.minBeatDuration = 60 / 1000

DynamicLayerData.defaultSignature = Fraction:new(4)
DynamicLayerData.mainTimeField = "measureTime"

local mt = {__index = DynamicLayerData}
function DynamicLayerData:new(ld)
	local layerData = setmetatable({}, mt)

	layerData:init()
	if ld then
		layerData:load(ld)
	end

	return layerData
end

local rangeNames = {"timePoint", "tempo", "stop", "velocity", "expand", "signature", "interval", "measure"}
function DynamicLayerData:init()
	local function getTime(_, object)
		if object.timePoint then
			object = object.timePoint
		end
		if self.mainTimeField == "measureTime" then
			return object.measureTime
		end
		return object:tonumber()
	end
	self.getTime = getTime

	local ranges = {}
	self.ranges = ranges

	for _, name in ipairs(rangeNames) do
		local range = RangeTracker:new()
		ranges[name] = range
		range.getTime = getTime
	end

	ranges.note = {}
end

function DynamicLayerData:getNoteRange(inputType, inputIndex)
	local ranges = self.ranges.note
	ranges[inputType] = ranges[inputType] or {}
	local range = ranges[inputType][inputIndex]
	if not range then
		range = RangeTracker:new()
		ranges[inputType][inputIndex] = range
		range.getTime = self.getTime
		range:setRange(self.startTime, self.endTime)
	end
	return range
end

function DynamicLayerData:load(layerData)
	local ranges = self.ranges
	ranges.timePoint:fromList(layerData.timePointList)
	ranges.tempo:fromList(layerData.tempoDatas)
	ranges.stop:fromList(layerData.stopDatas)
	ranges.velocity:fromList(layerData.velocityDatas)
	ranges.expand:fromList(layerData.expandDatas)
	ranges.interval:fromList(layerData.intervalDatas)
	ranges.measure:fromList(layerData.measureDatas)
	ranges.signature:fromList(layerData.signatureDatas)

	for inputType, r in pairs(layerData.noteDatas) do
		for inputIndex, noteDatas in pairs(r) do
			local range = self:getNoteRange(inputType, inputIndex)
			range:fromList(noteDatas)
		end
	end

	self.mode = layerData.mode
	if layerData.signatureMode then
		self.signatureMode = layerData.signatureMode
		self.defaultSignature = layerData.defaultSignature
	end
	self:setTimeMode(layerData.mode)
end

function DynamicLayerData:save(layerData)
	local ranges = self.ranges
	layerData.timePointList = ranges.timePoint:toList()
	layerData.tempoDatas = ranges.tempo:toList()
	layerData.stopDatas = ranges.stop:toList()
	layerData.velocityDatas = ranges.velocity:toList()
	layerData.expandDatas = ranges.expand:toList()
	layerData.intervalDatas = ranges.interval:toList()
	layerData.measureDatas = ranges.measure:toList()

	layerData.signatures = {}
	for _, signatureData in ipairs(ranges.signature:toList()) do
		layerData.signatures[signatureData.timePoint.measureTime:tonumber()] = signatureData.signature
	end

	layerData.timePoints = {}
	for _, timePoint in ipairs(layerData.timePointList) do
		layerData.timePoints[tostring(timePoint)] = timePoint
	end
	for inputType, r in pairs(ranges.note) do
		layerData.noteDatas[inputType] = {}
		for inputIndex, range in pairs(r) do
			layerData.noteDatas[inputType][inputIndex] = range:toList()
		end
	end

	layerData.mode = self.mode
	if self.signatureMode then
		layerData.signatureMode = self.signatureMode
		layerData.defaultSignature = self.defaultSignature
	end
end

function DynamicLayerData:setTimeMode(mode)
	self.mode = mode
	local time
	if mode == "absolute" then
		time = 0
	elseif mode == "measure" then
		self.mainTimeField = "measureTime"
		time = Fraction:new(0)
	elseif mode == "interval" then
		self.mainTimeField = "intervalTime"
		self:_setRange(0, 0)
		self.startTime, self.endTime = time, time
		self.dynamicTimePoint = self:newTimePoint()
		return
	else
		error("Wrong time mode")
	end
	self:_setRange(time, time)
	self.startTime, self.endTime = time, time
	self.zeroTimePoint = self:getTimePoint(time)
	self.dynamicTimePoint = self:newTimePoint()
end

function DynamicLayerData:setSignatureMode(mode)
	assert(mode == "long" or mode == "short", "Wrong signature mode")
	self.signatureMode = mode
	self:compute()
end

function DynamicLayerData:setPrimaryTempo(tempo)
	assert(tempo >= 0, "Wrong primary tempo")
	self.primaryTempo = tempo
	self:compute()
end

function DynamicLayerData:setDefaultSignature(signature)
	assert(type(signature) == "table" and signature[1] > 0, "Wrong default signature tempo")
	self.defaultSignature = signature
	self:compute()
end

function DynamicLayerData:_setRange(startTime, endTime)
	for _, name in ipairs(rangeNames) do
		self.ranges[name]:setRange(startTime, endTime)
	end
	for _, r in pairs(self.ranges.note) do
		for _, range in pairs(r) do
			range:setRange(startTime, endTime)
		end
	end
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

function DynamicLayerData:newTimePoint()
	local mode = assert(self.mode, "Mode should be set")
	if mode == "absolute" then
		return AbsoluteTimePoint:new()
	elseif mode == "measure" then
		return MeasureTimePoint:new()
	elseif mode == "interval" then
		return IntervalTimePoint:new()
	end
end

local function map(x, a, b, c, d)
	return (x - a) * (d - c) / (b - a) + c
end

function DynamicLayerData:resetDynamicTimePoint()
	local timePoint = self.dynamicTimePoint
	for k in pairs(timePoint) do
		timePoint[k] = nil
	end
end

function DynamicLayerData:getDynamicTimePoint(...)
	local mode = assert(self.mode, "Mode should be set")

	local timePoint = self.dynamicTimePoint

	self:resetDynamicTimePoint()
	timePoint:setTime(...)

	local t = timePoint:tonumber()

	local a, b = self.ranges.timePoint:getInterp(timePoint)
	if not a and not b then
		return
	elseif a == b then
		return a
	elseif a and b then
		local ta, tb
		if mode == "measure" then
			ta, tb = a.measureTime:tonumber(), b.measureTime:tonumber()
		elseif mode == "interval" then
			ta, tb = a:tonumber(), b:tonumber()
		end
		timePoint.absoluteTime = map(t, ta, tb, a.absoluteTime, b.absoluteTime)
		timePoint.visualTime = map(t, ta, tb, a.visualTime, b.visualTime)
		timePoint.beatTime = map(t, ta, tb, a.beatTime, b.beatTime)
		timePoint.prev = a
		timePoint.next = b
	else
		local signature = self.defaultSignature
		if a then
			local signatureData = a.signatureData
			if signatureData and signatureData.timePoint > timePoint then
				signatureData = nil
			end
			if signatureData and self.signatureMode == "long" then
				signature = signatureData.signature
			end
		end
		timePoint.prev = a and a.prev
		timePoint.next = b and b.next
		a = a or b

		local tempoMultiplier = self.primaryTempo == 0 and 1 or a.tempoData.tempo / self.primaryTempo
		if b and b._stopData then
			tempoMultiplier = 0
		end

		if mode == "measure" then
			local duration = (t - a.measureTime:tonumber()) * signature
			timePoint.absoluteTime = a.absoluteTime + duration * a.tempoData:getBeatDuration()
			timePoint.beatTime = a.beatTime + duration
		elseif mode == "interval" then
			local intervalData, nextIntervalData = a.intervalData:getPair()
			local _a, _b = intervalData.timePoint, nextIntervalData.timePoint
			local ta, tb = _a:tonumber(), _b:tonumber()
			timePoint.absoluteTime = map(t, ta, tb, _a.absoluteTime, _b.absoluteTime)
		end

		local currentSpeed = a.velocityData and a.velocityData.currentSpeed or 1
		timePoint.visualTime = a.visualTime + (timePoint.absoluteTime - a.absoluteTime) * currentSpeed * tempoMultiplier
	end

	timePoint.tempoData = a.tempoData
	timePoint.velocityData = a.velocityData
	timePoint.intervalData = timePoint.intervalData or a.intervalData
	timePoint.visualSection = a.visualSection
	timePoint.measureData = a.measureData

	return timePoint
end

function DynamicLayerData:getDynamicTimePointAbsolute(limit, absoluteTime, visualSide)
	local mode = assert(self.mode, "Mode should be set")
	assert(limit)

	local timePoint = self.dynamicTimePoint

	self:resetDynamicTimePoint()
	timePoint:setTimeAbsolute(absoluteTime, visualSide)

	local t = absoluteTime

	local a, b = self.ranges.timePoint:getInterp(timePoint)
	if not a and not b then
		return
	elseif a == b then
		return a
	elseif a and b then
		if mode == "measure" then
			local ta, tb = a.measureTime:tonumber(), b.measureTime:tonumber()
			local measureTime = map(t, a.absoluteTime, b.absoluteTime, ta, tb)
			timePoint.measureTime = Fraction:new(measureTime, limit, true)
		elseif mode == "interval" then
			timePoint:fromnumber(a.intervalData, t, limit, a.measureData, true)
		end
		timePoint.visualTime = map(t, a.absoluteTime, b.absoluteTime, a.visualTime, b.visualTime)
		timePoint.beatTime = map(t, a.absoluteTime, b.absoluteTime, a.beatTime, b.beatTime)
		timePoint.prev = a
		timePoint.next = b
	elseif a or b then
		local signature = self.defaultSignature
		if a then
			local signatureData = a.signatureData
			if signatureData and signatureData.timePoint > timePoint then
				signatureData = nil
			end
			if signatureData and self.signatureMode == "long" then
				signature = signatureData.signature
			end
		end
		timePoint.prev = a and a.prev
		timePoint.next = b and b.next
		a = a or b

		local tempoMultiplier = self.primaryTempo == 0 and 1 or a.tempoData.tempo / self.primaryTempo
		if b and b._stopData then
			tempoMultiplier = 0
		end

		if mode == "measure" then
			local duration = (t - a.absoluteTime) / a.tempoData:getBeatDuration()
			timePoint.measureTime = a.measureTime + Fraction:new(duration / signature, limit, true)
			timePoint.beatTime = a.beatTime + duration
		elseif mode == "interval" then
			timePoint:fromnumber(a.intervalData, t, limit, a.measureData, true)
		end

		local currentSpeed = a.velocityData and a.velocityData.currentSpeed or 1
		timePoint.visualTime = a.visualTime + (t - a.absoluteTime) * currentSpeed * tempoMultiplier
	end

	timePoint.tempoData = a.tempoData
	timePoint.velocityData = a.velocityData
	timePoint.intervalData = timePoint.intervalData or a.intervalData
	timePoint.visualSection = a.visualSection
	timePoint.measureData = a.measureData

	return timePoint
end

function DynamicLayerData:checkTimePoint(timePoint)
	local dtp = self.dynamicTimePoint
	if timePoint.ptr == dtp.ptr then
		timePoint = self:getTimePoint(dtp:getTime())
	end
	return timePoint
end

function DynamicLayerData:getTimePoint(...)
	local timePoint = self:newTimePoint()
	timePoint:setTime(...)

	local t = self.ranges.timePoint:find(timePoint)
	if t then
		return t
	end

	self.ranges.timePoint:insert(timePoint)
	self:compute()

	return timePoint
end

function DynamicLayerData:compute()
	local mode = assert(self.mode, "Mode should be set")

	local isMeasure = mode == "measure"
	local isInterval = mode == "interval"
	local isLong = self.signatureMode == "long"

	local ranges = self.ranges
	local tempoData = ranges.tempo.head
	local velocityData = ranges.velocity.head
	local measureData = ranges.measure.head

	local intervalData = ranges.interval.head
	if intervalData and not intervalData.next and intervalData.prev then
		intervalData = intervalData.prev
	end

	local timePoint = ranges.timePoint.head
	local endTimePoint = ranges.timePoint.tail

	if not timePoint then
		return
	end

	local signatureData = ranges.signature.head
	if signatureData and signatureData.timePoint > timePoint then
		signatureData = nil
	end

	local primaryTempo = self.primaryTempo

	-- start with prev time point to be not affected by stops and expands
	local prevTimePoint = timePoint.prev or timePoint
	local time = prevTimePoint.absoluteTime or 0
	local beatTime = prevTimePoint.beatTime or 0
	local visualTime = prevTimePoint.visualTime or 0
	local visualSection = prevTimePoint.visualSection or 0
	local currentTime = prevTimePoint.measureTime
	local currentAbsoluteTime = time
	while timePoint and timePoint <= endTimePoint do
		local isAtTimePoint = not isMeasure
		if isMeasure then
			local measureOffset = currentTime:floor()

			local targetTime = Fraction:new(measureOffset + 1)
			if timePoint.measureTime < targetTime then
				targetTime = timePoint.measureTime
			end
			isAtTimePoint = timePoint.measureTime == targetTime

			local signature = self.defaultSignature
			if signatureData and (isLong or measureOffset == signatureData.timePoint.measureTime:tonumber()) then
				signature = signatureData.signature
			end

			beatTime = beatTime + signature:tonumber() * (targetTime - currentTime)

			if tempoData then
				local duration = tempoData:getBeatDuration() * signature
				time = time + duration * (targetTime - currentTime)
			end
			currentTime = targetTime
		elseif isInterval and intervalData then
			if timePoint._intervalData then
				intervalData = timePoint._intervalData
			end
			if timePoint._measureData then
				measureData = timePoint._measureData
			end
			time = timePoint:tonumber()
		elseif not isInterval then
			time = timePoint.absoluteTime
		end

		local tempoMultiplier = (primaryTempo == 0 or not tempoData) and 1 or tempoData.tempo / primaryTempo

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
				if isMeasure then
					local duration = stopData.duration
					if not stopData.isAbsolute then
						duration = tempoData:getBeatDuration() * duration
					end
					time = time + duration
					if primaryTempo ~= 0 then
						tempoMultiplier = 0
					end
				end
			end
		end

		local currentSpeed = velocityData and velocityData.currentSpeed or 1
		visualTime = visualTime + (time - currentAbsoluteTime) * currentSpeed * tempoMultiplier
		currentAbsoluteTime = time

		if isAtTimePoint then
			local nextVelocityData = timePoint._velocityData
			if nextVelocityData then
				velocityData = nextVelocityData
			end
			currentSpeed = velocityData and velocityData.currentSpeed or 1

			local expandData = timePoint._expandData
			if expandData then
				local duration = expandData.duration
				if isMeasure then
					duration = tempoData:getBeatDuration() * duration * currentSpeed
				elseif isInterval then
					duration = intervalData:getBeatDuration() * duration * currentSpeed
				end
				if math.abs(duration) == math.huge then
					visualSection = visualSection + 1
				else
					visualTime = visualTime + duration
				end
			end

			timePoint.tempoData = tempoData
			timePoint.velocityData = velocityData
			timePoint.signatureData = signatureData
			timePoint.measureData = measureData

			if not timePoint.readonly then
				timePoint.absoluteTime = time
			end
			timePoint.beatTime = beatTime
			timePoint.visualTime = visualTime
			timePoint.visualSection = visualSection

			timePoint = timePoint.next
		end
	end

	local zeroTimePoint = self.zeroTimePoint
	if not zeroTimePoint then
		return
	end

	local zeroBeatTime = zeroTimePoint.beatTime
	local zeroTime = zeroTimePoint.absoluteTime
	local zeroVisualTime = zeroTimePoint.visualTime

	local t = self.ranges.timePoint.head
	while t and t <= endTimePoint  do
		t.beatTime = t.beatTime - zeroBeatTime
		t.absoluteTime = t.absoluteTime - zeroTime
		t.visualTime = t.visualTime - zeroVisualTime
		t = t.next
	end
end

function DynamicLayerData:getTimingObject(timePoint, name, class, ...)
	local key = "_" .. name .. "Data"
	local object = timePoint[key]
	if object then
		if select("#", ...) > 0 and object:set(...) then
			self:compute()
		end
		return object
	end

	object = class:new(...)

	timePoint[key] = object
	object.timePoint = timePoint

	self.ranges[name]:insert(object)
	self:compute()

	return object
end

function DynamicLayerData:removeTimingObject(timePoint, name)
	local key = "_" .. name .. "Data"
	local object = assert(timePoint[key], name .. " not found")

	self.ranges[name]:remove(object)

	timePoint[key] = nil
	object.timePoint = nil

	self:compute()
end

function DynamicLayerData:getTempoData(time, ...)
	return self:getTimingObject(self:getTimePoint(time), "tempo", TempoData, ...)
end
function DynamicLayerData:removeTempoData(time)
	return self:removeTimingObject(self:getTimePoint(time), "tempo")
end

function DynamicLayerData:getStopData(time, ...)
	local timePoint = self:getTimePoint(time, 1)
	local stopData = self:getTimingObject(timePoint, "stop", StopData, ...)
	stopData.leftTimePoint = self:getTimePoint(timePoint:getPrevTime())  -- for time point interpolation
	return stopData
end
function DynamicLayerData:removeStopData(time)
	return self:removeTimingObject(self:getTimePoint(time, 1), "stop")
end

function DynamicLayerData:getVelocityData(timePoint, ...)
	timePoint = self:checkTimePoint(timePoint)
	return self:getTimingObject(timePoint, "velocity", VelocityData, ...)
end
function DynamicLayerData:removeVelocityData(timePoint)
	return self:removeTimingObject(timePoint, "velocity")
end

function DynamicLayerData:getExpandData(timePoint, ...)
	timePoint = self:checkTimePoint(timePoint)
	local expandData = self:getTimingObject(timePoint, "expand", ExpandData, ...)
	expandData.leftTimePoint = self:getTimePoint(timePoint:getPrevVisualTime())  -- for time point interpolation
	return expandData
end
function DynamicLayerData:removeExpandData(timePoint)
	return self:removeTimingObject(timePoint, "expand")
end

function DynamicLayerData:getSignatureData(measureOffset, ...)
	assert(self.signatureMode, "Signature mode should be set")
	local timePoint = self:getTimePoint(Fraction:new(measureOffset))
	self:getTimePoint(Fraction:new(measureOffset + 1))  -- for time point interpolation
	return self:getTimingObject(timePoint, "signature", SignatureData, ...)
end
function DynamicLayerData:removeSignatureData(measureOffset)
	local timePoint = self:getTimePoint(Fraction:new(measureOffset))
	return self:removeTimingObject(timePoint, "signature")
end

function DynamicLayerData:getSignature(measureOffset)
	local mode = self.signatureMode
	assert(mode, "Signature mode should be set")

	local range = self.ranges.signature
	local signatureData = range.head
	if not signatureData or measureOffset < signatureData.timePoint.measureTime:floor() then
		return self.defaultSignature
	end

	signatureData = range.tail
	while signatureData and signatureData >= range.head do
		local time = signatureData.timePoint.measureTime:floor()
		if mode == "short" and time == measureOffset or mode == "long" and time <= measureOffset then
			return signatureData.signature
		end
		signatureData = signatureData.prev
	end
	return self.defaultSignature
end

function DynamicLayerData:_getIntervalData(timePoint, ...)
	return self:getTimingObject(timePoint, "interval", IntervalData, ...)
end
function DynamicLayerData:getIntervalData(absoluteTime, beats, start)
	local timePoint = self:getTimePoint(absoluteTime)
	timePoint.absoluteTime = absoluteTime
	timePoint.readonly = true
	local intervalData = self:_getIntervalData(timePoint, beats)
	timePoint.intervalData = intervalData
	timePoint.time = start
	return intervalData
end
function DynamicLayerData:_removeIntervalData(timePoint)
	return self:removeTimingObject(timePoint, "interval")
end
function DynamicLayerData:removeIntervalData(absoluteTime)
	local timePoint = self:getTimePoint(absoluteTime)
	return self:_removeIntervalData(timePoint)
end
function DynamicLayerData:splitInterval(timePoint)
	local _intervalData = timePoint.intervalData

	local time = timePoint.time
	local _beats = time:floor()

	local intervalData
	local tp, dir
	if time[1] > 0 then
		local beats = _intervalData.next and _intervalData.beats - _beats or 1
		if timePoint.ptr == self.dynamicTimePoint.ptr then
			intervalData = self:getIntervalData(timePoint.absoluteTime, beats, time % 1)
		else
			timePoint.readonly = true
			intervalData = self:_getIntervalData(timePoint, beats)
			timePoint:setTime(intervalData, time % 1)
		end
		_intervalData.beats = _beats

		tp = timePoint.next
		dir = "next"
	else
		if timePoint.ptr == self.dynamicTimePoint.ptr then
			intervalData = self:getIntervalData(timePoint.absoluteTime, -_beats, time % 1)
		else
			intervalData = self:_getIntervalData(timePoint, -_beats)
		end
		intervalData.timePoint:setTime(_intervalData, time)
		tp = _intervalData.timePoint.prev
		dir = "prev"
	end
	while tp and tp.intervalData == _intervalData do
		tp.intervalData = intervalData
		tp.time = tp.time - _beats
		tp = tp[dir]
	end

	self:compute()
	return intervalData
end
function DynamicLayerData:mergeInterval(timePoint)
	local _intervalData = timePoint._intervalData
	if not _intervalData or self.ranges.interval.count == 2 then
		return
	end

	timePoint.readonly = false

	local _prev, _next = _intervalData.prev, _intervalData.next

	local _beats, intervalData, tp, dir
	if _prev then
		_beats = _prev.beats
		_prev.beats = _next and _prev.beats + _intervalData.beats or 1
		tp = timePoint
		intervalData = _prev
		dir = "next"
	elseif _next then
		_beats = -_intervalData.beats
		tp = _next.timePoint.prev
		intervalData = _next
		dir = "prev"
	end
	while tp and tp.intervalData == _intervalData do
		tp.intervalData = intervalData
		tp.time = tp.time + _beats
		tp = tp[dir]
	end

	self:_removeIntervalData(timePoint)
end
function DynamicLayerData:moveInterval(intervalData, absoluteTime)
	if intervalData.timePoint.absoluteTime == absoluteTime then
		return
	end
	local minTime, maxTime = -math.huge, math.huge
	if intervalData.prev then
		minTime = intervalData.prev.timePoint.absoluteTime + self.minBeatDuration * intervalData.prev:getDuration()
	end
	if intervalData.next then
		maxTime = intervalData.next.timePoint.absoluteTime - self.minBeatDuration * intervalData:getDuration()
	end
	if minTime >= maxTime then
		return
	end
	intervalData.timePoint.absoluteTime = math.min(math.max(absoluteTime, minTime), maxTime)
	self:compute()
end
function DynamicLayerData:updateInterval(intervalData, beats)
	local a, b = intervalData, intervalData.next
	beats = math.max(beats, 0)
	assert(math.floor(beats) == beats)

	if not b or beats == a.beats or beats == 0 and a:start() >= b:start() then
		return
	end

	local _a, _b = a.timePoint, b.timePoint

	local maxBeats = (_b.absoluteTime - _a.absoluteTime) / self.minBeatDuration + a:start() - b:start()
	beats = math.min(beats, math.floor(maxBeats))

	if beats < intervalData.beats then
		local rightTimePoint = b.timePoint
		local tp = rightTimePoint.prev
		while tp and tp ~= _a and tp.time >= b:start() + beats do
			self.ranges.timePoint:remove(tp)
			tp = rightTimePoint.prev
		end
	end
	intervalData.beats = beats
	self:compute()
end

function DynamicLayerData:getMeasureData(timePoint, ...)
	timePoint = self:checkTimePoint(timePoint)
	return self:getTimingObject(timePoint, "measure", MeasureData, ...)
end
function DynamicLayerData:removeMeasureData(timePoint)
	return self:removeTimingObject(timePoint, "measure")
end

function DynamicLayerData:getNoteData(timePoint, inputType, inputIndex)
	timePoint = self:checkTimePoint(timePoint)
	local noteData = NoteData:new(timePoint)
	return self:addNoteData(noteData, inputType, inputIndex)
end

function DynamicLayerData:addNoteData(noteData, inputType, inputIndex)
	local range = self:getNoteRange(inputType, inputIndex)
	range:insert(noteData)
	return noteData
end

function DynamicLayerData:removeNoteData(noteData, inputType, inputIndex)
	local range = self:getNoteRange(inputType, inputIndex)
	range:remove(noteData)
end

return DynamicLayerData
