local TempoData = {}

local mt = {__index = TempoData}

function TempoData:new(time, tempo)
	local tempoData = {}

	tempoData.time = time
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
	return a.time .. "," .. a.tempo
end

function mt.__eq(a, b)
	return a.time == b.time
end
function mt.__lt(a, b)
	return a.time < b.time
end
function mt.__le(a, b)
	return a.time <= b.time
end

return TempoData
