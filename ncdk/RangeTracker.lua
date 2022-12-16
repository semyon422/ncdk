local RangeTracker = {}

local mt = {__index = RangeTracker}

function RangeTracker:new()
	return setmetatable({}, mt)
end

local function addAfter(a, b)
	b.prev = a
	if a.next then
		b.next = a.next
		a.next.prev = b
	end
	a.next = b
end

local function addBefore(a, b)
	a.next = b
	if b.prev then
		a.prev = b.prev
		b.prev.next = a
	end
	b.prev = a
end

local function remove(a)
	local prev, next = a.prev, a.next
	if prev then prev.next = next end
	if next then next.prev = prev end
	a.prev, a.next = nil, nil
end

function RangeTracker:printRanges()
	print("start", self.startObject)
	print("end", self.endObject)
	print("first", self.firstObject)
	print("last", self.lastObject)
end

function RangeTracker:setRange(startTime, endTime)
	self.startTime, self.endTime = startTime, endTime
	self:update()
end

function RangeTracker:getObjectTime(object)
	error("not implemented")
end

function RangeTracker:getInterp(object)
	if object == self.startObject then
		return self.startObject, self.startObject
	end
	if object == self.firstObject then
		return self.firstObject, self.firstObject
	end
	if object == self.endObject then
		return self.endObject, self.endObject
	end
	if object == self.lastObject then
		return self.lastObject, self.lastObject
	end
	if object < self.firstObject then
		return nil, self.firstObject
	end
	if object > self.lastObject then
		return self.lastObject, nil
	end

	-- if self.startObject ~= self.firstObject and object < self.startObject then
	-- 	return
	-- end
	-- if self.endObject ~= self.lastObject and object > self.endObject then
	-- 	return
	-- end

	local currentObject = self.startObject
	while currentObject < self.endObject do
		if object == currentObject then
			return currentObject, currentObject
		end
		local next = currentObject.next
		if next and object > currentObject and object < next then
			return currentObject, next
		end
		currentObject = next
	end
end

function RangeTracker:insert(object)
	local objectTime = assert(self:getObjectTime(object))

	if not self.startObject then
		self.startObject = object
		self.firstObject = object
		self.endObject = object
		self.lastObject = object
		self:update()
		return
	end

	if self.startObject ~= self.firstObject then
		assert(object > self.startObject)
	end
	if self.endObject ~= self.lastObject then
		assert(object < self.endObject)
	end

	if object < self.firstObject then
		assert(objectTime >= self.startTime, "attempt to get a time point out of range")
		addBefore(object, self.firstObject)
		self.firstObject = object
		self:update()
		return
	end
	if object > self.lastObject then
		assert(objectTime <= self.endTime, "attempt to get a time point out of range")
		addAfter(self.lastObject, object)
		self.lastObject = object
		self:update()
		return
	end

	local currentObject = self.startObject
	while currentObject <= self.endObject do
		local next = currentObject.next
		if not next or object > currentObject and object < next then
			addAfter(currentObject, object)
			break
		end
		currentObject = next
	end
	self:update()
end

function RangeTracker:remove(object)
	if not self.firstObject then
		return
	end
	if self.firstObject == self.lastObject then
		self.startObject = nil
		self.firstObject = nil
		self.endObject = nil
		self.lastObject = nil
		remove(object)
		return
	end

	if self.startObject ~= self.firstObject then
		assert(object > self.startObject)
	end
	if self.endObject ~= self.lastObject then
		assert(object < self.endObject)
	end

	if object == self.firstObject then self.firstObject = object.next end
	if object == self.startObject then self.startObject = object.next end
	if object == self.lastObject then self.lastObject = object.prev end
	if object == self.endObject then self.endObject = object.prev end

	remove(object)

	self:update()
end

function RangeTracker:update()
	local object = self.startObject
	if not object then
		return
	end

	while self:getObjectTime(object) >= self.startTime do
		local prev = object.prev
		self.startObject = prev or object
		if not prev then break end
		object = prev
	end
	while self:getObjectTime(object) < self.startTime do
		self.startObject = object
		local next = object.next
		if not next or self:getObjectTime(next) >= self.startTime then break end
		object = next
	end

	object = self.endObject
	while self:getObjectTime(object) <= self.endTime do
		local next = object.next
		self.endObject = next or object
		if not next then break end
		object = next
	end
	while self:getObjectTime(object) > self.endTime do
		self.endObject = object
		local prev = object.prev
		if not prev or self:getObjectTime(prev) <= self.endTime then break end
		object = prev
	end
end

return RangeTracker
