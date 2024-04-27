local class = require("class")

---@class ncdk2.IntervalAbsolute
---@operator call: ncdk2.IntervalAbsolute
local IntervalAbsolute = class()

---@param points ncdk2.IntervalPoint[]
---@return ncdk2.Measure?
function IntervalAbsolute:getFirstMeasure(points)
	for _, p in ipairs(points) do
		if p._measure then
			return p._measure
		end
	end
end

---@param points ncdk2.IntervalPoint[]
---@return ncdk2.Interval?
function IntervalAbsolute:getFirstInterval(points)
	for _, p in ipairs(points) do
		if p._interval then
			return p._interval
		end
	end
end

---@param points ncdk2.IntervalPoint[]
function IntervalAbsolute:convert(points)
	local measure = self:getFirstMeasure(points)
	local interval = self:getFirstInterval(points)

	for _, point in ipairs(points) do
		if point._measure then
			measure = point._measure
		end

		local _interval = point._interval
		if _interval then
			interval.next, _interval.prev = _interval, interval
			interval = _interval
			interval.point = point
		end

		point.interval = interval
		point.measure = measure
	end

	for _, point in ipairs(points) do
		point.absoluteTime = point:tonumber()
	end
end

return IntervalAbsolute
