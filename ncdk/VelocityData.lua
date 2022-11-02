local VelocityData = {}

local mt = {__index = VelocityData}

VelocityData.currentSpeed = 1
VelocityData.localSpeed = 1
VelocityData.globalSpeed = 1
VelocityData.visualEndTimePoint = nil

function VelocityData:new(timePoint)
	assert(not timePoint.velocityData, "This timePoint already has a VelocityData")

	local velocityData = {}

	velocityData.timePoint = timePoint
	timePoint.velocityData = velocityData

	return setmetatable(velocityData, mt)
end

function VelocityData:delete()
	local timePoint = self.timePoint
	assert(timePoint.velocityData, "This VelocityData is deleted")

	self.timePoint = nil
	timePoint.velocityData = nil
end

return VelocityData
