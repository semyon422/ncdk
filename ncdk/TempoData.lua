local class = require("class")

---@class ncdk.TempoData
---@operator call: ncdk.TempoData
local TempoData = class()

---@param tempo number
function TempoData:new(tempo)
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

---@param a ncdk.TempoData
---@param b ncdk.TempoData
---@return boolean
function TempoData.__eq(a, b)
	return a.timePoint == b.timePoint
end

---@param a ncdk.TempoData
---@param b ncdk.TempoData
---@return boolean
function TempoData.__lt(a, b)
	return a.timePoint < b.timePoint
end

---@param a ncdk.TempoData
---@param b ncdk.TempoData
---@return boolean
function TempoData.__le(a, b)
	return a.timePoint <= b.timePoint
end

return TempoData
