local Fraction = require("ncdk.Fraction")
local TimePoint = require("ncdk.TimePoint")
local TempoData = require("ncdk.TempoData")
local StopData = require("ncdk.StopData")
local VelocityData = require("ncdk.VelocityData")
local ExpandData = require("ncdk.ExpandData")
local IntervalData = require("ncdk.IntervalData")
local IntervalTime = require("ncdk.IntervalTime")

local LayerData = {}

LayerData.primaryTempo = 0

local mt = {__index = LayerData}

function LayerData:new()
	local layerData = {}

	layerData.defaultSignature = Fraction:new(4)
	layerData.signatures = {}
	layerData.timePoints = {}
	layerData.tempoDatas = {}
	layerData.stopDatas = {}
	layerData.velocityDatas = {}
	layerData.expandDatas = {}
	layerData.intervalDatas = {}
	layerData.noteDatas = {}

	return setmetatable(layerData, mt)
end

local function sortByTimePoint(a, b)
	return a.timePoint < b.timePoint
end
function LayerData:compute()
	table.sort(self.tempoDatas, sortByTimePoint)
	table.sort(self.stopDatas, sortByTimePoint)
	table.sort(self.velocityDatas, sortByTimePoint)
	table.sort(self.intervalDatas, sortByTimePoint)
	table.sort(self.noteDatas, function(a, b)
		if a.timePoint == b.timePoint then
			return a.id < b.id
		end
		return a.timePoint < b.timePoint
	end)

	local intervalDatas = self.intervalDatas
	for i = 1, #intervalDatas do
		intervalDatas[i].next = intervalDatas[i + 1]
		intervalDatas[i].prev = intervalDatas[i - 1]
	end

	self:computeTimePoints()
end

function LayerData:setTimeMode(mode)
	self.mode = mode
	local time
	if mode == "absolute" then
		time = 0
	elseif mode == "measure" then
		time = Fraction:new(0)
	elseif mode == "interval" then
		return
	else
		error("Wrong time mode")
	end
	self.zeroTimePoint = self:getTimePoint(time, -1)
end

function LayerData:setSignatureMode(mode)
	assert(mode == "long" or mode == "short", "Wrong signature mode")
	self.signatureMode = mode
end

function LayerData:setPrimaryTempo(tempo)
	assert(tempo >= 0, "Wrong primary tempo")
	self.primaryTempo = tempo
end

function LayerData:getTimePoint(time, side, visualSide)
	local mode = assert(self.mode, "Mode should be set")

	if type(time) == "number" then
		time = math.min(math.max(time, -2147483648), 2147483647)
	end

	side = side or -1
	visualSide = visualSide or -1
	local timePoints = self.timePoints
	local key = tostring(time) .. "," .. side .. "," .. visualSide
	local timePoint = timePoints[key]
	if timePoint then
		return timePoint
	end

	timePoint = TimePoint:new()
	timePoint.side = side
	timePoint.visualSide = visualSide
	timePoints[key] = timePoint

	if mode == "absolute" then
		timePoint.absoluteTime = time
	elseif mode == "measure" then
		timePoint.measureTime = time
	elseif mode == "interval" then
		timePoint.intervalTime = time
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

function LayerData:getBaseTimePoint(index, time, field)
	field = field or "absoluteTime"
	local list = self.timePointList

	local timePoint = list[index]
	if time == timePoint[field] or time < timePoint[field] and index == 1 then
		-- skip
	elseif time > timePoint[field] then
		local nextTimePoint = list[index + 1]
		while nextTimePoint do
			if time >= nextTimePoint[field] then
				index = index + 1
				nextTimePoint = list[index + 1]
			else
				break
			end
		end
	elseif time < timePoint[field] then
		index = index - 1
		local prevTimePoint = list[index]
		while prevTimePoint do
			if time < prevTimePoint[field] then
				index = index - 1
				prevTimePoint = list[index]
			else
				break
			end
		end
	end

	return math.max(index, 1)
end

