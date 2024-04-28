local class = require("class")
local table_util = require("table_util")
local Interval = require("ncdk2.to.Interval")
local IntervalPoint = require("ncdk2.tp.IntervalPoint")
local IntervalLayer = require("ncdk2.layers.IntervalLayer")

---@class ncdk2.AbsoluteInterval
---@operator call: ncdk2.AbsoluteInterval
local AbsoluteInterval = class()

local timingMatchWindow = 0.005

---@param layer ncdk2.MeasureLayer
---@param fraction_mode any
function AbsoluteInterval:convert(layer, fraction_mode)
	if not fraction_mode then
		fraction_mode = false
	end

	local points = layer:getPointList()

	local intervalData
	for i, interval in ipairs(intervals) do
		local td = interval.tempoData
		table.sort(interval)

		local is_same = interval[#interval].absoluteTime == td.timePoint.absoluteTime
		interval.beats = 1
		if not is_same and i < #intervals then
			local _interval = {}
			local next_interval = intervals[i + 1]
			local next_td = next_interval.tempoData
			local idt = next_td.timePoint.absoluteTime - td.timePoint.absoluteTime
			local beats = idt / td:getBeatDuration()
			local next_td_time = Fraction(beats, 16, fraction_mode)
			local idt_new = next_td_time:floor() * td:getBeatDuration()
			local _time = next_td_time - Fraction(1, 16)
			_interval.beats = next_td_time:floor()
			if _time:tonumber() <= 0 then
				_interval.beats = 1
			elseif math.abs(idt_new - idt) > timingMatchWindow * td:getBeatDuration() then
				_interval.beats = _time:floor()
			end
			for j, tp in ipairs(interval) do
				local dt = tp.absoluteTime - td.timePoint.absoluteTime
				local time = Fraction(dt / td:getBeatDuration(), 16, fraction_mode)
				if time == next_td_time and time[1] ~= 0 then
					table.insert(next_interval, tp)
				else
					table.insert(_interval, tp)
				end
			end
			interval = _interval
		end
		table.sort(interval)

		is_same = interval[#interval].absoluteTime == td.timePoint.absoluteTime
		if is_same then
			interval.beats = 1
		end

		intervalData = newLayerData:insertIntervalData(td.timePoint.absoluteTime, interval.beats)

		for j, tp in ipairs(interval) do
			local dt = tp.absoluteTime - td.timePoint.absoluteTime
			local beatDuraion = td:getBeatDuration()
			local time = Fraction(dt / beatDuraion, 16, fraction_mode)

			if #interval > 1 and dt > 0 and i < #intervals and j == #interval then
				local next_interval = intervals[i + 1]
				local next_td = next_interval.tempoData
				local idt = next_td.timePoint.absoluteTime - td.timePoint.absoluteTime
				local beats = idt / beatDuraion
				local next_td_time = Fraction(beats, 16, fraction_mode)
				local idt_new = next_td_time:floor() * beatDuraion
				local _time = next_td_time - Fraction(1, 16)
				local t = td.timePoint.absoluteTime + _time:tonumber() * beatDuraion
				if _time:tonumber() > 0 and math.abs(idt_new - idt) > timingMatchWindow * beatDuraion then
					local id = newLayerData:insertIntervalData(t, 1, _time % 1)
					if time == _time then
						intervalData = id
						time = Fraction(0)
					end
				end
			end
			if i == #intervals and j == #interval then
				local beats = math.ceil(dt / beatDuraion)
				if beats > 0 then
					intervalData.beats = beats
					local t = td.timePoint.absoluteTime + beatDuraion * beats
					local id = newLayerData:insertIntervalData(t, 1)
					if time == Fraction(beats) then
						intervalData = id
						time = Fraction(0)
					end
				end
			end

			timePointMap[tp] = newLayerData:getTimePoint(intervalData, time, tp.visualSide)
		end
	end

	if #newLayerData.intervalDatas == 1 then
		local td = layerData.tempoDatas[1]
		local beatDuration = td:getBeatDuration()
		intervalData = newLayerData:insertIntervalData(td.timePoint.absoluteTime + beatDuration, 1)
	end

end

return AbsoluteInterval
