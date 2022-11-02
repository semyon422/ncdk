local TempoDataSequence = {}

local mt = {__index = TempoDataSequence}

function TempoDataSequence:new()
	local tempoDataSequence = {}

	tempoDataSequence.tempoDataCount = 0

	return setmetatable(tempoDataSequence, mt)
end

function TempoDataSequence:addTempoData(...)
	for _, tempoData in ipairs({...}) do
		table.insert(self, tempoData)
		self.tempoDataCount = self.tempoDataCount + 1
	end
end

function TempoDataSequence:getTempoData(tempoDataIndex)
	return self[tempoDataIndex]
end

function TempoDataSequence:getTempoDataCount()
	return self.tempoDataCount
end

function TempoDataSequence:getTempoDataByTime(time)
	for currentTempoDataIndex = 1, self:getTempoDataCount() do
		local currentTempoData = self:getTempoData(currentTempoDataIndex)
		if (currentTempoDataIndex == self:getTempoDataCount()) or
		   (currentTempoDataIndex == 1 and time < currentTempoData.time)
		then
			return currentTempoData
		end

		local nextTempoData = self:getTempoData(currentTempoDataIndex + 1)

		if time >= currentTempoData.time and time < nextTempoData.time then
			return currentTempoData
		end
	end
end

local function sort(tempoData1, tempoData2)
	return tempoData1.time < tempoData2.time
end

function TempoDataSequence:sort()
	return table.sort(self, sort)
end

return TempoDataSequence