function LayerData:interpolateTimePointAbsolute(index, timePoint)
	local t = timePoint.absoluteTime
	index = self:getBaseTimePoint(index, t, "absoluteTime")

	local list = self.timePointList

	local a = list[index]
	local b = list[index + 1]
	a = a or b

	local tempoMultiplier = self.primaryTempo == 0 and 1 or a.tempoData.tempo / self.primaryTempo
	if b and b._stopData then
		tempoMultiplier = 0
	end

	local currentSpeed = a.velocityData and a.velocityData.currentSpeed or 1
	timePoint.visualTime = a.visualTime + (t - a.absoluteTime) * currentSpeed * tempoMultiplier

	timePoint.tempoData = a.tempoData
	timePoint.velocityData = a.velocityData
	timePoint.intervalData = a.intervalData

	return index
end

function LayerData:interpolateTimePointVisual(index, timePoint)
	local t = timePoint.visualTime
	index = self:getBaseTimePoint(index, t, "visualTime")

	local list = self.timePointList

	local a = list[index]
	local b = list[index + 1]
	a = a or b

	local tempoMultiplier = self.primaryTempo == 0 and 1 or a.tempoData.tempo / self.primaryTempo
	local currentSpeed = a.velocityData and a.velocityData.currentSpeed or 1
	timePoint.absoluteTime = a.absoluteTime + (t - a.visualTime) / currentSpeed / tempoMultiplier

	timePoint.tempoData = a.tempoData
	timePoint.velocityData = a.velocityData
	timePoint.intervalData = a.intervalData

	return index
end

function LayerData:computeTimePoints()
	local mode = self.mode
	assert(mode, "Mode should be set")

	self:createTimePointList()

	local isMeasure = mode == "measure"
	local isInterval = mode == "interval"
	local isLong = self.signatureMode == "long"
	local timePointList = self.timePointList

	local tempoData = self:getTempoData(1)
	local velocityData = self:getVelocityData(1)
	local intervalData = self:getIntervalData(1)

	local timePointIndex = 1
	local timePoint = timePointList[timePointIndex]

	local signature = self.defaultSignature
	local primaryTempo = self.primaryTempo

	local time = 0
	local beatTime = 0
	local visualTime = 0
	local currentTime = timePoint.measureTime
	local currentAbsoluteTime = 0
	while timePoint do
		local isAtTimePoint = not isMeasure
		if isMeasure then
			local measureOffset = currentTime:floor()

			local targetTime = Fraction:new(measureOffset + 1)
			if timePoint.measureTime < targetTime then
				targetTime = timePoint.measureTime
			end
			isAtTimePoint = timePoint.measureTime == targetTime

			local defaultSignature = self.defaultSignature
			if isLong then
				defaultSignature = signature
			end
			signature = self:getSignature(measureOffset) or defaultSignature

			beatTime = beatTime + signature:tonumber() * (targetTime - currentTime)

			if tempoData then
				local duration = tempoData:getBeatDuration() * signature
				time = time + duration * (targetTime - currentTime)
			end
			currentTime = targetTime
		elseif isInterval then
			-- if timePoint._intervalData and timePoint._intervalData.next then
			-- 	intervalData = timePoint._intervalData
			-- end
			-- local nextIntervalData = intervalData.next
			-- local duration = (nextIntervalData.timePoint.absoluteTime - intervalData.timePoint.absoluteTime) / intervalData.intervals
			-- time = intervalData.timePoint.absoluteTime + duration * timePoint.intervalTime.time
			if timePoint._intervalData then
				intervalData = timePoint._intervalData
			end
			time = timePoint.intervalTime:tonumber()
		else
			time = timePoint.absoluteTime
		end

		local tempoMultiplier = (primaryTempo == 0 or not tempoData) and 1 or tempoData.tempo / primaryTempo

		if isAtTimePoint then
			local nextTempoData = timePoint._tempoData
			if nextTempoData then
				tempoData = nextTempoData
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
			timePoint.intervalData = intervalData

			timePoint.beatTime = beatTime
			timePoint.absoluteTime = time
			timePoint.visualTime = visualTime

			timePointIndex = timePointIndex + 1
			timePoint = timePointList[timePointIndex]
		end
	end

	local zeroTimePoint = self.zeroTimePoint
	if not zeroTimePoint then
		zeroTimePoint = TimePoint:new()
		zeroTimePoint.absoluteTime = 0
		zeroTimePoint.beatTime = 0
		zeroTimePoint.visualTime = 0
		self:interpolateTimePointAbsolute(1, zeroTimePoint)
	end

	local zeroBeatTime = zeroTimePoint.beatTime
	local zeroTime = zeroTimePoint.absoluteTime
	local zeroVisualTime = zeroTimePoint.visualTime

	for i, t in ipairs(timePointList) do
		t.index = i
		t.beatTime = t.beatTime - zeroBeatTime
		t.absoluteTime = t.absoluteTime - zeroTime
		t.visualTime = t.visualTime - zeroVisualTime
	end
