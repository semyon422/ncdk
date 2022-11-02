local VelocityData = {}

local mt = {__index = VelocityData}

VelocityData.currentSpeed = 1
VelocityData.localSpeed = 1
VelocityData.globalSpeed = 1
VelocityData.visualEndTimePoint = nil

function VelocityData:new(timePoint)
	assert(not timePoint.velocityData, "This timePoint already has a velocityData")

	local velocityData = {}

	velocityData.timePoint = timePoint
	timePoint.velocityData = velocityData

	return setmetatable(velocityData, mt)
end

return VelocityData
