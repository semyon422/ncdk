local RangeTracker = require("ncdk.RangeTracker")

local TestObject = {}

local mt = {__index = TestObject}

function TestObject:new(t)
	return setmetatable({t}, mt)
end
function mt.__tostring(a)
	return tostring(a[1])
end
function mt.__eq(a, b)
	return a[1] == b[1]
end
function mt.__lt(a, b)
	return a[1] < b[1]
end
function mt.__le(a, b)
	return a[1] <= b[1]
end

local objs = {}
local function obj(t)
	local _obj = objs[t]
	if _obj then
		return _obj
	end
	objs[t] = TestObject:new(t)
	return objs[t]
end

do
	local rt = RangeTracker:new()
	rt:setRange(0, 10)

	function rt:getTime(object)
		return object[1]
	end

	rt:syncChanges(0)

	rt:resetRedos()
	rt:insert(obj(1))
	rt:insert(obj(2))
	rt:insert(obj(3))
	rt:syncChanges(1)

	rt:resetRedos()
	rt:insert(obj(4))
	rt:insert(obj(5))
	rt:insert(obj(6))
	rt:syncChanges(2)

	rt:resetRedos()
	rt:insert(obj(7))
	rt:insert(obj(8))
	rt:insert(obj(9))
	rt:syncChanges(3)

	assert(rt.count == 9)
	assert(#rt.changes == 9)

	rt:syncChanges(1)
	assert(rt.count == 3)
	assert(#rt.changes == 9)
	rt:syncChanges(2)
	assert(rt.count == 6)
	assert(#rt.changes == 9)
	rt:syncChanges(1)
	assert(#rt.changes == 9)

	rt:resetRedos()
	rt:insert(obj(7))
	assert(#rt.changes == 4)
	rt:syncChanges(2)
	assert(rt.count == 4)
	rt:syncChanges(3)
	assert(rt.count == 4)
end

do
	local rt = RangeTracker:new()
	rt:setRange(0, 10)

	function rt:getTime(object)
		return object[1]
	end

	rt:syncChanges(0)

	rt:resetRedos()
	rt:insert(obj(1))
	rt:insert(obj(2))
	rt:insert(obj(3))
	rt:syncChanges(1)

	rt:resetRedos()
	rt:remove(obj(1))
	rt:remove(obj(2))
	rt:remove(obj(3))
	rt:insert(obj(1))
	rt:insert(obj(2))
	rt:insert(obj(3))
	rt:syncChanges(2)

	assert(#rt.changes == 9)
	assert(rt.count == 3)

	rt:syncChanges(1)

	assert(#rt.changes == 9)
	assert(rt.count == 3)
end

do
	local rt1 = RangeTracker:new()
	rt1:setRange(0, 10)
	local rt2 = RangeTracker:new()
	rt2:setRange(0, 10)

	function rt1:getTime(object)
		return object[1]
	end
	function rt2:getTime(object)
		return object[1]
	end

	rt1:syncChanges(0)
	rt2:syncChanges(0)

	rt1:insert(obj(1))

	rt1:syncChanges(1)
	rt2:syncChanges(1)

	assert(#rt1.changes == 1)
	assert(rt1.count == 1)

	rt1:remove(obj(1))
	rt2:insert(obj(1))

	rt1:syncChanges(2)
	rt2:syncChanges(2)

	assert(#rt1.changes == 2)
	assert(rt1.count == 0)
	assert(#rt2.changes == 1)
	assert(rt2.count == 1)

	rt1:syncChanges(1)
	rt2:syncChanges(1)

	assert(#rt1.changes == 2)
	assert(rt1.count == 1)
	assert(#rt2.changes == 1)
	assert(rt2.count == 0)

	rt1:syncChanges(2)
	rt2:syncChanges(2)

	assert(#rt1.changes == 2)
	assert(rt1.count == 0)
	assert(#rt2.changes == 1)
	assert(rt2.count == 1)


end
