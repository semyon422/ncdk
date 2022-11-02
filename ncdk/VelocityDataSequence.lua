local VelocityDataSequence = {}

local mt = {__index = VelocityDataSequence}

function VelocityDataSequence:new()
	local velocityDataSequence = {}

	velocityDataSequence.velocityDataCount = 0

	return setmetatable(velocityDataSequence, mt)
end

function VelocityDataSequence:addVelocityData(...)
	for _, velocityData in ipairs({...}) do
		table.insert(self, velocityData)
		self.velocityDataCount = self.velocityDataCount + 1
	end
end

function VelocityDataSequence:removeLastVelocityData()
	self[self.velocityDataCount].timePoint.velocityData = nil
	table.remove(self, self.velocityDataCount)
	self.velocityDataCount = self.velocityDataCount - 1
end

function VelocityDataSequence:getVelocityData(velocityDataIndex)
	return self[velocityDataIndex]
end

function VelocityDataSequence:getVelocityDataCount()
	return self.velocityDataCount
end

function VelocityDataSequence:getVelocityDataByTimePoint(timePoint)
	for currentVelocityDataIndex = 1, self:getVelocityDataCount() do
		local currentVelocityData = self:getVelocityData(currentVelocityDataIndex)
		if (currentVelocityDataIndex == self:getVelocityDataCount()) or
		   (currentVelocityDataIndex == 1 and timePoint < currentVelocityData.timePoint)
		then
			return currentVelocityData, currentVelocityDataIndex
		end

		local nextVelocityData = self:getVelocityData(currentVelocityDataIndex + 1)

		if timePoint >= currentVelocityData.timePoint and timePoint < nextVelocityData.timePoint then
			return currentVelocityData, currentVelocityDataIndex
		end
	end
end

local function sort(velocityData1, velocityData2)
	return velocityData1.timePoint < velocityData2.timePoint
end

function VelocityDataSequence:sort()
	return table.sort(self, sort)
end

return VelocityDataSequence
