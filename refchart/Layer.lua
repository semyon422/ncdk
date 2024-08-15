local class = require("class")
local Point = require("refchart.Point")
local Visual = require("refchart.Visual")

---@class refchart.Layer
---@operator call: refchart.Layer
---@field points refchart.Point[]
---@field visuals {[string]: refchart.VisualPoint[]}
local Layer = class()

---@param layer ncdk2.Layer
---@param l_name string
---@param vp_ref {[ncdk2.VisualPoint]: refchart.VisualPointReference}
function Layer:new(layer, l_name, vp_ref)
	---@type {[ncdk2.AbsolutePoint]: integer}
	local p_to_index = {}

	self.points = {}
	local _points = self.points
	for i, p in ipairs(layer:getPointList() --[=[@as ncdk2.AbsolutePoint[]]=]) do
		p_to_index[p] = i
		_points[i] = Point(p)
	end

	self.visuals = {}
	local visuals = self.visuals
	for v_name, visual in pairs(layer.visuals) do
		visuals[v_name] = Visual(visual, p_to_index, vp_ref, l_name, v_name)
	end
end

return Layer
