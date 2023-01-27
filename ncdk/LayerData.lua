local Fraction = require("ncdk.Fraction")
local TimePoint = require("ncdk.TimePoint")
local TempoData = require("ncdk.TempoData")
local SignatureData = require("ncdk.SignatureData")
local StopData = require("ncdk.StopData")
local VelocityData = require("ncdk.VelocityData")
local ExpandData = require("ncdk.ExpandData")
local IntervalData = require("ncdk.IntervalData")
local AbsoluteTimePoint = require("ncdk.AbsoluteTimePoint")
local IntervalTimePoint = require("ncdk.IntervalTimePoint")
local MeasureTimePoint = require("ncdk.MeasureTimePoint")
local NoteData = require("ncdk.NoteData")

local LayerData = {}

LayerData.primaryTempo = 0

local mt = {__index = LayerData}

function LayerData:new()
	local layerData = {}

	layerData.defaultSignature = Fraction:new(4)
	layerData.signatures = {}
	layerData.signatureDatas = {}
	layerData.timePoints = {}
	layerData.tempoDatas = {}
	layerData.stopDatas = {}
	layerData.velocityDatas = {}
	layerData.expandDatas = {}
	layerData.intervalDatas = {}
	layerData.noteDatas = {}

	return setmetatable(layerData, mt)
end

function LayerData:compute()
	table.sort(self.tempoDatas)
	table.sort(self.stopDatas)
	table.sort(self.velocityDatas)
	table.sort(self.intervalDatas)
	table.sort(self.noteDatas)

	-- for _, r in pairs(self.noteDatas) do
	-- 	for _, noteDatas in pairs(r) do
	-- 		table.sort(noteDatas)
	-- 	end
	-- end

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
	self.zeroTimePoint = self:getTimePoint(time)
end

function LayerData:setSignatureMode(mode)
	assert(mode == "long" or mode == "short", "Wrong signature mode")
	self.signatureMode = mode
end

function LayerData:setPrimaryTempo(tempo)
	assert(tempo >= 0, "Wrong primary tempo")
	self.primaryTempo = tempo
end

function LayerData:newTimePoint()
	local mode = assert(self.mode, "Mode should be set")
	if mode == "absolute" then
		return AbsoluteTimePoint:new()
	elseif mode == "measure" then
		return MeasureTimePoint:new()
	elseif mode == "interval" then
		return IntervalTimePoint:new()
	end
end

function LayerData:getTimePoint(...)
	self.testTimePoint = self.testTimePoint or self:newTimePoint()
	self.testTimePoint:setTime(...)

	local timePoints = self.timePoints
	local key = tostring(self.testTimePoint)
	local timePoint = timePoints[key]
	if timePoint then
		return timePoint
	end

	timePoint = self:newTimePoint()
	timePoint:setTime(...)
	timePoints[key] = timePoint

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

