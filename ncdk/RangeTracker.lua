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
	print("end", self.firstObject)
	print("first", self.endObject)
	print("last", self.lastObject)
end

function RangeTracker:setRange(startTime, endTime, callback)
	if self.endTime and startTime > self.endTime then
		self.startTime, self.endTime = self.endTime, endTime
		self:update()
		if callback then callback() end
	end
	self.startTime, self.endTime = startTime, endTime
	self:update()
	if callback then callback() end
end

function RangeTracker:getObjectTime(object)
	error("not implemented")
end

function RangeTracker:insert(object)
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

	local objectTime = self:getObjectTime(object)
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

	local currentTimePoint = self.startObject
	while currentTimePoint <= self.endObject do
		local next = currentTimePoint.next
		if not next or object > currentTimePoint and object < next then
			addAfter(currentTimePoint, object)
			break
		end
		currentTimePoint = next
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
	while self:getObjectTime(object) > self.startTime do
		self.startObject = object
		local prev = object.prev
		if not prev then break end
		object = prev
	end
	while self:getObjectTime(object) <= self.startTime do
		self.startObject = object
		local next = object.next
		if not next or self:getObjectTime(next) >= self.startTime then break end
		object = next
	end

	object = self.endObject
	while self:getObjectTime(object) > self.endTime do
		self.endObject = object
		local prev = object.prev
		if not prev or self:getObjectTime(prev) <= self.endTime then break end
		object = prev
	end
	while self:getObjectTime(object) <= self.endTime do
		self.endObject = object
		local next = object.next
		if not next then break end
		object = next
	end
end

return RangeTracker
