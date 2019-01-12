local Fraction = require("ncdk.Fraction")

local VelocityData = {}

local VelocityData_metatable = {}
VelocityData_metatable.__index = VelocityData

VelocityData.new = function(self, timePoint, currentSpeed, localSpeed, globalSpeed, visualEndTimePoint)
	local velocityData = {}
	
	velocityData.timePoint = timePoint
	velocityData.currentSpeed = currentSpeed or Fraction:new(1)
	velocityData.localSpeed = localSpeed or Fraction:new(1)
	velocityData.globalSpeed = globalSpeed or Fraction:new(1)
	velocityData.visualEndTimePoint = visualEndTimePoint
	
	if not timePoint.velocityData then
		timePoint.velocityData = velocityData
	else
		error("This timePoint already has a velocityData")
	end
	
	setmetatable(velocityData, VelocityData_metatable)
	
	return velocityData
end

return VelocityData
