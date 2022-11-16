local VelocityData = {}

local mt = {__index = VelocityData}

VelocityData.currentSpeed = 1
VelocityData.localSpeed = 1
VelocityData.globalSpeed = 1

function VelocityData:new(timePoint, currentSpeed, localSpeed, globalSpeed)
	assert(not timePoint.velocityData, "This timePoint already has a VelocityData")

	local velocityData = {}

	velocityData.timePoint = timePoint
	timePoint.velocityData = velocityData

	velocityData.currentSpeed = currentSpeed
	velocityData.localSpeed = localSpeed
	velocityData.globalSpeed = globalSpeed

	return setmetatable(velocityData, mt)
end

function VelocityData:delete()
	local timePoint = self.timePoint
	assert(timePoint.velocityData, "This VelocityData is deleted")

	self.timePoint = nil
	timePoint.velocityData = nil
end

function mt.__tostring(a)
	return ("%s,%s,%s,%s"):format(a.timePoint, a.currentSpeed, a.localSpeed, a.globalSpeed)
end

function mt.__eq(a, b)
	return a.timePoint == b.timePoint
end
function mt.__lt(a, b)
	return a.timePoint < b.timePoint
end
function mt.__le(a, b)
	return a.timePoint <= b.timePoint
end

return VelocityData
