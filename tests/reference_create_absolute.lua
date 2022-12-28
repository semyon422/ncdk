local NoteChart		= require("ncdk.NoteChart")
local VelocityData	= require("ncdk.VelocityData")
local NoteData		= require("ncdk.NoteData")

local noteChart = NoteChart:new()

local layerData1 = noteChart:getLayerData(1)
layerData1:setTimeMode("absolute")

noteChart.inputMode.key = 10

-- not related to ncdk
noteChart.type = "osu"
-- end

local timePoint1 = layerData1:getTimePoint(
	0, -- absoluteTime in absolute mode
	0 -- side, doesn't affect anything in absolute mode
)

layerData1:insertVelocityData(layerData1:getTimePoint(0), 1)

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
