local class = require("class")

---@class refchart.RefChart
---@operator call: refchart.RefChart
---@field inputmode ncdk.InputMode
---@field layers {[string]: refchart.Layer}
---@field notes refchart.Note[]
local RefChart = class()

return RefChart
