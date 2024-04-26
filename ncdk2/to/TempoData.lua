local class = require("class")

---@class ncdk2.TempoData
---@operator call: ncdk2.TempoData
local TempoData = class()

---@param tempo number
function TempoData:new(tempo)
	self.tempo = tempo
end

---@return number
function TempoData:getBeatDuration()
	return 60 / self.tempo
end

---@param a ncdk.TempoData
---@return string
function TempoData.__tostring(a)
	return ("TempoData(%s)"):format(a.tempo)
end

return TempoData
