local StopData = {}

local mt = {__index = StopData}

function StopData:new()
	return setmetatable({}, mt)
end

return StopData
