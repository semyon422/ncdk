local VelocityData = {}

local mt = {__index = VelocityData}

VelocityData.currentSpeed = 1
VelocityData.localSpeed = 1
VelocityData.globalSpeed = 1

function VelocityData:new(currentSpeed, localSpeed, globalSpeed)
	local velocityData = {}

	velocityData.currentSpeed = currentSpeed
	velocityData.localSpeed = localSpeed
	velocityData.globalSpeed = globalSpeed

	return setmetatable(velocityData, mt)
end

function VelocityData:set(currentSpeed, localSpeed, globalSpeed)
	local _currentSpeed = self.currentSpeed
	self.currentSpeed = currentSpeed
	self.localSpeed = localSpeed
	self.globalSpeed = globalSpeed
	return _currentSpeed ~= currentSpeed
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
