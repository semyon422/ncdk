local VelocityData = require("ncdk.VelocityData")
local ExpandData = require("ncdk.ExpandData")
local IntervalData = require("ncdk.IntervalData")
local MeasureData = require("ncdk.MeasureData")
local NoteData = require("ncdk.NoteData")
local RangeTracker = require("ncdk.RangeTracker")
local IntervalTimePoint = require("ncdk.IntervalTimePoint")

local DynamicLayerData = {}

DynamicLayerData.primaryTempo = 0
DynamicLayerData.minBeatDuration = 60 / 1000

local mt = {__index = DynamicLayerData}
function DynamicLayerData:new(ld)
	local layerData = setmetatable({}, mt)

	layerData:init()
	if ld then
		layerData:load(ld)
	end

	return layerData
end

local rangeNames = {"timePoint", "velocity", "expand", "interval", "measure"}
function DynamicLayerData:init()
	local function getTime(_, object)
		if object.timePoint then
			object = object.timePoint
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

	self:_setRange(0, 0)
	self.startTime, self.endTime = 0, 0
	self.dynamicTimePoint = self:newTimePoint()
	self.searchTimePoint = self:newTimePoint()
end

function DynamicLayerData:isValid()
	local ranges = self.ranges
	for _, name in ipairs(rangeNames) do
		if not ranges[name]:isValid() then
			return false, name
		end
	end

	for inputType, d in pairs(ranges.note) do
		for inputIndex, range in pairs(d) do
			if not range:isValid() then
				return false, inputType .. inputIndex
			end
		end
	end

	return true
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
	assert(layerData.mode == "interval", "only interval mode supported")

	local ranges = self.ranges
	ranges.timePoint:fromList(layerData.timePointList)
	ranges.velocity:fromList(layerData.velocityDatas)
	ranges.expand:fromList(layerData.expandDatas)
	ranges.interval:fromList(layerData.intervalDatas)
	ranges.measure:fromList(layerData.measureDatas)

	for inputType, r in pairs(layerData.noteDatas) do
		for inputIndex, noteDatas in pairs(r) do
			local range = self:getNoteRange(inputType, inputIndex)
			range:fromList(noteDatas)
		end
	end
end

function DynamicLayerData:save(layerData)
	local ranges = self.ranges
	layerData.timePointList = ranges.timePoint:toList()
	layerData.velocityDatas = ranges.velocity:toList()
	layerData.expandDatas = ranges.expand:toList()
	layerData.intervalDatas = ranges.interval:toList()
	layerData.measureDatas = ranges.measure:toList()

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

	layerData.mode = "interval"
end

function DynamicLayerData:setPrimaryTempo(tempo)
	assert(tempo >= 0, "Wrong primary tempo")
	self.primaryTempo = tempo
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

function DynamicLayerData:syncChanges(offset)
	for _, name in ipairs(rangeNames) do
		self.ranges[name]:syncChanges(offset)
	end
	for _, r in pairs(self.ranges.note) do
		for _, range in pairs(r) do
			range:syncChanges(offset)
		end
	end
end

function DynamicLayerData:resetRedos()
	for _, name in ipairs(rangeNames) do
		self.ranges[name]:resetRedos()
	end
	for _, r in pairs(self.ranges.note) do
		for _, range in pairs(r) do
			range:resetRedos()
		end
	end
end

function DynamicLayerData:newTimePoint()
	return IntervalTimePoint:new()
end

local function map(x, a, b, c, d)
	return (x - a) * (d - c) / (b - a) + c
end

function DynamicLayerData:resetDynamicTimePoint()
	local timePoint = self.dynamicTimePoint
	local ptr = timePoint.ptr
	for k in pairs(timePoint) do
		timePoint[k] = nil
	end
	timePoint.ptr = ptr
end

