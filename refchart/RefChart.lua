local class = require("class")
local Layer = require("refchart.Layer")
local Notes = require("refchart.Notes")

---@class refchart.RefChart
---@operator call: refchart.RefChart
---@field inputmode ncdk.InputMode
---@field layers {[string]: refchart.Layer}
---@field notes refchart.Note[]
local RefChart = class()

---@param chart ncdk2.Chart
function RefChart:new(chart)
	self.inputmode = chart.inputMode
	self.layers = {}

	---@type {[ncdk2.VisualPoint]: refchart.VisualPointReference}
	local vp_ref = {}

	for l_name, layer in pairs(chart.layers) do
		local _layer = Layer(layer, l_name, vp_ref)
		self.layers[l_name] = _layer
	end

	self.notes = Notes(chart.notes, vp_ref)
end

return RefChart
