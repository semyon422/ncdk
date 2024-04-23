local TimePoint = require("ncdk2.tp.TimePoint")

---@class ncdk2.AbsoluteTimePoint: ncdk2.TimePoint
---@operator call: ncdk2.AbsoluteTimePoint
---@field tempoData ncdk2.TempoData?
local AbsoluteTimePoint = TimePoint + {}

return AbsoluteTimePoint
