local class = require("class")
local table_util = require("table_util")
local Tempo = require("ncdk2.to.Tempo")
local Interval = require("ncdk2.to.Interval")
local IntervalPoint = require("ncdk2.tp.IntervalPoint")
local IntervalLayer = require("ncdk2.layers.IntervalLayer")
local TempoConnector = require("ncdk2.convert.TempoConnector")
local Fraction = require("ncdk.Fraction")

---@class ncdk2.AbsoluteInterval
---@operator call: ncdk2.AbsoluteInterval
local AbsoluteInterval = class()

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
	intervals[Fraction(0)] = Interval(tempo_offsets[tempos[1]])

	local total_beats = 0

	---@type {[ncdk2.Tempo]: number}
	local tempo_beat_offsets = {}
	tempo_beat_offsets[tempos[1]] = total_beats

	---@type {[ncdk2.Tempo]: ncdk.Fraction}
	local tempo_beats = {}

	for i = 2, #tempos  do
		local prev_tempo, tempo = tempos[i - 1], tempos[i]
		local offset = tempo_offsets[prev_tempo]
		local beat_duration = prev_tempo:getBeatDuration()

		local beats, aux_interval = self.tempoConnector:connect(
			offset,
			beat_duration,
			tempo_offsets[tempo]
		)

		tempo_beats[prev_tempo] = beats

		if aux_interval then
			local aux_offset = beats:tonumber() * beat_duration + offset
			intervals[beats + total_beats] = Interval(aux_offset)
			if beats[2] == 1 then
				total_beats = total_beats + 1
			end
		end

		total_beats = total_beats + beats:ceil()
		intervals[Fraction(total_beats)] = Interval(tempo_offsets[tempo])

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

	---@type {[string]: ncdk2.IntervalPoint}
	local points_map = {}

	for i, p in ipairs(points) do
		local tempo = assert(p.tempo)
		local tempo_offset = tempo_offsets[tempo]
		local rel_time_n = (p.absoluteTime - tempo_offset) / tempo:getBeatDuration()
		local rel_time = self:bestFraction(rel_time_n)
		if tempo_beats[tempo] and rel_time > tempo_beats[tempo] then
			rel_time = Fraction(rel_time:ceil())
		end

		local time = rel_time + tempo_beat_offsets[tempo]

		if i == #points and not p._tempo then
			local time_ceil_n = time:ceil()
			local beats = time_ceil_n - tempo_beat_offsets[tempo]
			intervals[Fraction(time_ceil_n)] = Interval(tempo_offset + tempo:getBeatDuration() * beats)
		end

		---@cast p -ncdk2.AbsolutePoint, +ncdk2.IntervalPoint
		setmetatable(p, IntervalPoint)
		table_util.clear(p)

		p:new(time)
		points_map[tostring(p)] = p  -- more than one point can use same key, fix this below
	end

	for _, visualPoint in ipairs(layer.visual.points) do
		visualPoint.point = points_map[tostring(visualPoint.point)]
		-- possibly need to add expands here recovering 1ms SVs
	end

	local notes, visual = layer.notes, layer.visual

	---@cast layer -ncdk2.AbsoluteLayer, +ncdk2.IntervalLayer
	setmetatable(layer, IntervalLayer)
	table_util.clear(layer)

	layer:new()
	layer.notes = notes
	layer.points = points_map
	layer.visual = visual

	for time, interval in pairs(intervals) do
		local p = layer:getPoint(time)
		p._interval = interval
	end

	layer:compute()
end

return AbsoluteInterval
