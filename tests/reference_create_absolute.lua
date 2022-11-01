local NoteChart		= require("ncdk.NoteChart")
local VelocityData	= require("ncdk.VelocityData")
local StopData		= require("ncdk.StopData")
local TempoData		= require("ncdk.TempoData")
local NoteData		= require("ncdk.NoteData")
local Fraction		= require("ncdk.Fraction")

local noteChart = NoteChart:new()

local layerData1 = noteChart.layerDataSequence:getLayerData(1)
layerData1:setTimeMode("absolute")

noteChart.inputMode.key = 10

-- not related to ncdk
noteChart.type = "osu"
-- end

local timePoint1 = layerData1:getTimePoint(
	0, -- absoluteTime in absolute mode
	-1 -- side, doesn't affect anything in absolute mode
)

local velocityData1 = VelocityData:new(timePoint1)
velocityData1.currentVelocity = 1
layerData1:addVelocityData(velocityData1)

local noteData1 = NoteData:new(timePoint1)
layerData1:addNoteData(noteData1)
noteData1.inputType = "key"
noteData1.inputIndex = 1

-- not related to ncdk
noteData1.sounds = {}
noteData1.sounds[1] = {"sound.ogg", 1}
noteChart:addResource("sound", "sound.ogg", {"sound.ogg", "sound_fallback.ogg"})

noteData1.images = {}
noteData1.images[1] = {"image.png", 1}
noteChart:addResource("image", "image.png", {"image.png", "image_fallback.png"})

noteData1.noteType = "ImageNote"
noteData1.noteType = "SoundNote"
noteData1.noteType = "LongNoteStart"
noteData1.noteType = "LongNoteEnd"
noteData1.noteType = "ShortNote"
-- end

noteChart:compute()

return noteChart
