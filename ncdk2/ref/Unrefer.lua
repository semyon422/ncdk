local class = require("class")

---@class ncdk2.UnrefPoint
---@operator call: ncdk2.UnrefPoint
---@field time number
---@field tempo number?
---@field measure ncdk.Fraction?
local UnrefPoint = class()

---@class ncdk2.UnrefVisualPoint
---@operator call: ncdk2.UnrefVisualPoint
---@field point integer
---@field expand number?
---@field velocity number[]?
local UnrefVisualPoint = class()

---@class ncdk2.VisualPointReference
---@operator call: ncdk2.VisualPointReference
---@field layer string
---@field visual string
---@field index integer
local VisualPointReference = class()

---@class ncdk2.UnrefLayer
---@operator call: ncdk2.UnrefLayer
---@field points ncdk2.UnrefPoint[]
---@field visuals {[string]: ncdk2.UnrefVisualPoint[]}
local UnrefLayer = class()

---@class ncdk2.UnrefNote
---@operator call: ncdk2.UnrefNote
---@field point ncdk2.VisualPointReference
---@field column ncdk2.Column
---@field type ncdk2.NoteType
---@field weight integer
local UnrefNote = class()

function UnrefLayer:new()
	self.visuals = {}
end

---@class ncdk2.Unrefer
---@operator call: ncdk2.Unrefer
local Unrefer = class()

---@param chart ncdk2.Chart
function Unrefer:new(chart)
	self.chart = chart
end

---@return table
function Unrefer:unref()
	local chart = self.chart

	local unrefed_chart = {
		inputmode = chart.inputMode,
		resources = {},
	}
	self.unrefed_chart = unrefed_chart

	local u_layers, vp_ref = self:unrefLayers()
	unrefed_chart.layers = u_layers

	unrefed_chart.notes = self:unrefNotes(vp_ref)

	return unrefed_chart
end

---@param layer ncdk2.Layer
---@return ncdk2.UnrefPoint[]
---@return {[ncdk2.AbsolutePoint]: integer}
function Unrefer:unrefPoints(layer)
	local points = layer:getPointList()
	---@cast points ncdk2.AbsolutePoint[]

	---@type {[ncdk2.AbsolutePoint]: integer}
	local p_to_index = {}

	---@type ncdk2.UnrefPoint[]
	local u_points = {}
	for i, p in ipairs(points) do
		p_to_index[p] = i

		local u_p = UnrefPoint()

		u_p.time = p.absoluteTime
		if p._tempo then
			u_p.tempo = p._tempo.tempo
		end
		if p._measure then
			u_p.measure = p._measure.offset
		end

		u_points[i] = u_p
	end

	return u_points, p_to_index
end

---@param visual ncdk2.Visual
---@param vp_ref {[ncdk2.AbsolutePoint]: integer}
---@param vp_to_index {[ncdk2.VisualPoint]: ncdk2.VisualPointReference}
---@param l_name string
---@param v_name string
---@return ncdk2.UnrefVisualPoint[]
function Unrefer:unrefVisualPoints(visual, vp_ref, vp_to_index, l_name, v_name)
	---@type ncdk2.UnrefVisualPoint[]
	local u_vps = {}
	for i, vp in ipairs(visual.points) do
		vp_to_index[vp] = {
			layer = l_name,
			visual = v_name,
			index = i,
		}

		local p = vp.point
		---@cast p ncdk2.AbsolutePoint

		local p_index = vp_ref[p]

		local u_vp = UnrefVisualPoint()

		u_vp.point = p_index
		if vp._expand then
			u_vp.expand = vp._expand.duration
		elseif vp._velocity then
			u_vp.velocity = {
				vp._velocity.currentSpeed,
				vp._velocity.localSpeed,
				vp._velocity.globalSpeed,
			}
		end

		u_vps[i] = u_vp
	end

	return u_vps
end

---@return {[string]: ncdk2.UnrefLayer}
---@return {[ncdk2.VisualPoint]: ncdk2.VisualPointReference}
function Unrefer:unrefLayers()
	---@type {[string]: ncdk2.UnrefLayer}
	local u_layers = {}

	---@type {[ncdk2.VisualPoint]: ncdk2.VisualPointReference}
	local vp_ref = {}

	for l_name, layer in pairs(self.chart.layers) do
		local u_points, p_to_index = self:unrefPoints(layer)

		local u_layer = UnrefLayer()
		u_layer.points = u_points
		u_layers[l_name] = u_layer

		local visuals = u_layer.visuals

		for v_name, visual in pairs(layer.visuals) do
			local u_vps = self:unrefVisualPoints(visual, p_to_index, vp_ref, l_name, v_name)
			visuals[v_name] = u_vps
		end
	end

	return u_layers, vp_ref
end

---@param vp_ref {[ncdk2.VisualPoint]: ncdk2.VisualPointReference}
function Unrefer:unrefNotes(vp_ref)
	local chart = self.chart

	---@type ncdk2.UnrefNote[]
	local notes = {}
	for i, note in ipairs(chart.notes.notes) do
		local u_note = UnrefNote()
		u_note.point = vp_ref[note.visualPoint]
		u_note.column = note.column
		u_note.type = note.type
		u_note.weight = note.weight
	end

	return notes
end

return Unrefer
