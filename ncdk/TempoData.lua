local TempoData = {}

local mt = {__index = TempoData}

function TempoData:new(tempo)
	local tempoData = {}

	tempoData.tempo = tempo

	return setmetatable(tempoData, mt)
end

function TempoData:set(tempo)
	local _tempo = self.tempo
	self.tempo = tempo
	return _tempo ~= tempo
end

function TempoData:getBeatDuration()
	return 60 / self.tempo
end

function mt.__tostring(a)
	return tostring(a.timePoint) .. "," .. a.tempo
end

function mt.__eq(a, b)
	return a.timePoint == b.timePoint
end
function mt.__lt(a, b)
	return a.timePoint < b.timePoint
end
function mt.__le(a, b)
	return a.timePoint <= b.timePoint
end

return TempoData
