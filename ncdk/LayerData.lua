local class = require("class")
local Fraction = require("ncdk.Fraction")
local TempoData = require("ncdk.TempoData")
local SignatureData = require("ncdk.SignatureData")
local StopData = require("ncdk.StopData")
local VelocityData = require("ncdk.VelocityData")
local ExpandData = require("ncdk.ExpandData")
local IntervalData = require("ncdk.IntervalData")
local MeasureData = require("ncdk.MeasureData")
local AbsoluteTimePoint = require("ncdk.AbsoluteTimePoint")
local IntervalTimePoint = require("ncdk.IntervalTimePoint")
local MeasureTimePoint = require("ncdk.MeasureTimePoint")

---@class ncdk.LayerData
---@operator call: ncdk.LayerData
local LayerData = class()

LayerData.primaryTempo = 0
LayerData.tempoMultiplyTarget = "current"  -- "current" | "local" | "global"

local listNames = {
	"signatureDatas",
	"tempoDatas",
	"stopDatas",
	"velocityDatas",
	"expandDatas",
	"intervalDatas",
	"measureDatas",
}
function LayerData:new()
	self.defaultSignature = Fraction(4)
	self.signatures = {}
	self.timePoints = {}
	self.noteDatas = {}
	for _, name in ipairs(listNames) do
		self[name] = {}
	end
end

function LayerData:compute()
	for _, name in ipairs(listNames) do
		table.sort(self[name])
	end

	for _, r in pairs(self.noteDatas) do
		for _, noteDatas in pairs(r) do
			table.sort(noteDatas)
		end
	end

	local intervalDatas = self.intervalDatas
	for i = 1, #intervalDatas do
		intervalDatas[i].next = intervalDatas[i + 1]
		intervalDatas[i].prev = intervalDatas[i - 1]
	end

	self:computeTimePoints()
end

---@param list table
---@return boolean
local function isListValid(list)
	for i = 1, #list - 1 do
		if list[i] >= list[i + 1] then
			return false
		end
	end
	return true
end

---@return boolean
---@return string?
function LayerData:isValid()
	for _, name in ipairs(listNames) do
		if not isListValid(self[name]) then
			return false, name
		end
	end

	for inputType, r in pairs(self.noteDatas) do
		for inputIndex, noteDatas in pairs(r) do
			if not isListValid(noteDatas) then
				return false, inputType .. inputIndex
			end
		end
	end

	return true
end

---@param mode string
function LayerData:setTimeMode(mode)
	self.mode = mode
	local time
	if mode == "absolute" then
		time = 0
	elseif mode == "measure" then
		time = Fraction(0)
	elseif mode == "interval" then
		return
	else
		error("Wrong time mode")
	end
	self.zeroTimePoint = self:getTimePoint(time)
end

---@param mode string
function LayerData:setSignatureMode(mode)
	assert(mode == "long" or mode == "short", "Wrong signature mode")
	self.signatureMode = mode
end

---@param tempo number
function LayerData:setPrimaryTempo(tempo)
	assert(tempo >= 0, "Wrong primary tempo")
	self.primaryTempo = tempo
end

---@return ncdk.AbsoluteTimePoint|ncdk.MeasureTimePoint|ncdk.IntervalTimePoint
function LayerData:newTimePoint()
	local mode = assert(self.mode, "Mode should be set")
	if mode == "absolute" then
		return AbsoluteTimePoint()
	elseif mode == "measure" then
		return MeasureTimePoint()
	elseif mode == "interval" then
		return IntervalTimePoint()
	end
	error("Invalid time mode")
end

---@param ... any
---@return ncdk.TimePoint
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

---@param index number
---@param t ncdk.TimePoint
---@param mode string
---@return number
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

---@param velocityData ncdk.VelocityData?
---@param tempoMultiplier number
---@return number
---@return number
---@return number
function LayerData:getMultipliedSpeeds(velocityData, tempoMultiplier)
	local currentSpeed, localSpeed, globalSpeed = 1, 1, 1
	if velocityData then
		currentSpeed = velocityData.currentSpeed
		localSpeed = velocityData.localSpeed
		globalSpeed = velocityData.globalSpeed
	end

	if self.tempoMultiplyTarget == "current" then
		currentSpeed = currentSpeed * tempoMultiplier
	elseif self.tempoMultiplyTarget == "local" then
		localSpeed = localSpeed * tempoMultiplier
	elseif self.tempoMultiplyTarget == "global" then
		globalSpeed = globalSpeed * tempoMultiplier
	end

	return currentSpeed, localSpeed, globalSpeed
end

