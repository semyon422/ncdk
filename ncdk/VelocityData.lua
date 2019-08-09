local Fraction = require("ncdk.Fraction")

local VelocityData = {}

local VelocityData_metatable = {}
VelocityData_metatable.__index = VelocityData

VelocityData.currentSpeed = Fraction:new(1)
VelocityData.localSpeed = Fraction:new(1)
VelocityData.globalSpeed = Fraction:new(1)
VelocityData.visualEndTimePoint = nil

VelocityData.new = function(self, timePoint)
	local velocityData = {}
	
	velocityData.timePoint = timePoint
	
	if not timePoint.velocityData then
		timePoint.velocityData = velocityData
	else
		error("This timePoint already has a velocityData")
	end
	
	setmetatable(velocityData, VelocityData_metatable)
	
	return velocityData
end

return VelocityData
