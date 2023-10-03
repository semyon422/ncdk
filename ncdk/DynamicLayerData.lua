local class = require("class")
local VelocityData = require("ncdk.VelocityData")
local ExpandData = require("ncdk.ExpandData")
local IntervalData = require("ncdk.IntervalData")
local MeasureData = require("ncdk.MeasureData")
local NoteData = require("ncdk.NoteData")
local RangeTracker = require("ncdk.RangeTracker")
local LineSection = require("ncdk.LineSection")
local IntervalTimePoint = require("ncdk.IntervalTimePoint")

---@class ncdk.DynamicLayerData
---@operator call: ncdk.DynamicLayerData
local DynamicLayerData = class()

DynamicLayerData.primaryTempo = 0
DynamicLayerData.minBeatDuration = 60 / 1000

---@param ld ncdk.LayerData?
function DynamicLayerData:new(ld)
	self:init()
	if ld then
		self:load(ld)
	end
end

local rangeNames = {"timePoint", "velocity", "expand", "interval", "measure"}
function DynamicLayerData:init()
	local function getTime(object)
		if object.timePoint then
			object = object.timePoint
		end
		return object.absoluteTime
	end
	self.getTime = getTime

	local ranges = {}
	self.ranges = ranges
	self.changeOffset = 0  -- use global changeOffset because of sync bug when creating new ranges after some changes

	local function getChangeOffset()
		return self.changeOffset
	end
	self.getChangeOffset = getChangeOffset

	for _, name in ipairs(rangeNames) do
		local range = RangeTracker()
		ranges[name] = range
		range.getTime = getTime
		range.getChangeOffset = getChangeOffset
		range.noHistory = true
	end

	ranges.note = {}

	self:_setRange(0, 0)
	self.startTime, self.endTime = 0, 0
	self.dynamicTimePoint = self:newTimePoint()
	self.searchTimePoint = self:newTimePoint()

	self.uncomputedSection = LineSection()
end

function DynamicLayerData:uncompute()
	local a = self.ranges.timePoint.first
	local b = self.ranges.timePoint.last
	if not a then return end
	self.uncomputedSection:add(a:tonumber(), b:tonumber())
end

---@return boolean
---@return string?
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

---@param inputType string
---@param inputIndex number
---@return ncdk.RangeTracker
function DynamicLayerData:getNoteRange(inputType, inputIndex)
	local ranges = self.ranges.note
	ranges[inputType] = ranges[inputType] or {}
	local range = ranges[inputType][inputIndex]
	if not range then
		range = RangeTracker()
		ranges[inputType][inputIndex] = range
		range.getTime = self.getTime
		range.getChangeOffset = self.getChangeOffset
		range:setRange(self.startTime, self.endTime)
	end
	return range
end

---@param layerData ncdk.LayerData
function DynamicLayerData:load(layerData)
	assert(layerData.mode == "interval", "only interval mode supported")

	local ranges = self.ranges
	ranges.timePoint:fromList(layerData.timePointList)
	ranges.velocity:fromList(layerData.velocityDatas)
	ranges.expand:fromList(layerData.expandDatas)
	ranges.interval:fromList(layerData.intervalDatas)
	ranges.measure:fromList(layerData.measureDatas)

	ranges.note = {}
	for inputType, r in pairs(layerData.noteDatas) do
		for inputIndex, noteDatas in pairs(r) do
			local range = self:getNoteRange(inputType, inputIndex)
			range:fromList(noteDatas)
		end
	end

	self:uncompute()
end

---@param layerData ncdk.LayerData
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

	layerData.noteDatas = {}
	for inputType, r in pairs(ranges.note) do
		layerData.noteDatas[inputType] = {}
		for inputIndex, range in pairs(r) do
			layerData.noteDatas[inputType][inputIndex] = range:toList()
		end
	end

	layerData.mode = "interval"
end

---@param tempo number
function DynamicLayerData:setPrimaryTempo(tempo)
	assert(tempo >= 0, "Wrong primary tempo")
	self.primaryTempo = tempo
	self.uncomputedSection:add(self.ranges.timePoint.first:tonumber(), self.ranges.timePoint.last:tonumber())
	self:compute()
end

---@param startTime number
---@param endTime number
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

---@param startTime number
---@param endTime number
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

---@param offset number
function DynamicLayerData:syncChanges(offset)
	self.changeOffset = offset
	for _, name in ipairs(rangeNames) do
		self.ranges[name]:syncChanges()
	end
	for _, r in pairs(self.ranges.note) do
		for _, range in pairs(r) do
			range:syncChanges()
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

