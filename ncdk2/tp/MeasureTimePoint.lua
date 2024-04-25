local TimePoint = require("ncdk2.tp.TimePoint")

---@class ncdk2.MeasureTimePoint: ncdk2.TimePoint
---@operator call: ncdk2.MeasureTimePoint
---@field _signatureData ncdk2.SignatureData?
---@field _tempoData ncdk2.TempoData?
---@field tempoData ncdk2.TempoData?
---@field _stopData ncdk2.StopData?
local MeasureTimePoint = TimePoint + {}

-- StopData should be placed on isRightSide = true
-- In this case both false and true time points should exist
MeasureTimePoint.isRightSide = false

---@param measureTime ncdk.Fraction
---@param isRightSide boolean?
function MeasureTimePoint:new(measureTime, isRightSide)
	self.measureTime = measureTime
	self.isRightSide = isRightSide
end

---@param a ncdk2.MeasureTimePoint
---@return string
function MeasureTimePoint.__tostring(a)
	return ("MeasureTimePoint(%s,%s)"):format(a.measureTime, a.isRightSide)
end

---@param a ncdk2.MeasureTimePoint
---@param b ncdk2.MeasureTimePoint
---@return boolean
function MeasureTimePoint.__eq(a, b)
	local at, bt = a.measureTime, b.measureTime
	return at == bt and a.isRightSide == b.isRightSide
end

---@param a ncdk2.MeasureTimePoint
---@param b ncdk2.MeasureTimePoint
---@return boolean
function MeasureTimePoint.__lt(a, b)
	local at, bt = a.measureTime, b.measureTime
	return at < bt or
		at == bt and a.isRightSide == false and b.isRightSide == true
end

---@param a ncdk2.MeasureTimePoint
---@param b ncdk2.MeasureTimePoint
---@return boolean
function MeasureTimePoint.__le(a, b)
	local at, bt = a.measureTime, b.measureTime
	return at < bt or
		at == bt and a.isRightSide == false and b.isRightSide == true or
		at == bt and a.isRightSide == b.isRightSide
end

return MeasureTimePoint
