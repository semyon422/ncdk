local IntervalTimePoint = require("ncdk2.tp.IntervalTimePoint")

---@class ncdk2.ReferenceIntervalTimePoint: ncdk2.IntervalTimePoint
---@operator call: ncdk2.ReferenceIntervalTimePoint
local ReferenceIntervalTimePoint = IntervalTimePoint + {}

function ReferenceIntervalTimePoint:new(time, beats, offset)
	self.time = time
	self.beats = beats
	self.offset = offset
end

return ReferenceIntervalTimePoint