function DynamicLayerData:resetChanges()
	for _, name in ipairs(rangeNames) do
		self.ranges[name]:resetChanges()
	end
	for _, r in pairs(self.ranges.note) do
		for _, range in pairs(r) do
			range:resetChanges()
		end
	end
end

---@return ncdk.IntervalTimePoint
function DynamicLayerData:newTimePoint()
	return IntervalTimePoint()
end

---@param x number
---@param a number
---@param b number
---@param c number
---@param d number
---@return number
local function map(x, a, b, c, d)
	return (x - a) * (d - c) / (b - a) + c
end

function DynamicLayerData:resetDynamicTimePoint()
	local timePoint = self.dynamicTimePoint
	for k in pairs(timePoint) do
		timePoint[k] = nil
	end
end

---@param intervalData ncdk.IntervalData
---@param time ncdk.Fraction
---@param visualSide number?
---@return ncdk.IntervalTimePoint?
function DynamicLayerData:getDynamicTimePoint(intervalData, time, visualSide)
	local timePoint = self.dynamicTimePoint

	self:resetDynamicTimePoint()
	timePoint:setTime(intervalData, time, visualSide)

	local t = timePoint:tonumber()

	local a, b = self.ranges.timePoint:getInterp(timePoint)
	if not a and not b then
		return
	elseif a == b then
		return a:clone(timePoint)
	end

	timePoint.prev = a
	timePoint.next = b

	if a and b then
		local ta, tb = a.absoluteTime, b.absoluteTime
		timePoint.absoluteTime = map(t, ta, tb, a.absoluteTime, b.absoluteTime)
		timePoint.visualTime = map(t, ta, tb, a.visualTime, b.visualTime)
	else
		a = a or b

		local intervalData, nextIntervalData = a.intervalData:getPair()
		local tempoMultiplier = self.primaryTempo == 0 and 1 or intervalData:getTempo() / self.primaryTempo

		local _a, _b = intervalData.timePoint, nextIntervalData.timePoint
		local ta, tb = _a.absoluteTime, _b.absoluteTime
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

---@param limit number
---@param absoluteTime number
---@param visualSide number?
---@return ncdk.IntervalTimePoint?
function DynamicLayerData:getDynamicTimePointAbsolute(limit, absoluteTime, visualSide)
	assert(limit)

	local timePoint = self.dynamicTimePoint

	self:resetDynamicTimePoint()
	timePoint:setTimeAbsolute(absoluteTime, visualSide)

	local t = absoluteTime

	local a, b = self.ranges.timePoint:getInterp(timePoint)
	if not a and not b then
		return
	elseif a == b then
		a:clone(timePoint)
		timePoint.absoluteTime = absoluteTime
		return timePoint
	end

	timePoint.prev = a
	timePoint.next = b

	if a and b then
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

	if timePoint == a then
		a:clone(timePoint)
		timePoint.absoluteTime = absoluteTime
		return timePoint
	end
	if timePoint == b then
		b:clone(timePoint)
		timePoint.absoluteTime = absoluteTime
		return timePoint
	end

	timePoint.velocityData = a.velocityData
	timePoint.intervalData = timePoint.intervalData or a.intervalData
	timePoint.visualSection = a.visualSection
	timePoint.measureData = a.measureData

	return timePoint
end

---@param timePoint ncdk.IntervalTimePoint
---@return ncdk.IntervalTimePoint
function DynamicLayerData:checkTimePoint(timePoint)
	local dtp = self.dynamicTimePoint
	if rawequal(timePoint, dtp) then
		timePoint = self:getTimePoint(dtp:getTime())
	end
	return timePoint
end

---@param ... any?
---@return ncdk.IntervalTimePoint
function DynamicLayerData:getTimePoint(...)
	local timePoint = self.searchTimePoint
	timePoint:setTime(...)

	local t = self.ranges.timePoint:find(timePoint)
	if t then
		return t
	end

	timePoint = self:newTimePoint()
	timePoint:setTime(...)
	timePoint.absoluteTime = timePoint:tonumber()

	self.ranges.timePoint:insert(timePoint)
	self:uncompute()
	self:compute()

	return timePoint
end

function DynamicLayerData:compute()
	local ranges = self.ranges

	local timePoint = ranges.timePoint.head
	local endTimePoint = ranges.timePoint.tail

	if not timePoint then
		return
	end

	local a, b = timePoint:tonumber(), endTimePoint:tonumber()
	if not self.uncomputedSection:over(a, b, true) then
		return
	end
	local sections = self.uncomputedSection:intersect(a, b)
	self.uncomputedSection:sub(a, b)

	for i = 1, #sections, 2 do
		self:computeByTime(sections[i], sections[i + 1])
	end

	self:_setRange(self.startTime, self.endTime)
