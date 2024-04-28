local class = require("class")

---@class ncdk2.AbsoluteAbsolute
---@operator call: ncdk2.AbsoluteAbsolute
local AbsoluteAbsolute = class()

---@param points ncdk2.MeasurePoint[]
---@return ncdk2.Tempo?
function AbsoluteAbsolute:getFirstTempo(points)
	for _, p in ipairs(points) do
		if p._tempo then
			return p._tempo
		end
	end
end

---@param points ncdk2.AbsolutePoint[]
function AbsoluteAbsolute:convert(points)
	local tempo = self:getFirstTempo(points)

	for _, point in ipairs(points) do
		local nextTempo = point._tempo
		if nextTempo then
			tempo = nextTempo
		end

		point.tempo = tempo
	end
end

return AbsoluteAbsolute
