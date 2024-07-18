local class = require("class")
local table_util = require("table_util")
local Tempo = require("ncdk2.to.Tempo")
local Measure = require("ncdk2.to.Measure")
local AbsolutePoint = require("ncdk2.tp.AbsolutePoint")
local AbsoluteLayer = require("ncdk2.layers.AbsoluteLayer")
local Restorer = require("ncdk2.visual.Restorer")

---@class ncdk2.IntervalAbsolute
---@operator call: ncdk2.IntervalAbsolute
local IntervalAbsolute = class()

---@param points ncdk2.IntervalPoint[]
---@return {[string]: ncdk2.AbsolutePoint}
function IntervalAbsolute:convertPoints(points)
	---@type {[string]: ncdk2.AbsolutePoint}
	local points_map = {}

	---@type {[ncdk2.Interval]: number}
	local interval_tempos = {}

	for _, p in ipairs(points) do
		local _interval = p._interval
		if _interval then
			interval_tempos[_interval] = _interval:getTempo()
		end
	end

	local first_measure = false

	for _, p in ipairs(points) do
		local _interval = p._interval
		local interval = p.interval
		local tempo = interval_tempos[interval]

		local _measure = p._measure
		local measure = p.measure

		local time = p.time

		---@type ncdk.Fraction
		local beat_offset
		if measure then
			beat_offset = measure.offset
		end

		local absoluteTime = p.absoluteTime

		---@cast p -ncdk2.IntervalPoint, +ncdk2.AbsolutePoint
		setmetatable(p, AbsolutePoint)
		table_util.clear(p)

		if _interval or _measure then
			p._tempo = Tempo(tempo)
			local offset = time % 1 + (beat_offset or 0)
			if offset:tonumber() ~= 0 then
				p._measure = Measure(offset)
			end
		end

		if not first_measure and _interval then
			first_measure = true
			p._measure = Measure()
		end

		p:new(absoluteTime)
		points_map[tostring(p)] = p
	end

	return points_map
end

---@param layer ncdk2.IntervalLayer
function IntervalAbsolute:convert(layer)
	for _, visual in pairs(layer.visuals) do
		Restorer:restore(visual.points)
	end

	local points = layer:getPointList()
	local points_map = self:convertPoints(points)

	local visuals = layer.visuals

	---@cast layer -ncdk2.IntervalLayer, +ncdk2.AbsoluteLayer
	setmetatable(layer, AbsoluteLayer)
	table_util.clear(layer)

	layer:new()
	layer.points = points_map
	layer.visuals = visuals

	layer:compute()
end

return IntervalAbsolute