end

---@param startTime number
---@param endTime number
function DynamicLayerData:computeByTime(startTime, endTime)
	self:_setRange(startTime, endTime)

	local ranges = self.ranges
	local velocityData = ranges.velocity.head
	local measureData = ranges.measure.head

	local timePoint = ranges.timePoint.head
	local endTimePoint = ranges.timePoint.tail

	if not timePoint then
		return
	end

	local primaryTempo = self.primaryTempo

	-- start with prev time point to be not affected by stops and expands
	local prevTimePoint = timePoint.prev or timePoint
	local visualTime = prevTimePoint.visualTime or 0
	local visualSection = prevTimePoint.visualSection or 0
	local currentAbsoluteTime = prevTimePoint.absoluteTime or 0
	while timePoint and timePoint <= endTimePoint do
		if timePoint._measureData then
			measureData = timePoint._measureData
		end
		local time = timePoint:tonumber()

		local tempoMultiplier = primaryTempo == 0 and 1 or timePoint.intervalData:getTempo() / primaryTempo

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
			local duration = timePoint.intervalData:getBeatDuration() * expandData.duration * currentSpeed
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

---@param timePoint ncdk.IntervalTimePoint
---@param name string
---@param class table
---@param ... any?
---@return table
function DynamicLayerData:getTimingObject(timePoint, name, class, ...)
	local key = "_" .. name .. "Data"
	local object = timePoint[key]
	if object then
		if select("#", ...) > 0 and object:set(...) then
			self:compute()
		end
		return object
	end

	object = class(...)

	timePoint[key] = object
	object.timePoint = timePoint

	self.ranges[name]:insert(object)

	self:uncompute()
	self:compute()

	return object
end

---@param timePoint ncdk.IntervalTimePoint
---@param name string
function DynamicLayerData:removeTimingObject(timePoint, name)
	local key = "_" .. name .. "Data"
	local object = timePoint[key]
	if not object then
		return
	end

	self.ranges[name]:remove(object)

	timePoint[key] = nil
	object.timePoint = nil

	self:uncompute()
	self:compute()
end

---@param timePoint ncdk.IntervalTimePoint
---@param ... any?
---@return ncdk.VelocityData
function DynamicLayerData:getVelocityData(timePoint, ...)
	timePoint = self:checkTimePoint(timePoint)
	return self:getTimingObject(timePoint, "velocity", VelocityData, ...)
end

---@param timePoint ncdk.IntervalTimePoint
function DynamicLayerData:removeVelocityData(timePoint)
	self:removeTimingObject(timePoint, "velocity")
end

---@param timePoint ncdk.IntervalTimePoint
---@param ... any?
---@return ncdk.ExpandData
function DynamicLayerData:getExpandData(timePoint, ...)
	timePoint = self:checkTimePoint(timePoint)
	local expandData = self:getTimingObject(timePoint, "expand", ExpandData, ...)
	expandData.leftTimePoint = self:getTimePoint(timePoint:getPrevVisualTime())  -- for time point interpolation
	return expandData
end

---@param timePoint ncdk.IntervalTimePoint
function DynamicLayerData:removeExpandData(timePoint)
	self:removeTimingObject(timePoint, "expand")
end

---@param timePoint ncdk.IntervalTimePoint
---@param ... any?
---@return ncdk.IntervalData
function DynamicLayerData:_getIntervalData(timePoint, ...)
	return self:getTimingObject(timePoint, "interval", IntervalData, ...)
end

---@param absoluteTime number
---@param beats number
---@param start ncdk.Fraction?
---@return ncdk.IntervalData
function DynamicLayerData:getIntervalData(absoluteTime, beats, start)
	local timePoint = self:getTimePoint(absoluteTime)
	timePoint.absoluteTime = absoluteTime
	timePoint.readonly = true
	local intervalData = self:_getIntervalData(timePoint, beats)
	timePoint.intervalData = intervalData
	timePoint.time = start
	return intervalData
end

---@param timePoint ncdk.IntervalTimePoint
function DynamicLayerData:_removeIntervalData(timePoint)
	self:removeTimingObject(timePoint, "interval")
end

---@param absoluteTime number
function DynamicLayerData:removeIntervalData(absoluteTime)
	local timePoint = self:getTimePoint(absoluteTime)
	self:_removeIntervalData(timePoint)
end

