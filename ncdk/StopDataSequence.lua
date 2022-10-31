local StopDataSequence = {}

local StopDataSequence_metatable = {}
StopDataSequence_metatable.__index = StopDataSequence

StopDataSequence.new = function(self)
	local stopDataSequence = {}

	stopDataSequence.stopDataCount = 0

	setmetatable(stopDataSequence, StopDataSequence_metatable)

	return stopDataSequence
end

StopDataSequence.addStopData = function(self, ...)
	for _, stopData in ipairs({...}) do
		table.insert(self, stopData)
		self.stopDataCount = self.stopDataCount + 1
	end
end

StopDataSequence.getStopData = function(self, stopDataIndex)
	return self[stopDataIndex]
end

StopDataSequence.getStopDataCount = function(self)
	return self.stopDataCount
end

local sort = function(stopData1, stopData2)
	return stopData1.measureTime < stopData2.measureTime
end

StopDataSequence.sort = function(self)
	return table.sort(self, sort)
end

return StopDataSequence
