local class = require("class")

local ExpandData = class()

function ExpandData:new(duration)
	self:set(duration)
end

function ExpandData:set(duration)
	local _duration = self.duration
	self.duration = duration
	return _duration ~= duration
end

function ExpandData.__tostring(a)
	return tostring(a.timePoint) .. "," .. a.duration
end

function ExpandData.__eq(a, b)
	return a.timePoint == b.timePoint
end
function ExpandData.__lt(a, b)
	return a.timePoint < b.timePoint
end
function ExpandData.__le(a, b)
	return a.timePoint <= b.timePoint
end

return ExpandData
