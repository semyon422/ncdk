local class = require("class")
local table_util = require("table_util")
local Interval = require("ncdk2.to.Interval")
local IntervalPoint = require("ncdk2.tp.IntervalPoint")
local IntervalLayer = require("ncdk2.layers.IntervalLayer")

---@class ncdk2.MeasureInterval
---@operator call: ncdk2.MeasureInterval
local MeasureInterval = class()

---@param points ncdk2.MeasurePoint[]
---@return {[string]: ncdk2.IntervalPoint}
function MeasureInterval:convertPoints(points)
	---@type {[string]: ncdk2.IntervalPoint}
	local points_map = {}
	local absoluteTime = 0

	---@type ncdk2.IntervalPoint
	local last_point

	local prev_stop = false

	local stop_beats = 0
	for _, p in ipairs(points) do
		local _tempo = p._tempo
		local _stop = p._stop

		if prev_stop then
			stop_beats = stop_beats + 1
		end

		local beatTime = assert(p.beatTime) + stop_beats
		absoluteTime = assert(p.absoluteTime)

		---@cast p -ncdk2.MeasurePoint, +ncdk2.IntervalPoint
		setmetatable(p, IntervalPoint)
		table_util.clear(p)

		p:new(beatTime)
		points_map[tostring(p)] = p
		if _tempo or _stop or prev_stop then
			p._interval = Interval(absoluteTime)
			prev_stop = _stop ~= nil
		end
		last_point = p
	end
	if not last_point._interval then
		last_point._interval = Interval(absoluteTime)
	end
	return points_map
end

---@param layer ncdk2.MeasureLayer
function MeasureInterval:convert(layer)
	local points = layer:getPointList()
	local points_map = self:convertPoints(points)

	local visuals = layer.visuals

	---@cast layer -ncdk2.MeasureLayer, +ncdk2.IntervalLayer
	setmetatable(layer, IntervalLayer)
	table_util.clear(layer)

	layer:new()
	layer.points = points_map
	layer.visuals = visuals

	layer:compute()
end

return MeasureInterval
