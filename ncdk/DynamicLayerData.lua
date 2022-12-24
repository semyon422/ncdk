local Fraction = require("ncdk.Fraction")
local TimePoint = require("ncdk.TimePoint")
local TempoData = require("ncdk.TempoData")
local StopData = require("ncdk.StopData")
local VelocityData = require("ncdk.VelocityData")
local ExpandData = require("ncdk.ExpandData")
local IntervalData = require("ncdk.IntervalData")
local SignatureData = require("ncdk.SignatureData")
local NoteData = require("ncdk.NoteData")
local RangeTracker = require("ncdk.RangeTracker")
local IntervalTime = require("ncdk.IntervalTime")

local DynamicLayerData = {}

DynamicLayerData.primaryTempo = 0
DynamicLayerData.minimumBeatLength = 60 / 1000

local mt = {__index = DynamicLayerData}

function DynamicLayerData:new()
	local layerData = {}

	layerData.dynamicTimePoint = TimePoint:new()
	layerData.defaultSignature = Fraction:new(4)

	layerData.mainTimeField = "measureTime"
	local ld = layerData

	local function getTime(object)
		if ld.mainTimeField == "measureTime" then
			return object[ld.mainTimeField]
		end
		return object.intervalTime:tonumber()
	end

	local timePointsRange = RangeTracker:new()
	layerData.timePointsRange = timePointsRange
	function timePointsRange:getObjectTime(object) return getTime(object) end

	local tempoDatasRange = RangeTracker:new()
	layerData.tempoDatasRange = tempoDatasRange
	function tempoDatasRange:getObjectTime(object) return getTime(object.timePoint) end

	local stopDatasRange = RangeTracker:new()
	layerData.stopDatasRange = stopDatasRange
	function stopDatasRange:getObjectTime(object) return getTime(object.timePoint) end

	local velocityDatasRange = RangeTracker:new()
	layerData.velocityDatasRange = velocityDatasRange
	function velocityDatasRange:getObjectTime(object) return getTime(object.timePoint) end

	local expandDatasRange = RangeTracker:new()
	layerData.expandDatasRange = expandDatasRange
	function expandDatasRange:getObjectTime(object) return getTime(object.timePoint) end

	local signatureDatasRange = RangeTracker:new()
	layerData.signatureDatasRange = signatureDatasRange
	function signatureDatasRange:getObjectTime(object) return getTime(object.timePoint) end

	local intervalDatasRange = RangeTracker:new()
	layerData.intervalDatasRange = intervalDatasRange
	function intervalDatasRange:getObjectTime(object) return getTime(object.timePoint) end

	return setmetatable(layerData, mt)
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
		return
	else
		error("Wrong time mode")
	end
	self:_setRange(time, time)
	self.zeroTimePoint = self:getTimePoint(time, -1)
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
	self.timePointsRange:setRange(startTime, endTime)
	self.tempoDatasRange:setRange(startTime, endTime)
	self.stopDatasRange:setRange(startTime, endTime)
	self.velocityDatasRange:setRange(startTime, endTime)
	self.expandDatasRange:setRange(startTime, endTime)
	self.signatureDatasRange:setRange(startTime, endTime)
	self.intervalDatasRange:setRange(startTime, endTime)
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

function DynamicLayerData:resetDynamicTimePoint()
	local timePoint = self.dynamicTimePoint
	timePoint.side = nil
	timePoint.visualSide = nil
	timePoint.measureTime = nil
	timePoint.absoluteTime = nil
	timePoint.intervalTime = nil
	timePoint.beatTime = 0
	timePoint._tempoData = nil
	timePoint._velocityData = nil
	timePoint._stopData = nil
	timePoint._expandData = nil
	timePoint._signatureData = nil
	timePoint._intervalData = nil
	timePoint.prev = nil
	timePoint.next = nil
end

function DynamicLayerData:setExactDynamicTimePoint(a, b)
	local timePoint = self.dynamicTimePoint
	timePoint.side = a.side
	timePoint.measureTime = a.measureTime
	timePoint.visualTime = a.visualTime
	timePoint.beatTime = a.beatTime
	timePoint.absoluteTime = a.absoluteTime
	timePoint.intervalTime = a.intervalTime
	timePoint._tempoData = a._tempoData
	timePoint._velocityData = a._velocityData
	timePoint._stopData = a._stopData
	timePoint._expandData = a._expandData
	timePoint._signatureData = a._signatureData
	timePoint._intervalData = a._intervalData
	timePoint.prev = a.prev
	timePoint.next = b.next
