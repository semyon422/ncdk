local Interpolator = require("ncdk2.Interpolator")
local class = require("class")

local test = {}

local Obj = class()

function Obj:new(time)
	self.time = time
end

function Obj:compare(obj)
	return self.time < obj.time
end

function test.basic(t)
	local itp = Interpolator()

	local objs = {
		Obj(1),
		Obj(2),  -- <- this should be selected for Obj(2)
		Obj(2),
		Obj(2),
		Obj(3),
	}

	local obj = Obj(2)
	for i = 1, #objs do
		t:eq(itp:getBaseIndex(objs, i, obj), 2)
	end
end

function test.is_ok(t)
	local itp = Interpolator()

	local objs = {
		Obj(1),
		Obj(2),
		Obj(2),
		Obj(2),
		Obj(3),
	}

	t:assert(itp:isOk({Obj(1)}, 1, Obj(1)))
	t:assert(itp:isOk({Obj(1), Obj(1)}, 1, Obj(1)))
	t:assert(not itp:isOk({Obj(1), Obj(1)}, 2, Obj(1)))

	local obj = Obj(1.5)
	t:assert(itp:isOk(objs, 1, obj))
	t:assert(not itp:isOk(objs, 2, obj))
	t:assert(not itp:isOk(objs, 3, obj))
	t:assert(not itp:isOk(objs, 4, obj))
	t:assert(not itp:isOk(objs, 5, obj))

	obj = Obj(2)
	t:assert(not itp:isOk(objs, 1, obj))
	t:assert(itp:isOk(objs, 2, obj))
	t:assert(not itp:isOk(objs, 3, obj))
	t:assert(not itp:isOk(objs, 4, obj))
	t:assert(not itp:isOk(objs, 5, obj))

	obj = Obj(2.5)
	t:assert(not itp:isOk(objs, 1, obj))
	t:assert(not itp:isOk(objs, 2, obj))
	t:assert(not itp:isOk(objs, 3, obj))
	t:assert(itp:isOk(objs, 4, obj))
	t:assert(not itp:isOk(objs, 5, obj))
end

return test
