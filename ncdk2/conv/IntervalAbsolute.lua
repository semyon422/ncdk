local Converter = require("ncdk2.conv.Converter")

---@class ncdk2.IntervalAbsolute: ncdk2.Converter
---@operator call: ncdk2.IntervalAbsolute
local IntervalAbsolute = Converter + {}

---@param timePoints ncdk2.IntervalTimePoint[]
---@return ncdk2.MeasureData?
function IntervalAbsolute:getFirstMeasureData(timePoints)
	for _, tp in ipairs(timePoints) do
		if tp._measureData then
			return tp._measureData
		end
	end
end

---@param timePoints ncdk2.IntervalTimePoint[]
---@return ncdk2.IntervalData?
function IntervalAbsolute:getFirstIntervalData(timePoints)
	for _, tp in ipairs(timePoints) do
		if tp._intervalData then
			return tp._intervalData
		end
	end
end

---@param timePoints ncdk2.IntervalTimePoint[]
function IntervalAbsolute:convert(timePoints)
	local measureData = self:getFirstMeasureData(timePoints)
	local intervalData = self:getFirstIntervalData(timePoints)

	for _, timePoint in ipairs(timePoints) do
		if timePoint._measureData then
			measureData = timePoint._measureData
		end

		local _intervalData = timePoint._intervalData
		if _intervalData then
			intervalData.next, _intervalData.prev = _intervalData, intervalData
			intervalData = _intervalData
			intervalData.timePoint = timePoint
		end

		timePoint.intervalData = intervalData
		timePoint.measureData = measureData
	end

	for _, timePoint in ipairs(timePoints) do
		timePoint.absoluteTime = timePoint:tonumber()
	end
end

return IntervalAbsolute
