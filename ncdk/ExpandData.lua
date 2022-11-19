local ExpandData = {}

local mt = {__index = ExpandData}

function ExpandData:new(duration)
	local expandData = {}

	expandData.duration = duration

	return setmetatable(expandData, mt)
end

function ExpandData:set(duration)
	local _duration = self.duration
	self.duration = duration
	return _duration ~= duration
end

function mt.__tostring(a)
	return tostring(a.timePoint) .. "," .. a.duration
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

return ExpandData
