local StopData = {}

local StopData_metatable = {}
StopData_metatable.__index = StopData

StopData.new = function(self, measureTime, measureDuration)
	local stopData = {}
	
	stopData.measureTime = measureTime
	stopData.measureDuration = measureDuration
	
	setmetatable(stopData, StopData_metatable)
	
	return stopData
end

return StopData
