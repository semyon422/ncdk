local class = require("class")
local InputMode = require("ncdk.InputMode")
local ResourceList = require("ncdk.ResourceList")
local Notes = require("ncdk2.notes.Notes")

---@class ncdk2.Chart
---@operator call: ncdk2.Chart
---@field layers {[string]: ncdk2.Layer}
local Chart = class()

function Chart:new()
	self.layers = {}
	self.notes = Notes()
	self.inputMode = InputMode()
	self.resourceList = ResourceList()
end

---@return ncdk2.Visual[]
function Chart:getVisuals()
	local visuals = {}
	for _, layer in pairs(self.layers) do
		table.insert(visuals, layer.visual)
	end
	return visuals
end

---@param vp ncdk2.VisualPoint
---@return ncdk2.Visual?
function Chart:getVisualByPoint(vp)
	for _, layer in pairs(self.layers) do
		if layer.visual.points_map[vp] then
			return layer.visual
		end
	end
end

function Chart:compute()
	for _, layer in pairs(self.layers) do
		layer:compute()
	end
	self.notes:validate()
end

return Chart
