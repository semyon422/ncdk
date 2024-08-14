local class = require("class")
local Layer = require("refchart.Layer")
local Note = require("refchart.Note")
local Point = require("refchart.Point")
local RefChart = require("refchart.RefChart")
local VisualPoint = require("refchart.VisualPoint")
local VisualPointReference = require("refchart.VisualPointReference")

---@class refchart.Refer
---@operator call: refchart.Refer
local Refer = class()

---@param chart ncdk2.Chart
function Refer:new(chart)
	self.chart = chart
end

---@return table
function Refer:ref()
	local chart = self.chart

	local refchart = RefChart()
	refchart.inputmode = chart.inputMode

	self.refchart = refchart

	local _layers, vp_ref = self:refLayers()
	refchart.layers = _layers

	refchart.notes = self:refNotes(vp_ref)

	return refchart
end

---@param layer ncdk2.Layer
---@return refchart.Point[]
---@return {[ncdk2.AbsolutePoint]: integer}
function Refer:refPoints(layer)
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

---@param visual ncdk2.Visual
---@param p_to_index {[ncdk2.AbsolutePoint]: integer}
---@param vp_ref {[ncdk2.VisualPoint]: refchart.VisualPointReference}
---@param l_name string
---@param v_name string
---@return refchart.VisualPoint[]
function Refer:refVisualPoints(visual, p_to_index, vp_ref, l_name, v_name)
	---@type refchart.VisualPoint[]
	local _vps = {}
	for i, vp in ipairs(visual.points) do
		vp_ref[vp] = VisualPointReference(l_name, v_name, i)

		local p = vp.point
		---@cast p ncdk2.AbsolutePoint

		local p_index = p_to_index[p]

		local _vp = VisualPoint()

		_vp.point = p_index
		if vp._expand then
			_vp.expand = vp._expand.duration
		elseif vp._velocity then
			_vp.velocity = {
				vp._velocity.currentSpeed,
				vp._velocity.localSpeed,
				vp._velocity.globalSpeed,
			}
		end

		_vps[i] = _vp
	end

	return _vps
end

---@return {[string]: refchart.Layer}
---@return {[ncdk2.VisualPoint]: refchart.VisualPointReference}
function Refer:refLayers()
	---@type {[string]: refchart.Layer}
	local _layers = {}

	---@type {[ncdk2.VisualPoint]: refchart.VisualPointReference}
	local vp_ref = {}

	for l_name, layer in pairs(self.chart.layers) do
		local _points, p_to_index = self:refPoints(layer)

		local _layer = Layer()
		_layer.points = _points
		_layers[l_name] = _layer

		local visuals = _layer.visuals

		for v_name, visual in pairs(layer.visuals) do
			local _vps = self:refVisualPoints(visual, p_to_index, vp_ref, l_name, v_name)
			visuals[v_name] = _vps
		end
	end

	return _layers, vp_ref
end

---@param vp_ref {[ncdk2.VisualPoint]: refchart.VisualPointReference}
function Refer:refNotes(vp_ref)
	local chart = self.chart

	---@type refchart.Note[]
	local notes = {}
	for i, note in ipairs(chart.notes.notes) do
		local _note = Note()
		_note.point = vp_ref[note.visualPoint]
		_note.column = note.column
		_note.type = note.type
		_note.weight = note.weight
	end

	return notes
end

return Refer
