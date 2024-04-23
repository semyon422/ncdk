local TimedObject = require("ncdk2.to.TimedObject")

---@class ncdk2.IntervalData: ncdk2.TimedObject
---@operator call: ncdk2.IntervalData
local IntervalData = TimedObject + {}

---@param beats number
function IntervalData:new(beats)
	assert(type(beats) == "number" and beats >= 0 and beats % 1 == 0, "invalid beats: " .. beats)
	self.beats = beats
end

return IntervalData
