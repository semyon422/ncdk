local class = require("class")

---@class ncdk2.VisualColumns
---@operator call: ncdk2.VisualColumns
local VisualColumns = class()

-- automatically manages visual points for stacked notes

---@param visual ncdk2.Visual
function VisualColumns:new(visual)
	self.visual = visual
	---@type {[ncdk2.Point]: ncdk2.VisualPoint[]}
	self.points = {}
	---@type {[ncdk2.Point]: {[ncdk2.Column]: integer}}
	self.indexes = {}
end

---@param point ncdk2.Point
---@param column ncdk2.Column
function VisualColumns:getPoint(point, column)
	local points = self.points
	local indexes = self.indexes

	points[point] = points[point] or {}
	indexes[point] = indexes[point] or {}
	local _points = points[point]
	local _columns = indexes[point]

	_columns[column] = (_columns[column] or 0) + 1
	local index = _columns[column]
	local vp = _points[index]
	if vp then
		return vp
	end

	vp = self.visual:newPoint(point)
	_points[index] = vp
	return vp
end

return VisualColumns
