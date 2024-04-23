local Converter = require("ncdk2.conv.Converter")
local Fraction = require("ncdk.Fraction")

---@class ncdk2.MeasureAbsolute: ncdk2.Converter
---@operator call: ncdk2.MeasureAbsolute
local MeasureAbsolute = Converter + {}

---@type "long"|"short"
MeasureAbsolute.signatureMode = "long"

MeasureAbsolute.defaultSignature = Fraction(4)

---@param timePoints ncdk2.MeasureTimePoint[]
---@return ncdk2.TempoData?
function MeasureAbsolute:getFirstTempoData(timePoints)
	for _, tp in ipairs(timePoints) do
		if tp._tempoData then
			return tp._tempoData
		end
	end
end

---@param timePoints ncdk2.MeasureTimePoint[]
function MeasureAbsolute:convert(timePoints)
	local isLong = self.signatureMode == "long"

	local tempoData = self:getFirstTempoData(timePoints)
	if not tempoData then
		return
	end

	local timePointIndex = 1
	local timePoint = timePoints[timePointIndex]

	local signature = self.defaultSignature

	local zeroTime = 0
	local time = 0
	local currentTime = timePoint.measureTime
	while timePoint do
		local measureOffset = currentTime:floor()

		local targetTime = Fraction(measureOffset + 1)
		if timePoint.measureTime < targetTime then
			targetTime = timePoint.measureTime
		end
		local isAtTimePoint = timePoint.measureTime == targetTime

		local defaultSignature = self.defaultSignature
		if isLong then
			defaultSignature = signature
		end

		if timePoint._signatureData then
			signature = timePoint._signatureData.signature or defaultSignature
		else
			signature = defaultSignature
		end

		---@type number
		local duration = tempoData:getBeatDuration() * signature

		---@type number
		time = time + duration * (targetTime - currentTime)
		currentTime = targetTime

		if targetTime[1] == 0 then
			zeroTime = time  -- ??? stops
		end

		if isAtTimePoint then
			local nextTempoData = timePoint._tempoData
			if nextTempoData then
				tempoData = nextTempoData
			end

			local stopData = timePoint._stopData
			if stopData then
				local stop_duration = stopData.duration
				if not stopData.isAbsolute then
					stop_duration = tempoData:getBeatDuration() * stop_duration
				end
				time = time + stop_duration
			end

			timePoint.tempoData = tempoData
			timePoint.absoluteTime = time

			timePointIndex = timePointIndex + 1
			timePoint = timePoints[timePointIndex]
		end
	end

	for i, t in ipairs(timePoints) do
		t.absoluteTime = t.absoluteTime - zeroTime
	end
end

return MeasureAbsolute
