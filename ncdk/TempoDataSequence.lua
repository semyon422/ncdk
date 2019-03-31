local TempoDataSequence = {}

local TempoDataSequence_metatable = {}
TempoDataSequence_metatable.__index = TempoDataSequence

TempoDataSequence.new = function(self)
	local tempoDataSequence = {}
	
	tempoDataSequence.tempoDataCount = 0
	
	setmetatable(tempoDataSequence, TempoDataSequence_metatable)
	
	return tempoDataSequence
end

TempoDataSequence.addTempoData = function(self, ...)
	for _, tempoData in ipairs({...}) do
		table.insert(self, tempoData)
		self.tempoDataCount = self.tempoDataCount + 1
	end
end

TempoDataSequence.getTempoData = function(self, tempoDataIndex)
	return self[tempoDataIndex]
end

TempoDataSequence.getTempoDataCount = function(self)
	return self.tempoDataCount
end

TempoDataSequence.getTempoDataByMeasureTime = function(self, measureTime)
	for currentTempoDataIndex = 1, self:getTempoDataCount() do
		local currentTempoData = self:getTempoData(currentTempoDataIndex)
		if (currentTempoDataIndex == self:getTempoDataCount()) or
		   (currentTempoDataIndex == 1 and measureTime < currentTempoData.measureTime)
		then
			return currentTempoData
		end
		
		local nextTempoData = self:getTempoData(currentTempoDataIndex + 1)
		
		if measureTime >= currentTempoData.measureTime and measureTime < nextTempoData.measureTime then
			return currentTempoData
		end
	end
end

local sort = function(tempoData1, tempoData2)
	return tempoData1.measureTime.number < tempoData2.measureTime.number
end

TempoDataSequence.sort = function(self)
	return table.sort(self, sort)
end

return TempoDataSequence
