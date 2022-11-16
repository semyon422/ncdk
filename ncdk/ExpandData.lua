local ExpandData = {}

local mt = {__index = ExpandData}

function ExpandData:new(timePoint, duration)
	local expandData = {}

	expandData.timePoint = timePoint
	expandData.duration = duration

	timePoint.expandData = expandData

	return setmetatable(expandData, mt)
end

function ExpandData:delete()
	local timePoint = self.timePoint
	assert(timePoint.expandData, "This ExpandData is deleted")

	self.timePoint = nil
	timePoint.expandData = nil
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