end

function DynamicLayerData:getDynamicTimePoint(time, side, visualSide)
	local mode = assert(self.mode, "Mode should be set")
	assert(time)

	local timePoint = self.dynamicTimePoint

	self:resetDynamicTimePoint()
	timePoint.side = side
	timePoint.visualSide = visualSide
	timePoint.mode = mode
	timePoint:setTime(time)

	local t = time:tonumber()

	local a, b = self.timePointsRange:getInterp(timePoint)
	if not a and not b then
		return
	elseif a == b then
		return a
	elseif a and b then
		local ta, tb
		if mode == "measure" then
			ta, tb = a.measureTime:tonumber(), b.measureTime:tonumber()
		elseif mode == "interval" then
			ta, tb = a.intervalTime:tonumber(), b.intervalTime:tonumber()
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
			local ta, tb = _a.intervalTime:tonumber(), _b.intervalTime:tonumber()
			timePoint.absoluteTime = map(t, ta, tb, _a.absoluteTime, _b.absoluteTime)
		end

		local currentSpeed = a.velocityData and a.velocityData.currentSpeed or 1
		timePoint.visualTime = a.visualTime + (timePoint.absoluteTime - a.absoluteTime) * currentSpeed * tempoMultiplier
	end

	timePoint.tempoData = a.tempoData
	timePoint.velocityData = a.velocityData
	timePoint.intervalData = a.intervalData

	return timePoint
end

function DynamicLayerData:getDynamicTimePointAbsolute(time, limit, side, visualSide)
	local mode = assert(self.mode, "Mode should be set")
	assert(time and limit)

	local timePoint = self.dynamicTimePoint

	self:resetDynamicTimePoint()
	timePoint.side = side
	timePoint.visualSide = visualSide
	timePoint.absoluteTime = time
	timePoint.mode = mode

	local t = time

	local a, b = self.timePointsRange:getInterp(timePoint)
	if not a and not b then
		return
	elseif a == b then
		return a
	elseif a and b then
		if mode == "measure" then
			local ta, tb = a.measureTime:tonumber(), b.measureTime:tonumber()
			local measureTime = map(t, a.absoluteTime, b.absoluteTime, ta, tb)
			timePoint.measureTime = Fraction:new(measureTime, limit, false)
		elseif mode == "interval" then
			timePoint.intervalTime = IntervalTime:fromnumber(a.intervalData, t, limit)
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
			timePoint.measureTime = a.measureTime + Fraction:new(duration / signature, limit, false)
			timePoint.beatTime = a.beatTime + duration
		elseif mode == "interval" then
			timePoint.intervalTime = IntervalTime:fromnumber(a.intervalData, t, limit)
		end

		local currentSpeed = a.velocityData and a.velocityData.currentSpeed or 1
		timePoint.visualTime = a.visualTime + (t - a.absoluteTime) * currentSpeed * tempoMultiplier
	end

	timePoint.tempoData = a.tempoData
	timePoint.velocityData = a.velocityData
	timePoint.intervalData = a.intervalData

	return timePoint
end

function DynamicLayerData:getTimePoint(time, side, visualSide)
	local mode = assert(self.mode, "Mode should be set")

	side = side or -1
	visualSide = visualSide or -1

	local timePoint = TimePoint:new()
	timePoint.side = side
	timePoint.visualSide = visualSide

	timePoint.mode = mode
	timePoint:setTime(time)

	local t = self.timePointsRange:find(timePoint)
	if t then
		return t
	end

	self.timePointsRange:insert(timePoint)
	self:compute()

	return timePoint
end

