local class = require("class")

---@class ncdk2.VisualTimePoint
---@operator call: ncdk2.VisualTimePoint
local VisualTimePoint = class()

VisualTimePoint.visualTime = 0
VisualTimePoint.visualSection = 0
VisualTimePoint.currentSpeed = 1
VisualTimePoint.localSpeed = 1
VisualTimePoint.globalSpeed = 1

---@param timePoint ncdk2.TimePoint
function VisualTimePoint:new(timePoint)
	self.timePoint = timePoint
	self.noteDatas = {}
end

return VisualTimePoint
