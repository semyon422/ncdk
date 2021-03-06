local Fraction = require("ncdk.Fraction")

local noteChart = require("tests.reference_create_measure")

-- get all NoteData objects
local noteDatas = {}
for layerIndex in noteChart:getLayerDataIndexIterator() do
	local layerData = noteChart:requireLayerData(layerIndex)
	for noteDataIndex = 1, layerData:getNoteDataCount() do
		local noteData = layerData:getNoteData(noteDataIndex)
		noteDatas[#noteDatas + 1] = noteData
	end
end

local layerData = noteChart:requireLayerData(1)
local currentTimePoint = layerData:getTimePoint() -- without arguments
currentTimePoint.absoluteTime = 0 -- you should manually set absoluteTime
currentTimePoint.velocityData = layerData:getVelocityData(1) -- and corresponding to this time VelocityData

-- visual time computed relative to zero time point and not multiplied by localSpeed and globalSpeed
currentTimePoint:computeZeroClearVisualTime()
assert(currentTimePoint.zeroClearVisualTime)

local noteData = noteDatas[1]
local timePoint = noteData.timePoint
timePoint:computeVisualTime(currentTimePoint)
assert(timePoint.currentVisualTime) -- visual time of note for current time
assert(timePoint.absoluteTime) -- absolute time of note