function DynamicLayerData:compute()
	local mode = assert(self.mode, "Mode should be set")

	local isMeasure = mode == "measure"
	local isInterval = mode == "interval"
	local isLong = self.signatureMode == "long"

	local tempoData = self.tempoDatasRange.startObject
	local velocityData = self.velocityDatasRange.startObject

	local intervalData = self.intervalDatasRange.startObject
	if intervalData and not intervalData.next then
		intervalData = intervalData.prev
	end

	local timePoint = self.timePointsRange.startObject
	local endTimePoint = self.timePointsRange.endObject

	if not timePoint then
		return
	end

	-- start with left time point to be not affected by stops and expands
	if timePoint.side == 1 and timePoint.prev and timePoint.prev.side == -1 then
		timePoint = timePoint.prev
	end
	if timePoint.visualSide == 1 and timePoint.prev and timePoint.prev.visualSide == -1 then
		timePoint = timePoint.prev
	end

	local signatureData = self.signatureDatasRange.startObject
	if signatureData and signatureData.timePoint > timePoint then
		signatureData = nil
	end

	local primaryTempo = self.primaryTempo

	local time = timePoint.absoluteTime or 0
	local beatTime = timePoint.beatTime or 0
	local visualTime = timePoint.visualTime or 0
	local currentTime = timePoint.measureTime
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
			time = timePoint.intervalTime:tonumber()
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

			local expandData = timePoint._expandData
			if expandData then
				expandData.velocityData = velocityData
				local duration = expandData.duration
				if isMeasure then
					duration = tempoData:getBeatDuration() * duration * currentSpeed
				elseif isInterval then
					duration = intervalData:getBeatDuration() * duration * currentSpeed
				end
				visualTime = visualTime + duration
			end

			timePoint.tempoData = tempoData
			timePoint.velocityData = velocityData
			timePoint.signatureData = signatureData
			timePoint.intervalData = intervalData

			if not timePoint.readonly then
				timePoint.absoluteTime = time
			end
			timePoint.beatTime = beatTime
			timePoint.visualTime = visualTime

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

	local t = self.timePointsRange.startObject
	while t do
		t.beatTime = t.beatTime - zeroBeatTime
		t.absoluteTime = t.absoluteTime - zeroTime
		t.visualTime = t.visualTime - zeroVisualTime
		t = t.next
	end
end

function DynamicLayerData:getTimingObject(timePoint, name, class, ...)
	local object = timePoint["_" .. name]
	if object then
		if select("#", ...) > 0 and object:set(...) then
			self:compute()
		end
		return object
	end

	object = class:new(...)

	timePoint["_" .. name] = object
	object.timePoint = timePoint

	self[name .. "sRange"]:insert(object)
	self:compute()

	return object
end

function DynamicLayerData:removeTimingObject(timePoint, name)
	local object = assert(timePoint["_" .. name], name .. " not found")

	self[name .. "sRange"]:remove(object)

	timePoint["_" .. name] = nil
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

function DynamicLayerData:getSignatureData(measureOffset, ...)
	assert(self.signatureMode, "Signature mode should be set")
	local timePoint = self:getTimePoint(Fraction:new(measureOffset))
	self:getTimePoint(Fraction:new(measureOffset + 1))  -- for time point interpolation
	return self:getTimingObject(timePoint, "signatureData", SignatureData, ...)
end
function DynamicLayerData:removeSignatureData(measureOffset)
	local timePoint = self:getTimePoint(Fraction:new(measureOffset))
	return self:removeTimingObject(timePoint, "signatureData")
end

function DynamicLayerData:getSignature(measureOffset)
	local mode = self.signatureMode
	assert(mode, "Signature mode should be set")

	local range = self.signatureDatasRange
	local signatureData = range.startObject
	if not signatureData or measureOffset < signatureData.timePoint.measureTime:floor() then
		return self.defaultSignature
	end

	signatureData = range.endObject
	while signatureData and signatureData >= range.startObject do
		local time = signatureData.timePoint.measureTime:floor()
		if mode == "short" and time == measureOffset or mode == "long" and time <= measureOffset then
			return signatureData.signature
		end
		signatureData = signatureData.prev
	end
	return self.defaultSignature
end

function DynamicLayerData:_getIntervalData(timePoint, ...)
	return self:getTimingObject(timePoint, "intervalData", IntervalData, ...)
end
function DynamicLayerData:getIntervalData(absoluteTime, ...)
	local timePoint = self:getTimePoint(IntervalTime:new(absoluteTime, Fraction:new(0)))
	timePoint.absoluteTime = absoluteTime
	timePoint.readonly = true
	local intervalData = self:_getIntervalData(timePoint, ...)
	timePoint.intervalTime.intervalData = intervalData
	return intervalData
end
function DynamicLayerData:_removeIntervalData(timePoint)
	return self:removeTimingObject(timePoint, "intervalData")
end
function DynamicLayerData:removeIntervalData(absoluteTime)
	local timePoint = self:getTimePoint(IntervalTime:new(absoluteTime, Fraction:new(0)))
	return self:_removeIntervalData(timePoint)
