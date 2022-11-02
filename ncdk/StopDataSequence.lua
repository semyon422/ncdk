local StopDataSequence = {}

local mt = {__index = StopDataSequence}

function StopDataSequence:new()
	local stopDataSequence = {}

	stopDataSequence.stopDataCount = 0

	return setmetatable(stopDataSequence, mt)
end

function StopDataSequence:addStopData(...)
	for _, stopData in ipairs({...}) do
		table.insert(self, stopData)
		self.stopDataCount = self.stopDataCount + 1
	end
end

function StopDataSequence:getStopData(stopDataIndex)
	return self[stopDataIndex]
end

function StopDataSequence:getStopDataCount()
	return self.stopDataCount
end

local function sort(stopData1, stopData2)
	return stopData1.measureTime < stopData2.measureTime
end

function StopDataSequence:sort()
	return table.sort(self, sort)
end

return StopDataSequence
