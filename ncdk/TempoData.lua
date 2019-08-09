local TempoData = {}

local TempoData_metatable = {}
TempoData_metatable.__index = TempoData

TempoData.new = function(self, time, tempo)
	local tempoData = {}
	
	tempoData.time = time
	tempoData.tempo = tempo
	
	setmetatable(tempoData, TempoData_metatable)
	
	return tempoData
end

TempoData.getBeatDuration = function(self)
	return 60 / self.tempo
end

return TempoData
