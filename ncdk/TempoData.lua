local TempoData = {}

local mt = {__index = TempoData}

function TempoData:new(time, tempo)
	local tempoData = {}

	tempoData.time = time
	tempoData.tempo = tempo

	return setmetatable(tempoData, mt)
end

function TempoData:getBeatDuration()
	return 60 / self.tempo
end

return TempoData
