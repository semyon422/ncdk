local NoteChart		= require("ncdk.NoteChart")
local VelocityData	= require("ncdk.VelocityData")
local StopData		= require("ncdk.StopData")
local TempoData		= require("ncdk.TempoData")
local NoteData		= require("ncdk.NoteData")
local Fraction		= require("ncdk.Fraction")

local noteChart = NoteChart:new()

local layerData1 = noteChart:getLayerData(1)
layerData1:setTimeMode("measure")
layerData1:setSignatureMode("short")

noteChart.inputMode.key = 10
noteChart.inputMode.scratch = 2

-- not related to ncdk
noteChart.type = "bms"
-- end

layerData1:setSignature(
	0, -- measureOffset
	Fraction:new(4) -- signature, beats in measure
)

layerData1:insertTempoData(Fraction:new(0), 60)
layerData1:insertStopData(Fraction:new(0), Fraction:new(4))

local timePoint1 = layerData1:getTimePoint(
	Fraction:new(0), -- measureTime in measure mode
	0 -- side
)

layerData1:insertVelocityData(layerData1:getTimePoint(Fraction:new(0)), 1)

local noteData1 = NoteData:new(timePoint1)
layerData1:addNoteData(noteData1, "key", 1)

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