---@param index number
---@param timePoint ncdk.TimePoint
---@return number
function LayerData:interpolateTimePointAbsolute(index, timePoint)
	index = self:getBaseTimePoint(index, timePoint, "absolute")

	local list = self.timePointList

	local a = list[index]
	local b = list[index + 1]
	a = a or b

	local tempoMultiplier = 1
	if self.primaryTempo ~= 0 and a.tempoData then
		tempoMultiplier = a.tempoData.tempo / self.primaryTempo
	end
	if self.primaryTempo ~= 0 and b and b._stopData then
		tempoMultiplier = 0
	end

	local velocityData = a.velocityData
	local currentSpeed, localSpeed, globalSpeed =
		self:getMultipliedSpeeds(velocityData, tempoMultiplier)

	local t = timePoint.absoluteTime
	timePoint.visualTime = a.visualTime + (t - a.absoluteTime) * currentSpeed
	timePoint.visualSection = a.visualSection

	timePoint.tempoData = a.tempoData
	timePoint.velocityData = velocityData

	timePoint.currentSpeed = currentSpeed
	timePoint.localSpeed = localSpeed
	timePoint.globalSpeed = globalSpeed

	return index
end

---@param index number
---@param timePoint ncdk.TimePoint
---@return number
function LayerData:interpolateTimePointVisual(index, timePoint)
	index = self:getBaseTimePoint(index, timePoint, "visual")

	local list = self.timePointList

	local a = list[index]
	local b = list[index + 1]
	a = a or b

	local tempoMultiplier = 1
	if self.primaryTempo ~= 0 and a.tempoData then
		tempoMultiplier = a.tempoData.tempo / self.primaryTempo
	end

	local velocityData = a.velocityData
	local currentSpeed, localSpeed, globalSpeed =
		self:getMultipliedSpeeds(velocityData, tempoMultiplier)

	local t = timePoint.visualTime
	timePoint.absoluteTime = a.absoluteTime + (t - a.visualTime) / currentSpeed
	timePoint.visualSection = a.visualSection

	timePoint.tempoData = a.tempoData
	timePoint.velocityData = velocityData

	timePoint.currentSpeed = currentSpeed
	timePoint.localSpeed = localSpeed
	timePoint.globalSpeed = globalSpeed

	return index
end

function LayerData:assignNoteDatas()
	for _, timePoint in pairs(self.timePoints) do
		timePoint.noteDatas = {}
	end

	for inputType, r in pairs(self.noteDatas) do
		for inputIndex, noteDatas in pairs(r) do
			for _, noteData in ipairs(noteDatas) do
				local key = inputType .. inputIndex
				local nds = noteData.timePoint.noteDatas
				if nds[key] then
					error("can not assign NoteData, input already used: " .. key)
				end
				nds[key] = noteData
			end
		end
	end
end

