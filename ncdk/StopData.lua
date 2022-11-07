local StopData = {}

local mt = {__index = StopData}

function StopData:new()
	return setmetatable({}, mt)
end

function StopData:getDuration()
	return (self.duration * self.signature):tonumber()
end

return StopData
