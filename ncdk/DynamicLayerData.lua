local Fraction = require("ncdk.Fraction")
local TimePoint = require("ncdk.TimePoint")
local SignatureTable = require("ncdk.SignatureTable")

local DynamicLayerData = {}

local mt = {__index = DynamicLayerData}

function DynamicLayerData:new()
	local layerData = {}

	layerData.signatureTable = SignatureTable:new(Fraction:new(4))
	layerData.timePoints = {}
	layerData.noteDatas = {}

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
	self.zeroTimePoint = self:getTimePoint(time, -1)
end

function DynamicLayerData:getTimePoint(time, side)
	assert(self.mode, "Mode should be set")

	if type(time) == "number" then
		time = math.min(math.max(time, -2147483648), 2147483647)
	end

	local timePoints = self.timePoints
	local key = time .. "," .. side
	if timePoints[key] then
		return timePoints[key]
	end

	local timePoint = TimePoint:new()
	timePoint.side = side
	timePoints[key] = timePoint

	if self.mode == "absolute" then
		timePoint.absoluteTime = time
	elseif self.mode == "measure" then
		timePoint.measureTime = time
	end

	if not self.firstTimePoint or timePoint < self.firstTimePoint then
		self.firstTimePoint = timePoint
	end

	return timePoint
end

function DynamicLayerData:createTimePointList()
	local list = {}
	for _, timePoint in pairs(self.timePoints) do
		list[#list + 1] = timePoint
	end
	table.sort(list)
	for i = 1, #list do
		list[i].prev = list[i - 1]
		list[i].next = list[i + 1]
	end
end

function DynamicLayerData:computeTimePoints()
	assert(self.mode, "Mode should be set")

	self:createTimePointList()

	local isMeasure = self.mode == "measure"

	local tempoData = self.firstTempoData
	local velocityData = self.firstVelocityData

	local timePoint = self.firstTimePoint

	local time = 0
	local visualTime = 0
	local currentTime = timePoint.measureTime
	local currentAbsoluteTime = 0
	while timePoint do
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
			else
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
			timePoint.tempoData = tempoData
			timePoint.velocityData = velocityData

			timePoint.absoluteTime = timePoint.absoluteTime or time
			timePoint.zeroClearVisualTime = visualTime

			timePoint = timePoint.next
		end
	end

	local zeroTime = self.zeroTimePoint.absoluteTime
	local zeroVisualTime = self.zeroTimePoint.zeroClearVisualTime

	local t = self.firstTimePoint
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

	if not self.firstTempoData or tempoData.time < self.firstTempoData.time then
		self.firstTempoData = tempoData
	end
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