end
function DynamicLayerData:splitInterval(timePoint)
	local intervalTime = timePoint.intervalTime
	local _intervalData = timePoint.intervalData

	local t = intervalTime.time:tonumber()
	if t == 0 or t % 1 ~= 0 then
		return _intervalData
	end

	local intervalData
	local tp, dir
	if t > 0 then
		local intervals = _intervalData.next and _intervalData.intervals - t or 1
		if timePoint.ptr == self.dynamicTimePoint.ptr then
			intervalData = self:getIntervalData(timePoint.absoluteTime, intervals)
		else
			timePoint.readonly = true
			intervalData = self:_getIntervalData(timePoint, intervals)
			timePoint.intervalData = intervalData
			timePoint.intervalTime.intervalData = intervalData
			timePoint.intervalTime.time = Fraction:new(0)
		end
		_intervalData.intervals = t

		tp = intervalData.timePoint.next
		dir = "next"
	else
		if timePoint.ptr == self.dynamicTimePoint.ptr then
			intervalData = self:getIntervalData(timePoint.absoluteTime, -t)
		else
			intervalData = self:_getIntervalData(timePoint, -t)
		end
		tp = _intervalData.timePoint.prev
		dir = "prev"
	end
	while tp and tp.intervalTime.time:tonumber() ~= 0 do
		if tp.intervalTime.intervalData == _intervalData then
			tp.intervalData = intervalData
			tp.intervalTime.intervalData = intervalData
			tp.intervalTime.time = tp.intervalTime.time - t
		end
		tp = tp[dir]
	end

	self:compute()
	return intervalData
end
function DynamicLayerData:mergeInterval(timePoint)
	local _intervalData = timePoint._intervalData
	if not _intervalData or self.intervalDatasRange.count == 2 then
		return
	end

	timePoint.readonly = false

	local _prev, _next = _intervalData.prev, _intervalData.next

	local t = _prev and _prev.intervals
	local merged = _prev
	local tp = timePoint
	local dir, check0 = "next", true
	if _prev and _next then
		_prev.intervals = t + _intervalData.intervals
	elseif _prev then
		_prev.intervals = 1
	elseif _next then
		t = -_intervalData.intervals
		tp = _next.timePoint
		merged = _next
		dir = "prev"
		check0 = false
	end
	repeat
		if tp.intervalTime.intervalData == _intervalData then
			tp.intervalData = merged
			tp.intervalTime.intervalData = merged
			tp.intervalTime.time = tp.intervalTime.time + t
		end
		tp = tp[dir]
	until not tp or (check0 and tp.intervalTime.time:tonumber() == 0)

	self:_removeIntervalData(timePoint)
end
function DynamicLayerData:moveInterval(intervalData, absoluteTime)
	if intervalData.timePoint.absoluteTime == absoluteTime then
		return
	end
	local minTime, maxTime = -math.huge, math.huge
	if intervalData.prev then
		minTime = intervalData.prev.timePoint.absoluteTime + self.minimumBeatLength * intervalData.prev.intervals
	end
	if intervalData.next then
		maxTime = intervalData.next.timePoint.absoluteTime - self.minimumBeatLength * intervalData.intervals
	end
	intervalData.timePoint.absoluteTime = math.min(math.max(absoluteTime, minTime), maxTime)
	self:compute()
end
function DynamicLayerData:updateInterval(intervalData, intervals)
	if not intervals or intervals == intervalData.intervals or not intervalData.next then
		return
	end
	local maxIntervals = (intervalData.next.timePoint.absoluteTime - intervalData.timePoint.absoluteTime) / self.minimumBeatLength
	intervals = math.min(math.max(intervals, 1), math.floor(maxIntervals))
	if intervals < intervalData.intervals then
		local rightTimePoint = intervalData.next.timePoint
		local tp = rightTimePoint.prev
		while tp and tp.intervalTime.time:tonumber() >= intervals do
			self.timePointsRange:remove(tp)
			tp = rightTimePoint.prev
		end
	end
	intervalData.intervals = intervals
	self:compute()
end

function DynamicLayerData:getNoteData(timePoint, inputType, inputIndex)
	local dtp = self.dynamicTimePoint
	if timePoint.ptr == dtp.ptr then
		timePoint = self:getTimePoint(dtp:getTime(), dtp.side, dtp.visualSide)
	end

	local noteData = NoteData:new(timePoint, inputType, inputIndex)
	timePoint.noteDatas = timePoint.noteDatas or {}
	local noteDatas = noteData.timePoint.noteDatas
	for _, _noteData in ipairs(noteDatas) do
		if _noteData.inputType == inputType and _noteData.inputIndex == inputIndex then
			return
		end
	end

	table.insert(noteDatas, noteData)

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
