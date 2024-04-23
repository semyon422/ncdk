local class = require("class")

---@class ncdk2.VisualTimedObject
---@operator call: ncdk2.VisualTimedObject
local VisualTimedObject = class()

---@param visualTimePoint ncdk2.VisualTimePoint
function VisualTimedObject:new(visualTimePoint)
	self.visualTimePoint = visualTimePoint
end

return VisualTimedObject
