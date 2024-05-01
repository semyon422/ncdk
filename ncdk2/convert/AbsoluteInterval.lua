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
		local delta = Fraction(n, denom, "round"):tonumber()
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
function AbsoluteInterval:computeTempos(points)
	local tempos, tempo_offsets = self:loadTempos(points)

	---@type {[ncdk.Fraction]: ncdk2.Interval}
	local intervals = {}
	intervals[Fraction(0)] = Interval(tempo_offsets[tempos[1]])

	local total_beats = 0

	---@type {[ncdk2.Tempo]: number}
	local tempo_beat_offsets = {}
	tempo_beat_offsets[tempos[1]] = total_beats

	for i = 2, #tempos  do
		local prev_tempo, tempo = tempos[i - 1], tempos[i]
		local offset = tempo_offsets[prev_tempo]
		local beat_duration = prev_tempo:getBeatDuration()

		local beats = self.tempoConnector:connect(
			offset,
			beat_duration,
			tempo_offsets[tempo]
		)

		local beatsn = beats:tonumber()
		if beatsn % 1 ~= 0 then
			local aux_offset = beatsn * beat_duration + offset
			intervals[beats + total_beats] = Interval(aux_offset)
		end

		total_beats = total_beats + beats:ceil()
		intervals[Fraction(total_beats)] = Interval(tempo_offsets[tempo])

		tempo_beat_offsets[tempo] = total_beats
	end

	return intervals, tempo_beat_offsets, tempo_offsets
end

---@param layer ncdk2.AbsoluteLayer
---@param fraction_mode any
function AbsoluteInterval:convert(layer, fraction_mode)
	if not fraction_mode then
		fraction_mode = false
	end

	---@type ncdk2.AbsolutePoint[]
	local points = layer:getPointList()

	local last_point = points[#points]
	if not last_point._tempo then
		last_point._tempo = Tempo(1)
	end

	local intervals, tempo_beat_offsets, tempo_offsets = self:computeTempos(points)

	---@type {[string]: ncdk2.IntervalPoint}
	local points_map = {}

	for _, p in ipairs(points) do
		local tempo = assert(p.tempo)
		local tempo_offset = tempo_offsets[tempo]
		local relBeatTime = (p.absoluteTime - tempo_offset) / tempo:getBeatDuration()
		local relBeatTimef = self:bestFraction(relBeatTime)
		local beatTime = relBeatTimef + tempo_beat_offsets[tempo]
		print("beatTime", beatTime, relBeatTimef, tempo_beat_offsets[tempo])

		---@cast p -ncdk2.AbsolutePoint, +ncdk2.IntervalPoint
		setmetatable(p, IntervalPoint)
		table_util.clear(p)

		p:new(beatTime)
		points_map[tostring(p)] = p  -- more than one point can use same key, fix this below
	end

	for _, visualPoint in ipairs(layer.visualPoints) do
		visualPoint.point = points_map[tostring(visualPoint.point)]
		-- possibly need to add expands here recovering 1ms SVs
	end

	local notes, visualPoints = layer.notes, layer.visualPoints

	---@cast layer -ncdk2.AbsoluteLayer, +ncdk2.IntervalLayer
	setmetatable(layer, IntervalLayer)
	table_util.clear(layer)

	layer:new()
	layer.notes = notes
	layer.points = points_map
	layer.visualPoints = visualPoints

	for time, interval in pairs(intervals) do
		local p = layer:getPoint(time)
		p._interval = interval
	end

	layer:compute()
end

return AbsoluteInterval