---@param timePoint ncdk.IntervalTimePoint
---@return ncdk.IntervalData
function DynamicLayerData:splitInterval(timePoint)
	timePoint = self:checkTimePoint(timePoint)
	local _intervalData = timePoint.intervalData

	local time = timePoint.time
	local _beats = time:floor()

	local intervalData
	local tp, dir
	if time[1] > 0 then
		local beats = _intervalData.next and _intervalData.beats - _beats or 1
		timePoint.readonly = true
		intervalData = self:_getIntervalData(timePoint, beats)
		timePoint:setTime(intervalData, time % 1)
		_intervalData.beats = _beats

		tp = timePoint.next
		dir = "next"
	else
		intervalData = self:_getIntervalData(timePoint, -_beats)
		intervalData.timePoint:setTime(_intervalData, time)
		tp = _intervalData.timePoint.prev
		dir = "prev"
	end
	while tp and tp.intervalData == _intervalData do
		tp.intervalData = intervalData
		tp.time = tp.time - _beats
		tp = tp[dir]
	end

	self:uncompute()
	self:compute()
	return intervalData
end

---@param timePoint ncdk.IntervalTimePoint
function DynamicLayerData:mergeInterval(timePoint)
	local _intervalData = timePoint._intervalData
	if not _intervalData or self.ranges.interval.tree.size == 2 then
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

	self:uncompute()
	self:compute()
end

---@param intervalData ncdk.IntervalData
---@param absoluteTime number
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
	self:uncompute()
	self:compute()
end

---@param intervalData ncdk.IntervalData
---@param beats number
function DynamicLayerData:updateInterval(intervalData, beats)
	local a, b = intervalData, intervalData.next
	if not b then
		return
	end

	assert(math.floor(beats) == beats)
	beats = math.max(beats, a:start() >= b:start() and 1 or 0)

	if beats == a.beats then
		return
	end

	local _a, _b = a.timePoint, b.timePoint

	local maxBeats = (_b.absoluteTime - _a.absoluteTime) / self.minBeatDuration + a:start() - b:start()
	beats = math.min(beats, math.floor(maxBeats))

	if beats < intervalData.beats then
		local rightTimePoint = b.timePoint
		local tp = rightTimePoint.prev
		while tp and tp ~= _a and tp.time >= b:start() + beats do
			self:removeTimePoint(tp)
			tp = rightTimePoint.prev
		end
	end
	intervalData.beats = beats
	self:uncompute()
	self:compute()
end

---@param timePoint ncdk.IntervalTimePoint
function DynamicLayerData:removeTimePoint(timePoint)
	self.ranges.timePoint:remove(timePoint)
	self:removeTimingObject(timePoint, "measure")
	self:removeTimingObject(timePoint, "interval")
	self:removeTimingObject(timePoint, "expand")
	self:removeTimingObject(timePoint, "velocity")

	local function ex(key)
		return key.timePoint
	end

	for _, r in pairs(self.ranges.note) do
		for _, range in pairs(r) do
			local node = range.tree:findex(timePoint, ex)
			if node then
				local noteData = node.key
				range:remove(noteData)
				if noteData.startNoteData then
					range:remove(noteData.startNoteData)
				end
				if noteData.endNoteData then
					range:remove(noteData.endNoteData)
				end
			end
		end
	end

	self:resetChanges()
end

---@param timePoint ncdk.IntervalTimePoint
---@param ... any?
---@return ncdk.MeasureData
function DynamicLayerData:getMeasureData(timePoint, ...)
	timePoint = self:checkTimePoint(timePoint)
	return self:getTimingObject(timePoint, "measure", MeasureData, ...)
end

---@param timePoint ncdk.IntervalTimePoint
function DynamicLayerData:removeMeasureData(timePoint)
	self:removeTimingObject(timePoint, "measure")
end

---@param timePoint ncdk.IntervalTimePoint
---@param inputType string
---@param inputIndex number
---@return ncdk.NoteData
function DynamicLayerData:getNoteData(timePoint, inputType, inputIndex)
	timePoint = self:checkTimePoint(timePoint)
	local noteData = NoteData(timePoint)
	return self:addNoteData(noteData, inputType, inputIndex)
end

---@param noteData ncdk.NoteData
---@param inputType string
---@param inputIndex number
---@return ncdk.NoteData
function DynamicLayerData:addNoteData(noteData, inputType, inputIndex)
	local range = self:getNoteRange(inputType, inputIndex)
	return range:insert(noteData)
end

---@param noteData ncdk.NoteData
---@param inputType string
---@param inputIndex number
function DynamicLayerData:removeNoteData(noteData, inputType, inputIndex)
	local range = self:getNoteRange(inputType, inputIndex)
	range:remove(noteData)
end

return DynamicLayerData
