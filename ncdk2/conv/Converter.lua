local class = require("class")

---@class ncdk2.Converter
---@operator call: ncdk2.Converter
local Converter = class()

---@param timePoints ncdk2.Point[]
function Converter:convert(timePoints) end

return Converter
