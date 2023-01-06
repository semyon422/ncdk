local RangeTracker = {}

local mt = {__index = RangeTracker}

RangeTracker.count = 0

function RangeTracker:new()
	return setmetatable({}, mt)
end

function RangeTracker:fromList(list)
	self.count = #list
	self.first = list[1]
	self.last = list[#list]
	self.head = self.first
	self.tail = self.last
	for i = 1, #list do
		list[i].prev = list[i - 1]
		list[i].next = list[i + 1]
	end
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
	print("start", self.head)
	print("end", self.tail)
	print("first", self.first)
	print("last", self.last)
end

function RangeTracker:setRange(startTime, endTime)
	self.startTime, self.endTime = startTime, endTime
	self:update()
end

function RangeTracker:getTime(object)
	error("not implemented")
end

function RangeTracker:getInterp(object)
	if object == self.head then
		return self.head, self.head
	end
	if object == self.first then
		return self.first, self.first
	end
	if object == self.tail then
		return self.tail, self.tail
	end
	if object == self.last then
		return self.last, self.last
	end
	if object < self.first then
		return nil, self.first
	end
	if object > self.last then
		return self.last, nil
	end

	local current = self.head
	while current < self.tail do
		if object == current then
			return current, current
		end
		local next = current.next
		if next and object > current and object < next then
			return current, next
		end
		current = next
	end
end

function RangeTracker:find(object)
	if not self.head then
		return
	end

	local current = self.head
	while current and current <= self.tail do
		if object == current then
			return current
		end
		current = current.next
	end
end

local function assertTime(c)
	return assert(c, "attempt to get an object out of range")
end

function RangeTracker:insert(object)
	local time = assert(self:getTime(object))
	self.count = self.count + 1

	if not self.head then
		self.head = object
		self.first = object
		self.tail = object
		self.last = object
		self:update()
		return
	end

	if self.head ~= self.first then
		assertTime(object > self.head)
	end
	if self.tail ~= self.last then
		assertTime(object < self.tail)
	end

	if object < self.first then
		assertTime(time >= self.startTime)
		addBefore(object, self.first)
		self.first = object
		self:update()
		return
	end
	if object > self.last then
		assertTime(time <= self.endTime)
		addAfter(self.last, object)
		self.last = object
		self:update()
		return
	end

	local current = self.head
	while current <= self.tail do
		local next = current.next
		if not next or object > current and object < next then
			addAfter(current, object)
			break
		end
		current = next
	end
	self:update()
end

function RangeTracker:remove(object)
	if not self.first then
		return
	end
	self.count = self.count - 1

	if self.first == self.last then
		self.head = nil
		self.first = nil
		self.tail = nil
		self.last = nil
		remove(object)
		return
	end

	if self.head ~= self.first then
		assert(object > self.head)
	end
	if self.tail ~= self.last then
		assert(object < self.tail)
	end

	if object == self.first then self.first = object.next end
	if object == self.head then self.head = object.next end
	if object == self.last then self.last = object.prev end
	if object == self.tail then self.tail = object.prev end

	remove(object)

	self:update()
end

function RangeTracker:update()
	local object = self.head
	if not object then
		return
	end

	while self:getTime(object) >= self.startTime do
		local prev = object.prev
		self.head = prev or object
		if not prev then break end
		object = prev
	end
	while self:getTime(object) < self.startTime do
		self.head = object
		local next = object.next
		if not next or self:getTime(next) >= self.startTime then break end
		object = next
	end

	object = self.tail
	while self:getTime(object) <= self.endTime do
		local next = object.next
		self.tail = next or object
		if not next then break end
		object = next
	end
	while self:getTime(object) > self.endTime do
		self.tail = object
		local prev = object.prev
		if not prev or self:getTime(prev) <= self.endTime then break end
		object = prev
	end
end

return RangeTracker