function LayerData:computeTimePoints()
	local mode = self.mode
	assert(mode, "Mode should be set")

	local timePointList = {}
	for _, timePoint in pairs(self.timePoints) do
		timePointList[#timePointList + 1] = timePoint
	end
	table.sort(timePointList)
	self.timePointList = timePointList

	local isMeasure = mode == "measure"
	local isInterval = mode == "interval"
	local isLong = self.signatureMode == "long"

	local tempoData = self:getTempoData(1)
	local velocityData = self:getVelocityData(1)
	local intervalData = self:getIntervalData(1)
	local measureData = self:getMeasureData(1)

	local timePointIndex = 1
	local timePoint = timePointList[timePointIndex]

	local signature = self.defaultSignature
	local primaryTempo = self.primaryTempo

	local time = 0
	local beatTime = Fraction(0)
	local fullBeatTime = Fraction(0)
	local visualTime = 0
	local visualSection = 0
	local currentTime = timePoint.measureTime
	local currentAbsoluteTime = 0
	while timePoint do
		local isAtTimePoint = not isMeasure
		if isMeasure then
			local measureOffset = currentTime:floor()

			local targetTime = Fraction(measureOffset + 1)
			if timePoint.measureTime < targetTime then
				targetTime = timePoint.measureTime
			end
			isAtTimePoint = timePoint.measureTime == targetTime

			local defaultSignature = self.defaultSignature
			if isLong then
				defaultSignature = signature
			end
			signature = self:getSignature(measureOffset) or defaultSignature

			beatTime = beatTime + signature * (targetTime - currentTime)
			fullBeatTime = fullBeatTime + signature * (targetTime - currentTime)

			if tempoData then
				local duration = tempoData:getBeatDuration() * signature
				time = time + duration * (targetTime - currentTime)
			end
			currentTime = targetTime
		elseif isInterval then
			if timePoint._intervalData then
				intervalData = timePoint._intervalData
			end
			if timePoint._measureData then
				measureData = timePoint._measureData
			end
			time = timePoint:tonumber()
		else
			time = timePoint.absoluteTime
		end

		local tempoMultiplier = primaryTempo ~= 0 and tempoData and tempoData.tempo / primaryTempo or 1

		if isAtTimePoint then
			local nextTempoData = timePoint._tempoData
			if nextTempoData then
				tempoData = nextTempoData
			end

			local stopData = timePoint._stopData
			if stopData then
				stopData.tempoData = tempoData
				if isMeasure and tempoData then
					local duration = stopData.duration
					if not stopData.isAbsolute then
						duration = tempoData:getBeatDuration() * duration
						fullBeatTime = fullBeatTime + stopData.duration
					else
						fullBeatTime = fullBeatTime + Fraction:new(stopData.duration / tempoData:getBeatDuration(), 192, true)
					end
					time = time + duration
					if primaryTempo ~= 0 then
						tempoMultiplier = 0
					end
				end
			end
		end

		local currentSpeed, localSpeed, globalSpeed =
			self:getMultipliedSpeeds(velocityData, tempoMultiplier)

		visualTime = visualTime + (time - currentAbsoluteTime) * currentSpeed
		currentAbsoluteTime = time

		if isAtTimePoint then
			local nextVelocityData = timePoint._velocityData
			if nextVelocityData then
				velocityData = nextVelocityData
			end
			currentSpeed = self:getMultipliedSpeeds(velocityData, tempoMultiplier)

			local expandData = timePoint._expandData
			if expandData then
				local duration = expandData.duration
				if isMeasure and tempoData then
					duration = tempoData:getBeatDuration() * duration * currentSpeed
				elseif isInterval and intervalData then
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
			timePoint.measureData = measureData

			if not timePoint.readonly then
				timePoint.absoluteTime = time
			end
			timePoint.beatTime = beatTime
			timePoint.fullBeatTime = fullBeatTime
			timePoint.visualTime = visualTime
			timePoint.visualSection = visualSection
			timePoint.currentSpeed = currentSpeed
			timePoint.localSpeed = localSpeed
			timePoint.globalSpeed = globalSpeed

			timePointIndex = timePointIndex + 1
			timePoint = timePointList[timePointIndex]
		end
	end

	local zeroTimePoint = self.zeroTimePoint
	if not zeroTimePoint then
		zeroTimePoint = self:newTimePoint()
		zeroTimePoint.absoluteTime = 0
		zeroTimePoint.beatTime = Fraction(0)
		zeroTimePoint.fullBeatTime = Fraction(0)
		zeroTimePoint.visualTime = 0
		zeroTimePoint.visualSection = 0
		self:interpolateTimePointAbsolute(1, zeroTimePoint)
	end

	local zeroBeatTime = zeroTimePoint.beatTime
	local zeroFullBeatTime = zeroTimePoint.beatTime
	local zeroTime = zeroTimePoint.absoluteTime
	local zeroVisualTime = zeroTimePoint.visualTime

	for i, t in ipairs(timePointList) do
		t.index = i
		t.beatTime = t.beatTime - zeroBeatTime
		t.fullBeatTime = t.fullBeatTime - zeroFullBeatTime
		t.absoluteTime = t.absoluteTime - zeroTime
		t.visualTime = t.visualTime - zeroVisualTime
	end
end

---@param timePoint ncdk.TimePoint
---@param name string
---@param T table
---@param ... any?
---@return table
function LayerData:insertTimingObject(timePoint, name, T, ...)
	local object = T(...)
	table.insert(self[name .. "s"], object)

	assert(not timePoint["_" .. name])
	timePoint["_" .. name] = object
	object.timePoint = timePoint

	return object
end

---@param name string
---@return table
function LayerData:removeTimingObject(name)
	local object = table.remove(self[name .. "s"])
	local timePoint = object.timePoint

	assert(timePoint["_" .. name])
	timePoint["_" .. name] = nil
	object.timePoint = nil

	return object
end

---@param time number|ncdk.Fraction
---@param ... any?
---@return ncdk.TempoData
function LayerData:insertTempoData(time, ...)
	return self:insertTimingObject(self:getTimePoint(time), "tempoData", TempoData, ...)
end

---@return ncdk.TempoData
function LayerData:removeTempoData()
	return self:removeTimingObject("tempoData")
end

---@param time ncdk.Fraction
---@param ... any?
---@return ncdk.StopData
function LayerData:insertStopData(time, ...)
	local timePoint = self:getTimePoint(time, 1)  --[[@as ncdk.MeasureTimePoint]]
	local stopData = self:insertTimingObject(timePoint, "stopData", StopData, ...)
	stopData.leftTimePoint = self:getTimePoint(timePoint:getPrevTime())  -- for time point interpolation
	return stopData
end

---@return ncdk.StopData
function LayerData:removeStopData()
	return self:removeTimingObject("stopData")
end

---@param timePoint ncdk.TimePoint
---@param ... any?
---@return ncdk.VelocityData
function LayerData:insertVelocityData(timePoint, ...)
	return self:insertTimingObject(timePoint, "velocityData", VelocityData, ...)
end

---@return ncdk.VelocityData
function LayerData:removeVelocityData()
	return self:removeTimingObject("velocityData")
end

---@param timePoint ncdk.TimePoint
---@param ... any?
---@return ncdk.ExpandData
function LayerData:insertExpandData(timePoint, ...)
	local expandData = self:insertTimingObject(timePoint, "expandData", ExpandData, ...)
	expandData.leftTimePoint = self:getTimePoint(timePoint:getPrevVisualTime())  -- for time point interpolation
	return expandData
end

---@return ncdk.ExpandData
function LayerData:removeExpandData()
	return self:removeTimingObject("expandData")
end

---@param measureOffset number
---@param signature ncdk.Fraction
---@return ncdk.SignatureData
function LayerData:setSignature(measureOffset, signature)
	assert(self.signatureMode, "Signature mode should be set")
	self.signatures[measureOffset] = signature
	local timePoint = self:getTimePoint(Fraction:new(measureOffset))  -- for easier conversion to DynamicLayerData
	self:getTimePoint(Fraction:new(measureOffset + 1))  -- for time point interpolation
	return self:insertTimingObject(timePoint, "signatureData", SignatureData, signature)
end

---@param measureOffset number
---@return ncdk.Fraction?
function LayerData:getSignature(measureOffset)
	return self.signatures[measureOffset]
end

---@param absoluteTime number
---@param beats number
---@param start ncdk.Fraction?
---@return ncdk.IntervalData
function LayerData:insertIntervalData(absoluteTime, beats, start)
	local timePoint = self:getTimePoint(absoluteTime)  --[[@as ncdk.IntervalTimePoint]]
	timePoint.readonly = true
	local key = tostring(timePoint)
	local intervalData = self:insertTimingObject(timePoint, "intervalData", IntervalData, beats)
	timePoint.intervalData = intervalData
	timePoint.time = start
	timePoint.absoluteTime = absoluteTime
	local newKey = tostring(timePoint)
	assert(not self.timePoints[newKey])
	self.timePoints[key] = nil
	self.timePoints[newKey] = timePoint
	return intervalData
end

---@return ncdk.IntervalData
function LayerData:removeIntervalData()
	return self:removeTimingObject("intervalData")
end

---@param timePoint ncdk.TimePoint
---@param ... any?
---@return ncdk.MeasureData
function LayerData:insertMeasureData(timePoint, ...)
	return self:insertTimingObject(timePoint, "measureData", MeasureData, ...)
end

---@return ncdk.MeasureData
function LayerData:removeMeasureData()
	return self:removeTimingObject("measureData")
end

---@param i number
---@return ncdk.TempoData?
function LayerData:getTempoData(i) return self.tempoDatas[i] end
---@return number
function LayerData:getTempoDataCount() return #self.tempoDatas end

---@param i number
---@return ncdk.StopData?
function LayerData:getStopData(i) return self.stopDatas[i] end
---@return number
function LayerData:getStopDataCount() return #self.stopDatas end

---@param i number
---@return ncdk.VelocityData?
function LayerData:getVelocityData(i) return self.velocityDatas[i] end
---@return number
function LayerData:getVelocityDataCount() return #self.velocityDatas end

---@param i number
---@return ncdk.ExpandData?
function LayerData:getExpandData(i) return self.expandDatas[i] end
---@return number
function LayerData:getExpandDataCount() return #self.expandDatas end

---@param i number
---@return ncdk.IntervalData?
function LayerData:getIntervalData(i) return self.intervalDatas[i] end
---@return number
function LayerData:getIntervalDataCount() return #self.intervalDatas end

---@param i number
---@return ncdk.MeasureData?
function LayerData:getMeasureData(i) return self.measureDatas[i] end
---@return number
function LayerData:getMeasureDataCount() return #self.measureDatas end

---@param noteData ncdk.NoteData
---@param inputType string
---@param inputIndex number
function LayerData:addNoteData(noteData, inputType, inputIndex)
	local noteDatas = self:getNoteDatasList(inputType, inputIndex)

	table.insert(noteDatas, noteData)
	noteData.id = #noteDatas
end

---@param inputType string
---@param inputIndex number
---@return table
function LayerData:getNoteDatasList(inputType, inputIndex)
	local noteDatas = self.noteDatas
	noteDatas[inputType] = noteDatas[inputType] or {}
	noteDatas[inputType][inputIndex] = noteDatas[inputType][inputIndex] or {}
	return noteDatas[inputType][inputIndex]
end

return LayerData
