local StopData = {}

local StopData_metatable = {}
StopData_metatable.__index = StopData

StopData.new = function(self)
	local stopData = {}
	
	setmetatable(stopData, StopData_metatable)
	
	return stopData
end

return StopData
