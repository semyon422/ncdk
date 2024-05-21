local class = require("class")
local Fraction = require("ncdk.Fraction")
local Interpolator = require("ncdk2.Interpolator")
local MeasurePoint = require("ncdk2.tp.MeasurePoint")

---@class ncdk2.MeasureAbsolute
---@operator call: ncdk2.MeasureAbsolute
local MeasureAbsolute = class()

function MeasureAbsolute:new()
	self.interpolator = Interpolator()
end

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

	local defaultSignature = self.defaultSignature
	local signature = defaultSignature

	local beatTime = Fraction(0)
	local time = 0

	local currentTime = points[1].measureTime
	for _, point in ipairs(points) do
		local measureTime = point.measureTime

		---@type ncdk.Fraction
		beatTime = beatTime + signature * (measureTime - currentTime)

		---@type number
		local measure_duration = tempo:getBeatDuration() * signature

		---@type number
		time = time + measure_duration * (measureTime - currentTime)
		currentTime = measureTime

		if point._signature then
			signature = point._signature.signature or defaultSignature
		end

		local _tempo = point._tempo
		if _tempo then
			tempo = _tempo
		end

		point.tempo = tempo
		point.signature = signature
		point.absoluteTime = time
		point.beatTime = beatTime

		local stop = point._stop
		if stop then
			local stop_duration = stop.duration
			if not stop.isAbsolute then
				stop_duration = tempo:getBeatDuration() * stop_duration
			end
			time = time + stop_duration
		end
	end

	local zero_p = MeasurePoint()
	zero_p.measureTime = Fraction(0)

	local index = self.interpolator:getBaseIndex(points, 1, zero_p)
	local a = points[index]

	---@type number
	local zero_absoluteTime = a.absoluteTime - a.tempo:getBeatDuration() * a.measureTime * a.signature
	local zero_beatTime = a.beatTime - a.measureTime * a.signature

	for _, p in ipairs(points) do
		p.absoluteTime = p.absoluteTime - zero_absoluteTime
		p.beatTime = p.beatTime - zero_beatTime
	end
end

return MeasureAbsolute
