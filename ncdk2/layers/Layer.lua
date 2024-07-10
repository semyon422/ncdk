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
	local pointList = {}
	for _, point in pairs(self.points) do
		table.insert(pointList, point)
	end
	table.sort(pointList)
	return pointList
end

return Layer
