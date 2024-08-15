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
	local _points, p_to_index = self:refPoints(layer)
	self.points = _points

	self.visuals = {}
	local visuals = self.visuals

	for v_name, visual in pairs(layer.visuals) do
		visuals[v_name] = Visual(visual, p_to_index, vp_ref, l_name, v_name)
	end
end

---@param layer ncdk2.Layer
---@return refchart.Point[]
---@return {[ncdk2.AbsolutePoint]: integer}
function Layer:refPoints(layer)
	local points = layer:getPointList()
	---@cast points ncdk2.AbsolutePoint[]

	---@type {[ncdk2.AbsolutePoint]: integer}
	local p_to_index = {}

	---@type refchart.Point[]
	local _points = {}
	for i, p in ipairs(points) do
		p_to_index[p] = i

		local _p = Point()

		_p.time = p.absoluteTime
		if p._tempo then
			_p.tempo = p._tempo.tempo
		end
		if p._measure then
			_p.measure = p._measure.offset
		end

		_points[i] = _p
	end

	return _points, p_to_index
end

return Layer