end

function LayerData:insertTimingObject(timePoint, name, class, ...)
	local object = class:new(...)
	table.insert(self[name .. "s"], object)

	assert(not timePoint["_" .. name])
	timePoint["_" .. name] = object
	object.timePoint = timePoint

	return object
end

function LayerData:removeTimingObject(name)
	local object = table.remove(self[name .. "s"])
	local timePoint = object.timePoint

	assert(timePoint["_" .. name])
	timePoint["_" .. name] = nil
	object.timePoint = nil

	return object
end

function LayerData:insertTempoData(time, ...)
	return self:insertTimingObject(self:getTimePoint(time), "tempoData", TempoData, ...)
end
function LayerData:removeTempoData()
	return self:removeTimingObject("tempoData")
end

function LayerData:insertStopData(time, ...)
	local stopData = self:insertTimingObject(self:getTimePoint(time, 1), "stopData", StopData, ...)
	stopData.leftTimePoint = self:getTimePoint(time, -1)  -- for time point interpolation
	return stopData
end
function LayerData:removeStopData()
	return self:removeTimingObject("stopData")
end

function LayerData:insertVelocityData(time, side, ...)
	return self:insertTimingObject(self:getTimePoint(time, side), "velocityData", VelocityData, ...)
end
function LayerData:removeVelocityData()
	return self:removeTimingObject("velocityData")
end

function LayerData:insertExpandData(time, side, ...)
	local expandData = self:insertTimingObject(self:getTimePoint(time, side, 1), "expandData", ExpandData, ...)
	expandData.leftTimePoint = self:getTimePoint(time, side, -1)  -- for time point interpolation
	return expandData
end
function LayerData:removeExpandData()
	return self:removeTimingObject("expandData")
end

function LayerData:setSignature(measureOffset, signature)
	assert(self.signatureMode, "Signature mode should be set")
	self.signatures[measureOffset] = signature
end
function LayerData:getSignature(measureOffset)
	return self.signatures[measureOffset]
end

function LayerData:insertIntervalData(absoluteTime, ...)
	local timePoint = self:getTimePoint(IntervalTime:new(absoluteTime, Fraction:new(0)))
	local intervalData = self:insertTimingObject(timePoint, "intervalData", IntervalData, ...)
	timePoint.intervalTime.intervalData = intervalData
	timePoint.absoluteTime = absoluteTime
	return intervalData
end
function LayerData:removeIntervalData()
	return self:removeTimingObject("intervalData")
end

function LayerData:getTempoData(i) return self.tempoDatas[i] end
function LayerData:getTempoDataCount() return #self.tempoDatas end

function LayerData:getStopData(i) return self.stopDatas[i] end
function LayerData:getStopDataCount() return #self.stopDatas end

function LayerData:getVelocityData(i) return self.velocityDatas[i] end
function LayerData:getVelocityDataCount() return #self.velocityDatas end

function LayerData:getExpandData(i) return self.expandDatas[i] end
function LayerData:getExpandDataCount() return #self.expandDatas end

function LayerData:getIntervalData(i) return self.intervalDatas[i] end
function LayerData:getIntervalDataCount() return #self.intervalDatas end

function LayerData:addNoteData(noteData)
	local noteDatas = self.noteDatas
	table.insert(noteDatas, noteData)
	noteData.id = #noteDatas

	self.noteChart:increaseInputCount(noteData.inputType, noteData.inputIndex, 1)
end

function LayerData:getNoteData(i) return self.noteDatas[i] end
function LayerData:getNoteDataCount() return #self.noteDatas end

return LayerData
