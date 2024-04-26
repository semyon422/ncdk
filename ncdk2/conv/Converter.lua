local class = require("class")

---@class ncdk2.Converter
---@operator call: ncdk2.Converter
local Converter = class()

---@param points ncdk2.Point[]
function Converter:convert(points) end

return Converter
