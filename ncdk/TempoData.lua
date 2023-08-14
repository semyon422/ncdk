local class = require("class")

local TempoData = class()

function TempoData:new(tempo)
	self:set(tempo)
end

function TempoData:set(tempo)
	local _tempo = self.tempo
	self.tempo = tempo
	return _tempo ~= tempo
end

function TempoData:getBeatDuration()
	return 60 / self.tempo
end

function TempoData.__tostring(a)
	return tostring(a.timePoint) .. "," .. a.tempo
end

function TempoData.__eq(a, b)
	return a.timePoint == b.timePoint
end
function TempoData.__lt(a, b)
	return a.timePoint < b.timePoint
end
function TempoData.__le(a, b)
	return a.timePoint <= b.timePoint
end

return TempoData
