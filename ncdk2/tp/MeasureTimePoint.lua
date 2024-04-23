local TimePoint = require("ncdk2.tp.TimePoint")

---@class ncdk2.MeasureTimePoint: ncdk2.TimePoint
---@operator call: ncdk2.MeasureTimePoint
---@field _signatureData ncdk2.SignatureData?
---@field _tempoData ncdk2.TempoData?
---@field tempoData ncdk2.TempoData?
---@field _stopData ncdk2.StopData?
---@field measureTime ncdk.Fraction
---@field beatTime ncdk.Fraction?
---@field fullBeatTime ncdk.Fraction?
local MeasureTimePoint = TimePoint + {}

---@param measureTime ncdk.Fraction
function MeasureTimePoint:new(measureTime)
	self.measureTime = measureTime
end

-- StopData should be placed on isRightSide = true
-- In this case both false and true time points should exist
MeasureTimePoint.isRightSide = false

return MeasureTimePoint
