local class = require("class")
local table_util = require("table_util")
local Point = require("ncdk2.tp.Point")
local Visual = require("ncdk2.visual.Visual")

---@class ncdk2.Layer
---@operator call: ncdk2.Layer
---@field points {[string]: ncdk2.Point}
---@field visuals {[string]: ncdk2.Visual}
local Layer = class()

function Layer:new()
	self.points = {}
	self.visuals = {}
	self.testPoint = self:newPoint()
end

---@param ... any
---@return ncdk2.Point
function Layer:newPoint(...)
	return Point(...)
end

function Layer:compute()
	for _, visual in pairs(self.visuals) do
		visual:compute()
	end
	table_util.clear(self.testPoint)
end

---@param ... any
---@return ncdk2.Point
function Layer:getPoint(...)
	self.testPoint:new(...)

	local points = self.points
	local key = tostring(self.testPoint)
	local point = points[key]
	if point then
		return point
	end

	point = self:newPoint(...)
	points[key] = point

	return point
end

---@return ncdk2.Point[]
function Layer:getPointList()
	---@type ncdk2.Point[]
	local points = {}
	for _, point in pairs(self.points) do
		table.insert(points, point)
	end
	table.sort(points)
	return points
end

function Layer:validate()
	local points = self:getPointList()
	for i = 1, #points - 1 do
		local p = points[i]
		local next_p = points[i + 1]
		if p.absoluteTime == next_p.absoluteTime then
			print(("points found with equal absoluteTime: %s, %s"):format(p, next_p))
			print(p._interval, next_p._interval, p.absoluteTime, next_p.absoluteTime)
		end
	end
end

function Layer:toInterval() end
function Layer:toAbsolute() end

return Layer
