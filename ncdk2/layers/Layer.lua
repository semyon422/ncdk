local class = require("class")
local table_util = require("table_util")
local Point = require("ncdk2.tp.Point")
local Notes = require("ncdk2.notes.Notes")
local Visual = require("ncdk2.visual.Visual")

---@class ncdk2.Layer
---@operator call: ncdk2.Layer
---@field points {[string]: ncdk2.Point}
local Layer = class()

function Layer:new()
	self.notes = Notes()
	self.points = {}
	self.testPoint = self:newPoint()
	self.visual = Visual()
end

---@param ... any
---@return ncdk2.Point
function Layer:newPoint(...)
	return Point(...)
end

function Layer:compute()
	---@type {[ncdk2.Point]: true}
	local p_has_vp = {}
	for _, vp in ipairs(self.visual.points) do
		p_has_vp[vp.point] = true
	end
	for _, p in pairs(self.points) do
		if not p_has_vp[p] then
			self.visual:newPoint(p)  -- each Point should have at least one VisualPoint
		end
	end

	table_util.clear(self.testPoint)
	self.visual:compute()
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
