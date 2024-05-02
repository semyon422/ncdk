local class = require("class")
local InputMode = require("ncdk.InputMode")
local ResourceList = require("ncdk.ResourceList")
local Layer = require("ncdk2.layers.Layer")

---@class ncdk2.Chart
---@operator call: ncdk2.Chart
---@field layers ncdk2.Layer[]
local Chart = class()

function Chart:new()
	self.layers = {}
	self.inputMode = InputMode()
	self.resourceList = ResourceList()
end

---@return function
function Chart:getNotesIterator()
	return coroutine.wrap(function()
		for layerIndex, layer in ipairs(self.layers) do
			for inputType, r in pairs(layer.notes.data) do
				for inputIndex, notes in pairs(r) do
					coroutine.yield(notes, inputType, inputIndex, layerIndex)
				end
			end
		end
	end)
end

---@return function
---@return table
---@return number
function Chart:ilayers()
	return ipairs(self.layers)
end

---@param i number
---@return ncdk2.Layer
function Chart:getLayer(i)
	local layers = self.layers
	if not layers[i] then
		assert(i == #layers + 1)
		layers[i] = Layer()
	end
	return layers[i]
end

function Chart:compute()
	for _, layer in ipairs(self.layers) do
		layer:compute()
	end
end

return Chart
