local TimePoint = require("ncdk.TimePoint")

local noteChart = require("tests.reference_create_measure")

-- get all NoteData objects
local noteDatas = {}
for _, layerData in noteChart:getLayerDataIterator() do
	for noteDataIndex = 1, layerData:getNoteDataCount() do
		local noteData = layerData:getNoteData(noteDataIndex)
		noteDatas[#noteDatas + 1] = noteData
	end
end

local layerData = noteChart:getLayerData(1)
local currentTimePoint = layerData:newTimePoint()
currentTimePoint.side = 0
currentTimePoint.absoluteTime = 0 -- you should manually set absoluteTime
currentTimePoint.velocityData = layerData:getVelocityData(1) -- and corresponding to this time VelocityData

-- visual time computed relative to zero time point and not multiplied by localSpeed and globalSpeed
layerData:interpolateTimePointAbsolute(1, currentTimePoint)
assert(currentTimePoint.visualTime)

local noteData = noteDatas[1]
local timePoint = noteData.timePoint
assert(timePoint:getVisualTime(currentTimePoint)) -- visual time of note for current time
assert(timePoint.absoluteTime) -- absolute time of note
