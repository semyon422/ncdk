local class = require("class")
local InputMode = require("ncdk.InputMode")
local ResourceList = require("ncdk.ResourceList")

---@class ncdk2.Chart
---@operator call: ncdk2.Chart
---@field layers {[string]: ncdk2.Layer}
local Chart = class()

function Chart:new()
	self.layers = {}
	self.inputMode = InputMode()
	self.resourceList = ResourceList()
end

---@return function
function Chart:getNotesIterator()
	return coroutine.wrap(function()
		for layerIndex, layer in pairs(self.layers) do
			for column, notes in layer.notes:iter() do
				coroutine.yield(notes, column, layerIndex, layer)
			end
		end
	end)
end

function Chart:compute()
	for _, layer in pairs(self.layers) do
		layer:compute()
	end
end

return Chart
