local class = require("class")
local Fraction = require("ncdk.Fraction")

---@class ncdk2.MeasureAbsolute
---@operator call: ncdk2.MeasureAbsolute
local MeasureAbsolute = class()

MeasureAbsolute.defaultSignature = Fraction(4)

---@param points ncdk2.MeasurePoint[]
---@return ncdk2.Tempo?
function MeasureAbsolute:getFirstTempo(points)
	for _, p in ipairs(points) do
		if p._tempo then
			return p._tempo
		end
	end
end

---@param points ncdk2.MeasurePoint[]
function MeasureAbsolute:convert(points)
	local tempo = assert(self:getFirstTempo(points), "missing tempo")

	local pointIndex = 1
	local point = points[pointIndex]

	local defaultSignature = self.defaultSignature
	local signature = defaultSignature

	local beatTime = Fraction(0)
	local zeroTime = 0
	local time = 0
	local currentTime = point.measureTime
	if currentTime[1] > 0 then
		currentTime = Fraction(0)  -- what if all points are before 0?
	end

	while point do
		local measureOffset = currentTime:floor()

		local targetTime = Fraction(measureOffset + 1)
		if point.measureTime < targetTime then
			targetTime = point.measureTime
		end
		local isAtPoint = point.measureTime == targetTime

		---@type ncdk.Fraction
		beatTime = beatTime + signature * (targetTime - currentTime)

		---@type number
		local duration = tempo:getBeatDuration() * signature

		---@type number
		time = time + duration * (targetTime - currentTime)
		currentTime = targetTime

		if point._signature then
			signature = point._signature.signature or defaultSignature
		end

		if targetTime[1] == 0 then
			zeroTime = time  -- ??? stops
		end

		if isAtPoint then
			local nextTempo = point._tempo
			if nextTempo then
				tempo = nextTempo
			end

			local stop = point._stop
			if stop then
				local stop_duration = stop.duration
				if not stop.isAbsolute then
					stop_duration = tempo:getBeatDuration() * stop_duration
				end
				time = time + stop_duration
			end

			point.tempo = tempo
			point.absoluteTime = time
			point.beatTime = beatTime

			pointIndex = pointIndex + 1
			point = points[pointIndex]
		end
	end

	for i, t in ipairs(points) do
		t.absoluteTime = t.absoluteTime - zeroTime
	end
end

return MeasureAbsolute
