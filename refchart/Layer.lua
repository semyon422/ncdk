local class = require("class")

---@class refchart.Layer
---@operator call: refchart.Layer
---@field points refchart.Point[]
---@field visuals {[string]: refchart.VisualPoint[]}
local Layer = class()

function Layer:new()
	self.visuals = {}
end

return Layer