function DynamicLayerData:getDynamicTimePoint(...)
	local timePoint = self.dynamicTimePoint

	self:resetDynamicTimePoint()
	timePoint:setTime(...)

	local t = timePoint:tonumber()

	local a, b = self.ranges.timePoint:getInterp(timePoint)
	timePoint.prev = a
	timePoint.next = b

	if not a and not b then
		return
	elseif a == b then
		return a
	elseif a and b then
		local ta, tb = a:tonumber(), b:tonumber()
		timePoint.absoluteTime = map(t, ta, tb, a.absoluteTime, b.absoluteTime)
		timePoint.visualTime = map(t, ta, tb, a.visualTime, b.visualTime)
	else
		a = a or b

		local intervalData, nextIntervalData = a.intervalData:getPair()
		local tempoMultiplier = self.primaryTempo == 0 and 1 or intervalData:getTempo() / self.primaryTempo

		local _a, _b = intervalData.timePoint, nextIntervalData.timePoint
		local ta, tb = _a:tonumber(), _b:tonumber()
		timePoint.absoluteTime = map(t, ta, tb, _a.absoluteTime, _b.absoluteTime)

		local currentSpeed = a.velocityData and a.velocityData.currentSpeed or 1
		timePoint.visualTime = a.visualTime + (timePoint.absoluteTime - a.absoluteTime) * currentSpeed * tempoMultiplier
	end

	timePoint.velocityData = a.velocityData
	timePoint.intervalData = timePoint.intervalData or a.intervalData
	timePoint.visualSection = a.visualSection
	timePoint.measureData = a.measureData

	return timePoint
end

function DynamicLayerData:getDynamicTimePointAbsolute(limit, absoluteTime, visualSide)
	assert(limit)

	local timePoint = self.dynamicTimePoint

	self:resetDynamicTimePoint()
	timePoint:setTimeAbsolute(absoluteTime, visualSide)

	local t = absoluteTime

	local a, b = self.ranges.timePoint:getInterp(timePoint)
	timePoint.prev = a
	timePoint.next = b

	if not a and not b then
		return
	elseif a == b then
		return a
	elseif a and b then
		timePoint:fromnumber(a.intervalData, t, limit, a.measureData, true)
		timePoint.visualTime = map(t, a.absoluteTime, b.absoluteTime, a.visualTime, b.visualTime)
	else
		a = a or b

		local intervalData, nextIntervalData = a.intervalData:getPair()
		local tempoMultiplier = self.primaryTempo == 0 and 1 or intervalData:getTempo() / self.primaryTempo

		timePoint:fromnumber(a.intervalData, t, limit, a.measureData, true)

		local currentSpeed = a.velocityData and a.velocityData.currentSpeed or 1
		timePoint.visualTime = a.visualTime + (t - a.absoluteTime) * currentSpeed * tempoMultiplier
	end

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
	local timePoint = self.searchTimePoint
	timePoint:setTime(...)

	local t = self.ranges.timePoint:find(timePoint)
	if t then
		return t
	end

	timePoint = self:newTimePoint()
	timePoint:setTime(...)

	self.ranges.timePoint:insert(timePoint)
	self:compute()

	return timePoint
end

function DynamicLayerData:compute()
	local ranges = self.ranges
	local velocityData = ranges.velocity.head
	local measureData = ranges.measure.head

	local intervalData = ranges.interval.head
	if not intervalData then
		return
	end
	if not intervalData.next and intervalData.prev then
		intervalData = intervalData.prev
	end

	local timePoint = ranges.timePoint.head
	local endTimePoint = ranges.timePoint.tail

	if not timePoint then
		return
	end

	local primaryTempo = self.primaryTempo

	-- start with prev time point to be not affected by stops and expands
	local prevTimePoint = timePoint.prev or timePoint
	local time = prevTimePoint.absoluteTime or 0
	local visualTime = prevTimePoint.visualTime or 0
	local visualSection = prevTimePoint.visualSection or 0
	local currentAbsoluteTime = time
	while timePoint and timePoint <= endTimePoint do
		if timePoint._intervalData then
			intervalData = timePoint._intervalData
		end
		if timePoint._measureData then
			measureData = timePoint._measureData
		end
		time = timePoint:tonumber()

		local tempoMultiplier = primaryTempo == 0 and 1 or intervalData:getTempo() / primaryTempo

		local currentSpeed = velocityData and velocityData.currentSpeed or 1
		visualTime = visualTime + (time - currentAbsoluteTime) * currentSpeed * tempoMultiplier
		currentAbsoluteTime = time

		local nextVelocityData = timePoint._velocityData
		if nextVelocityData then
			velocityData = nextVelocityData
		end
		currentSpeed = velocityData and velocityData.currentSpeed or 1

		local expandData = timePoint._expandData
		if expandData then
			local duration = intervalData:getBeatDuration() * expandData.duration * currentSpeed
			if math.abs(duration) == math.huge then
				visualSection = visualSection + 1
			else
				visualTime = visualTime + duration
			end
		end

		timePoint.velocityData = velocityData
		timePoint.measureData = measureData

		if not timePoint.readonly then
			timePoint.absoluteTime = time
		end
		timePoint.visualTime = visualTime
		timePoint.visualSection = visualSection

		timePoint = timePoint.next
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
