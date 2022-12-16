local IntervalTime = {}

local mt = {__index = IntervalTime}

function IntervalTime:new(intervalData, time)
	local expandData = {}

	expandData.intervalData = intervalData
	expandData.time = time

	return setmetatable(expandData, mt)
end

function IntervalTime:tonumber()
	local id = self.intervalData
	if type(id) == "number" then
		return id
	end
	local _n = id.next
	if not _n then
		local _p = id.prev
		if not _p then
			return 0
		end
		id, _n = _p, id
	end
	local t = id.timePoint.absoluteTime
	if _n then
		t = id.timePoint.absoluteTime + (_n.timePoint.absoluteTime - id.timePoint.absoluteTime) * self.time / id.intervals
	end
	return t
end

function mt.__tostring(a)
	local time = a.intervalData
	if type(time) == "table" then
		time = time.timePoint.absoluteTime
	end
	return time .. "," .. a.time
end

local function isNumbers(a, b)
	local ia, ib = a.intervalData, b.intervalData
	local ta, tb = type(ia) == "table", type(ib) == "table"
	if ta and tb then
		return
	end
	if ta then
		ia = a:tonumber()
	end
	if tb then
		ib = b:tonumber()
	end
	return ia, ib
end

function mt.__eq(a, b)
	local na, nb = isNumbers(a, b)
	if na then
		return na == nb
	end
	return a.intervalData == b.intervalData and a.time == b.time
end
function mt.__lt(a, b)
	local na, nb = isNumbers(a, b)
	if na then
		return na < nb
	end
	return a.intervalData < b.intervalData or a.intervalData == b.intervalData and a.time < b.time
end
function mt.__le(a, b)
	local na, nb = isNumbers(a, b)
	if na then
		return na <= nb
	end
	return a.intervalData < b.intervalData or a.intervalData == b.intervalData and a.time <= b.time
end

return IntervalTime