function LayerData:getBaseTimePoint(index, t, mode)
	local list = self.timePointList
	index = math.min(math.max(index, 1), #list)

	local timePoint = list[index]
	if t == timePoint or t:compare(timePoint, mode) and index == 1 then
		-- skip
	elseif timePoint:compare(t, mode) then  -- t > timePoint
		local nextTimePoint = list[index + 1]
		while nextTimePoint do
			if not t:compare(nextTimePoint, mode) then  -- t >= nextTimePoint
				index = index + 1
				nextTimePoint = list[index + 1]
			else
				break
			end
		end
	elseif t:compare(timePoint, mode) then
		index = index - 1
		local prevTimePoint = list[index]
		while prevTimePoint do
			if t:compare(prevTimePoint, mode) then
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
	index = self:getBaseTimePoint(index, timePoint, "absolute")

	local list = self.timePointList

	local a = list[index]
	local b = list[index + 1]
	a = a or b

	local tempoMultiplier = self.primaryTempo == 0 and 1 or a.tempoData.tempo / self.primaryTempo
	if b and b._stopData then
		tempoMultiplier = 0
	end

	local t = timePoint.absoluteTime
	local currentSpeed = a.velocityData and a.velocityData.currentSpeed or 1
	timePoint.visualTime = a.visualTime + (t - a.absoluteTime) * currentSpeed * tempoMultiplier
	timePoint.visualSection = a.visualSection

	timePoint.tempoData = a.tempoData
	timePoint.velocityData = a.velocityData

	return index
end

function LayerData:interpolateTimePointVisual(index, timePoint)
	index = self:getBaseTimePoint(index, timePoint, "visual")

	local list = self.timePointList

	local a = list[index]
	local b = list[index + 1]
	a = a or b

	local t = timePoint.visualTime
	local tempoMultiplier = self.primaryTempo == 0 and 1 or a.tempoData.tempo / self.primaryTempo
	local currentSpeed = a.velocityData and a.velocityData.currentSpeed or 1
	timePoint.absoluteTime = a.absoluteTime + (t - a.visualTime) / currentSpeed / tempoMultiplier
	timePoint.visualSection = a.visualSection

	timePoint.tempoData = a.tempoData
	timePoint.velocityData = a.velocityData

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
	local visualSection = 0
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
			if timePoint._intervalData then
				intervalData = timePoint._intervalData
			end
			time = timePoint:tonumber()
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

			timePoint.beatTime = beatTime
			timePoint.absoluteTime = time
			timePoint.visualTime = visualTime
			timePoint.visualSection = visualSection

			timePointIndex = timePointIndex + 1
			timePoint = timePointList[timePointIndex]
		end
	end

	local zeroTimePoint = self.zeroTimePoint
	if not zeroTimePoint then
		zeroTimePoint = self:newTimePoint()
		zeroTimePoint.absoluteTime = 0
		zeroTimePoint.beatTime = 0
		zeroTimePoint.visualTime = 0
		zeroTimePoint.visualSection = 0
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
	local timePoint = self:getTimePoint(time, 1)
	local stopData = self:insertTimingObject(timePoint, "stopData", StopData, ...)
	stopData.leftTimePoint = self:getTimePoint(timePoint:getPrevTime())  -- for time point interpolation
	return stopData
end
function LayerData:removeStopData()
	return self:removeTimingObject("stopData")
end

function LayerData:insertVelocityData(timePoint, ...)
	return self:insertTimingObject(timePoint, "velocityData", VelocityData, ...)
end
function LayerData:removeVelocityData()
	return self:removeTimingObject("velocityData")
end

function LayerData:insertExpandData(timePoint, ...)
	local expandData = self:insertTimingObject(timePoint, "expandData", ExpandData, ...)
	expandData.leftTimePoint = self:getTimePoint(timePoint:getPrevVisualTime())  -- for time point interpolation
	return expandData
end
function LayerData:removeExpandData()
	return self:removeTimingObject("expandData")
end

function LayerData:setSignature(measureOffset, signature)
	assert(self.signatureMode, "Signature mode should be set")
	self.signatures[measureOffset] = signature
	local timePoint = self:getTimePoint(Fraction:new(measureOffset))  -- for easier conversion to DynamicLayerData
	self:getTimePoint(Fraction:new(measureOffset + 1))  -- for time point interpolation
	return self:insertTimingObject(timePoint, "signatureData", SignatureData, signature)
end
function LayerData:getSignature(measureOffset)
	return self.signatures[measureOffset]
end

function LayerData:insertIntervalData(absoluteTime, ...)
	local timePoint = self:getTimePoint(absoluteTime)
	local key = tostring(timePoint)
	local intervalData = self:insertTimingObject(timePoint, "intervalData", IntervalData, ...)
	timePoint.intervalData = intervalData
	timePoint.time = intervalData.start
	timePoint.absoluteTime = absoluteTime
	self.timePoints[key] = nil
	self.timePoints[tostring(timePoint)] = timePoint
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
	local inputType, inputIndex = noteData.inputType, noteData.inputIndex

	local noteDatas = self.noteDatas
	-- noteDatas[inputType] = noteDatas[inputType] or {}
	-- noteDatas[inputType][inputIndex] = noteDatas[inputType][inputIndex] or {}
	-- noteDatas = noteDatas[inputType][inputIndex]

	table.insert(noteDatas, noteData)
	noteData.id = #noteDatas

	local timePoint = noteData.timePoint
	timePoint.noteDatas = timePoint.noteDatas or {}
	table.insert(timePoint.noteDatas, noteData)

	self.noteChart:increaseInputCount(inputType, inputIndex, 1)
end

function LayerData:getNoteData(i) return self.noteDatas[i] end
function LayerData:getNoteDataCount() return #self.noteDatas end

return LayerData
