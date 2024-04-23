local TimedObject = require("ncdk2.to.TimedObject")

---@class ncdk2.TempoData: ncdk2.TimedObject
---@operator call: ncdk2.TempoData
local TempoData = TimedObject + {}

---@param timePoint ncdk2.TimePoint
---@param tempo number
function TempoData:new(timePoint, tempo)
	TimedObject.new(self, timePoint)
	self:set(tempo)
end

---@param tempo number
---@return boolean
function TempoData:set(tempo)
	local _tempo = self.tempo
	self.tempo = tempo
	return _tempo ~= tempo
end

---@return number
function TempoData:getBeatDuration()
	return 60 / self.tempo
end

---@param a ncdk.TempoData
---@return string
function TempoData.__tostring(a)
	return tostring(a.timePoint) .. "," .. a.tempo
end

TempoData.__eq = TimedObject.__eq
TempoData.__lt = TimedObject.__lt
TempoData.__le = TimedObject.__le

return TempoData
