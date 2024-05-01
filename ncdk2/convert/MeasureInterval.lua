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
	local lastPoint = points[1]
	local absoluteTime = 0
	for _, p in ipairs(points) do
		local _tempo = p._tempo
		local beatTime = assert(p.beatTime)
		absoluteTime = assert(p.absoluteTime)

		---@cast p -ncdk2.MeasurePoint, +ncdk2.IntervalPoint
		setmetatable(p, IntervalPoint)
		table_util.clear(p)

		p:new(beatTime)
		points_map[tostring(p)] = p
		if _tempo then
			p._interval = Interval(absoluteTime)
		end
		lastPoint = p
	end
	if not lastPoint._tempo then
		lastPoint._interval = Interval(absoluteTime)
	end
	return points_map
end

---@param layer ncdk2.MeasureLayer
function MeasureInterval:convert(layer)
	local points = layer:getPointList()
	local points_map = self:convertPoints(points)

	local notes, visualPoints = layer.notes, layer.visualPoints

	---@cast layer -ncdk2.MeasureLayer, +ncdk2.IntervalLayer
	setmetatable(layer, IntervalLayer)
	table_util.clear(layer)

	layer:new()
	layer.notes = notes
	layer.points = points_map
	layer.visualPoints = visualPoints

	layer:compute()
end

return MeasureInterval
