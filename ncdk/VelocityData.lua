local class = require("class")

local VelocityData = class()

VelocityData.currentSpeed = 1
VelocityData.localSpeed = 1
VelocityData.globalSpeed = 1

function VelocityData:new(currentSpeed, localSpeed, globalSpeed)
	self:set(currentSpeed, localSpeed, globalSpeed)
end

function VelocityData:set(currentSpeed, localSpeed, globalSpeed)
	local _currentSpeed = self.currentSpeed
	self.currentSpeed = currentSpeed
	self.localSpeed = localSpeed
	self.globalSpeed = globalSpeed
	return _currentSpeed ~= currentSpeed
end

function VelocityData.__tostring(a)
	return ("%s,%s,%s,%s"):format(a.timePoint, a.currentSpeed, a.localSpeed, a.globalSpeed)
end

function VelocityData.__eq(a, b)
	return a.timePoint == b.timePoint
end
function VelocityData.__lt(a, b)
	return a.timePoint < b.timePoint
end
function VelocityData.__le(a, b)
	return a.timePoint <= b.timePoint
end

return VelocityData
