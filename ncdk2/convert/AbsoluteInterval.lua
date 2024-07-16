local class = require("class")
local table_util = require("table_util")
local Interval = require("ncdk2.to.Interval")
local IntervalPoint = require("ncdk2.tp.IntervalPoint")
local IntervalLayer = require("ncdk2.layers.IntervalLayer")
local TempoConnector = require("ncdk2.convert.TempoConnector")
local Restorer = require("ncdk2.visual.Restorer")
local Fraction = require("ncdk.Fraction")

---@class ncdk2.AbsoluteInterval
---@operator call: ncdk2.AbsoluteInterval
local AbsoluteInterval = class()

AbsoluteInterval.min_beat_duration = 0.080  -- 750 bpm, 1/16 = 5ms

---@param denoms number[]
---@param merge_time number
function AbsoluteInterval:new(denoms, merge_time)
	self.denoms = denoms
	self.tempoConnector = TempoConnector(denoms[#denoms], merge_time)
end

---@param n number
---@return ncdk.Fraction
function AbsoluteInterval:bestFraction(n)
	local _delta = math.huge
	local _denom = 1
	for _, denom in ipairs(self.denoms) do
		local delta = math.abs(Fraction(n, denom, "round"):tonumber() - n)
		if delta < _delta then
			_denom = denom
			_delta = delta
		end
	end
	return Fraction(n, _denom, "round")
end

---@param dur number
---@return number
function AbsoluteInterval:clampTempo(dur)
	local mbd = self.min_beat_duration
	if dur < 0.001 then
		return mbd
	end
	while dur < mbd do
		dur = dur * 2
	end
	return dur
end

---@param points ncdk2.AbsolutePoint[]
---@return ncdk2.Tempo[]
---@return {[ncdk2.Tempo]: number}
function AbsoluteInterval:loadTempos(points)
	---@type {[ncdk2.Tempo]: number}
	local tempo_offsets = {}

	---@type ncdk2.Tempo[]
	local tempos = {}

	for _, point in ipairs(points) do
		local _tempo = point._tempo
		if _tempo then
			table.insert(tempos, _tempo)
			tempo_offsets[_tempo] = point.absoluteTime
		end
	end

	return tempos, tempo_offsets
end

---@param points ncdk2.AbsolutePoint[]
---@return {[ncdk.Fraction]: ncdk2.Interval}
---@return {[ncdk2.Tempo]: number}
---@return {[ncdk2.Tempo]: number}
---@return {[ncdk2.Tempo]: ncdk.Fraction}
function AbsoluteInterval:computeTempos(points)
	local tempos, tempo_offsets = self:loadTempos(points)

	---@type {[ncdk.Fraction]: ncdk2.Interval}
	local intervals = {}
	---@type {[ncdk2.Tempo]: number}
	local tempo_beat_offsets = {}
	---@type {[ncdk2.Tempo]: ncdk.Fraction}
	local tempo_beats = {}

	if #tempos == 0 then
		return intervals, tempo_beat_offsets, tempo_offsets, tempo_beats
	end

	local total_beats = 0
	tempo_beat_offsets[tempos[1]] = total_beats
	intervals[Fraction(0)] = Interval(tempo_offsets[tempos[1]])

	---@type {[number]: ncdk2.Interval}
	local offset_intervals = {}

	for i = 2, #tempos  do
		local prev_tempo, tempo = tempos[i - 1], tempos[i]
		local offset = tempo_offsets[prev_tempo]
		local beat_duration = self:clampTempo(prev_tempo:getBeatDuration())

		local beats, aux_interval, int_beats = self.tempoConnector:connect(
			offset,
			beat_duration,
			tempo_offsets[tempo]
		)

		tempo_beats[prev_tempo] = beats

		if aux_interval and beats[1] ~= 0 then
			local aux_offset = beats:tonumber() * beat_duration + offset
			local interval = Interval(aux_offset)
			assert(not offset_intervals[aux_offset], aux_offset)
			offset_intervals[aux_offset] = interval
			intervals[beats + total_beats] = interval
		end

		total_beats = total_beats + int_beats
		local _offset = tempo_offsets[tempo]
		local interval = Interval(_offset)
		assert(not offset_intervals[_offset], _offset)
		offset_intervals[_offset] = interval
		intervals[Fraction(total_beats)] = interval

		tempo_beat_offsets[tempo] = total_beats
	end

	return intervals, tempo_beat_offsets, tempo_offsets, tempo_beats
end

---@param layer ncdk2.AbsoluteLayer
---@param fraction_mode any
function AbsoluteInterval:convert(layer, fraction_mode)
	if not fraction_mode then
		fraction_mode = false
	end

	---@type ncdk2.AbsolutePoint[]
	local points = layer:getPointList()

	local intervals, tempo_beat_offsets, tempo_offsets, tempo_beats = self:computeTempos(points)

	if not next(intervals) then
		---@cast layer -ncdk2.AbsoluteLayer, +ncdk2.IntervalLayer
		setmetatable(layer, IntervalLayer)
		table_util.clear(layer)
		layer:new()
		return
	end

	---@type {[string]: ncdk2.IntervalPoint}
	local points_map = {}

	---@type ncdk.Fraction
	local prev_time

	for i, p in ipairs(points) do
		local absoluteTime = p.absoluteTime
		local tempo = assert(p.tempo)

		local tempo_offset = tempo_offsets[tempo]
		local beat_duration = self:clampTempo(tempo:getBeatDuration())
		local rel_time_n = (absoluteTime - tempo_offset) / beat_duration
		local rel_time = self:bestFraction(rel_time_n)
		if tempo_beats[tempo] and rel_time > tempo_beats[tempo] then
			rel_time = Fraction(rel_time:ceil())
		end

		local time = rel_time + tempo_beat_offsets[tempo]

		if i == 1 and not p._tempo then
			local time_ceil_n = time:floor()
			local beats = time_ceil_n - tempo_beat_offsets[tempo]
			intervals[Fraction(time_ceil_n)] = Interval(tempo_offset + beat_duration * beats)
		elseif i == #points and not p._tempo then
			local time_ceil_n = time:ceil()
			local beats = time_ceil_n - tempo_beat_offsets[tempo]
			intervals[Fraction(time_ceil_n)] = Interval(tempo_offset + beat_duration * beats)
		end

		---@cast p -ncdk2.AbsolutePoint, +ncdk2.IntervalPoint
		setmetatable(p, IntervalPoint)
		table_util.clear(p)

		if prev_time then
			assert(time >= prev_time, "time is not monotonic")
		end
		prev_time = time

		p:new(time)
		points_map[tostring(p)] = p  -- more than one point can use same key, fix this below
	end

	for _, visual in pairs(layer.visuals) do
		for _, visualPoint in ipairs(visual.points) do
			visualPoint.point = points_map[tostring(visualPoint.point)]
		end
	end

	local visuals = layer.visuals

	---@cast layer -ncdk2.AbsoluteLayer, +ncdk2.IntervalLayer
	setmetatable(layer, IntervalLayer)
	table_util.clear(layer)

	layer:new()
	layer.points = points_map
	layer.visuals = visuals

	for time, interval in pairs(intervals) do
		local p = layer:getPoint(time)
		p._interval = interval
	end

	layer.intervalAbsolute:convert(layer:getPointList())

	for name, visual in pairs(layer.visuals) do
		---@type number[]
		local vts = {}
		for i, vp in ipairs(visual.points) do
			vts[i] = vp.visualTime
		end
		Restorer:restore(visual.points)
		visual:compute()
		local sum = 0
		local sum2 = 0
		for i, vp in ipairs(visual.points) do
			local delta = vts[i] - vp.visualTime
			sum = sum + delta
			sum2 = sum2 + delta ^ 2
		end
		print(name, math.sqrt(math.abs(sum2 / #vts - (sum / #vts) ^ 2)))
	end

	layer:validate()
end

return AbsoluteInterval
