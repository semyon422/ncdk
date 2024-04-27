local class = require("class")
local Interval = require("ncdk2.to.Interval")
local IntervalPoint = require("ncdk2.tp.IntervalPoint")

---@class ncdk2.MeasureInterval
---@operator call: ncdk2.MeasureInterval
local MeasureInterval = class()

---@param points ncdk2.MeasurePoint[]
---@return ncdk2.IntervalPoint[]
function MeasureInterval:convert(points)
	local _points = {}

	for _, p in ipairs(points) do
		local _p = IntervalPoint(p.beatTime)
		if p._tempo then
			_p._interval = Interval(p.absoluteTime)
		end
	end

	return _points
end

return MeasureInterval
