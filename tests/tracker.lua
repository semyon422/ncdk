local RangeTracker = require("ncdk.RangeTracker")
local class = require("class")

local TestObject = class()

function TestObject:new(t)
	self[1] = t
end
function TestObject.__tostring(a)
	return tostring(a[1])
end
function TestObject.__eq(a, b)
	return a[1] == b[1]
end
function TestObject.__lt(a, b)
	return a[1] < b[1]
end
function TestObject.__le(a, b)
	return a[1] <= b[1]
end

local objs = {}
local function obj(t)
	local _obj = objs[t]
	if _obj then
		return _obj
	end
	objs[t] = TestObject(t)
	return objs[t]
end

do
	local rt = RangeTracker()
	rt:setRange(0, 10)

	function rt.getTime(object)
		return object[1]
	end

	local changes = 0
	function rt.getChangeOffset()
		return changes
	end
	local function sync(offset)
		changes = offset
		rt:syncChanges()
	end

	sync(0)

	rt:resetRedos()
	rt:insert(obj(1))
	rt:insert(obj(2))
	rt:insert(obj(3))
	sync(1)

	rt:resetRedos()
	rt:insert(obj(4))
	rt:insert(obj(5))
	rt:insert(obj(6))
	sync(2)

	rt:resetRedos()
	rt:insert(obj(7))
	rt:insert(obj(8))
	rt:insert(obj(9))
	sync(3)

	assert(rt.tree.size == 9)
	assert(#rt.changes == 9)

	sync(1)
	assert(rt.tree.size == 3)
	assert(#rt.changes == 9)
	sync(2)
	assert(rt.tree.size == 6)
	assert(#rt.changes == 9)
	sync(1)
	assert(#rt.changes == 9)

	rt:resetRedos()
	rt:insert(obj(7))
	assert(#rt.changes == 4)
	sync(2)
	assert(rt.tree.size == 4)
	sync(3)
	assert(rt.tree.size == 4)
end

do
	local rt = RangeTracker()
	rt:setRange(0, 10)

	function rt.getTime(object)
		return object[1]
	end

	local changes = 0
	function rt.getChangeOffset()
		return changes
	end
	local function sync(offset)
		changes = offset
		rt:syncChanges()
	end

	sync(0)

	rt:resetRedos()
	rt:insert(obj(1))
	rt:insert(obj(2))
	rt:insert(obj(3))
	sync(1)

	rt:resetRedos()
	rt:remove(obj(1))
	rt:remove(obj(2))
	rt:remove(obj(3))
	rt:insert(obj(1))
	rt:insert(obj(2))
	rt:insert(obj(3))
	sync(2)

	assert(#rt.changes == 9)
	assert(rt.tree.size == 3)

	sync(1)

	assert(#rt.changes == 9)
	assert(rt.tree.size == 3)
end

do
	local rts = {}
	local changes = 0
	for i = 1, 4 do
		local rt = RangeTracker()
		function rt.getTime(object)
			return object[1]
		end
		function rt.getChangeOffset()
			return changes
		end
		rt:setRange(0, 10)
		rts[i] = rt
	end

	local function sync(offset)
		changes = offset
		for i = 1, 4 do
			rts[i]:syncChanges()
		end
	end

	sync(0)

	rts[1]:insert(obj(1))
	sync(1)

	rts[4]:insert(obj(1))
	sync(2)

	rts[1]:remove(obj(1))
	rts[2]:insert(obj(1))
	sync(3)

	rts[4]:remove(obj(1))
	rts[3]:insert(obj(1))
	sync(4)

	assert(rts[1].tree.size == 0)
	assert(rts[2].tree.size == 1)
	assert(rts[3].tree.size == 1)
	assert(rts[4].tree.size == 0)

	sync(3)

	assert(rts[1].tree.size == 0)
	assert(rts[2].tree.size == 1)
	assert(rts[3].tree.size == 0)
	assert(rts[4].tree.size == 1)

	sync(2)

	assert(rts[1].tree.size == 1)
	assert(rts[2].tree.size == 0)
	assert(rts[3].tree.size == 0)
	assert(rts[4].tree.size == 1)
end
