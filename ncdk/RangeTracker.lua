local rbtree = require("rbtree")

local RangeTracker = {}

local mt = {__index = RangeTracker}

RangeTracker.debugChanges = false
RangeTracker.noHistory = false

local function cleanObject(a)
	a.prev, a.next = nil, nil
end

local function remove(a)
	local prev, next = a.prev, a.next
	if prev then prev.next = next end
	if next then next.prev = prev end
	cleanObject(a)
end

local function insert(a, _prev, _next)
	cleanObject(a)
	if _prev then
		_prev.next = a
		a.prev = _prev
	end
	if _next then
		_next.prev = a
		a.next = _next
	end
end

function RangeTracker:new()
	local tree = rbtree.new()

	local rt = {
		changes = {},
		changeCursor = 0,
		tree = tree,
	}

	function tree:findsub(key)
		local y
		local x = self.root
		while x and key ~= rt:getTime(x.key) do
			y = x
			if key < rt:getTime(x.key) then
				x = x.left
			else
				x = x.right
			end
		end
		return x, y
	end

	return setmetatable(rt, mt)
end

function RangeTracker:addChange(action, object)
	if self.noHistory then
		return
	end
	if self.debugChanges then
		print("add", action, object)
	end
	local offset = self:getChangeOffset()
	local changes = self.changes

	local change = {
		offset = offset,
		action = action,
		object = object,
	}
	table.insert(changes, change)
	self.changeCursor = #changes

	return change
end

function RangeTracker:resetChanges()
	self.changes = {}
	self.changeCursor = 0
end

function RangeTracker:resetRedos()
	local changes = self.changes
	for i = self.changeCursor + 1, #changes do
		changes[i] = nil
	end
end

function RangeTracker:undoChange(change)
	if self.noHistory then
		return
	end
	if self.debugChanges then
		print("undo", change.action, change.object)
	end
	if change.action == "insert" then
		assert(self.tree:remove(change.object))
		remove(change.object)
	elseif change.action == "remove" then
		self.tree:insert(change.object)
		insert(change.object, change.prev, change.next)
	end

	self:update()

	self.changeCursor = self.changeCursor - 1
end

function RangeTracker:redoChange(change)
	if self.noHistory then
		return
	end
	if self.debugChanges then
		print("redo", change.action, change.object)
	end
	if change.action == "insert" then
		local node = self.tree:insert(change.object)
		local _prev, _next = node:prev(), node:next()
		insert(node.key, _prev and _prev.key, _next and _next.key)
	elseif change.action == "remove" then
		assert(self.tree:remove(change.object))
		remove(change.object)
	end

	self:update()

	self.changeCursor = self.changeCursor + 1
end

function RangeTracker:syncChanges()
	if self.noHistory then
		return
	end
	local newOffset = self:getChangeOffset()
	local changes = self.changes

	local changePrev = changes[self.changeCursor]
	while changePrev and changePrev.offset >= newOffset do
		self:undoChange(changePrev)
		changePrev = changes[self.changeCursor]
	end

	local changeNext = changes[self.changeCursor + 1]
	while changeNext and changeNext.offset < newOffset do
		self:redoChange(changeNext)
		changeNext = changes[self.changeCursor + 1]
	end
end

function RangeTracker:fromList(list)
	local tree = self.tree
	for i = 1, #list do
		tree:insert(list[i])
	end
	local prev_node
	for node in tree:iter() do
		if prev_node then
			prev_node.key.next = node.key
			node.key.prev = prev_node.key
		end
		prev_node = node
	end
	self:update()
end

function RangeTracker:toList()
	local list, i = {}, 1
	for node in self.tree:iter() do
		list[i], i = node.key, i + 1
	end
	return list
end

function RangeTracker:setRange(startTime, endTime)
	self.startTime, self.endTime = startTime, endTime
	self:update()
end

function RangeTracker:getTime(object)
	error("not implemented")
end

function RangeTracker:getChangeOffset()
	error("not implemented")
end

function RangeTracker:getInterp(object)
	local a, b = self.tree:find(object)
	a = a or b
	if not a then
		return
	end

	local key = a.key
	if key == object then
		return key, key
	elseif object > key then
		local _next = a:next()
		return key, _next and _next.key
	elseif object < key then
		local _prev = a:prev()
		return _prev and _prev.key, key
	end
end

function RangeTracker:find(object)
	local node = self.tree:find(object)
	return node and node.key
end

function RangeTracker:insert(object)
	local node = self.tree:insert(object)
	if not node then
		return
	end

	self:addChange("insert", object)

	local _prev, _next = node:prev(), node:next()
	insert(node.key, _prev and _prev.key, _next and _next.key)

	self:update()

	return object
end

function RangeTracker:remove(object)
	local change = self:addChange("remove", object)
	if change then
		change.prev = object.prev
		change.next = object.next
	end

	assert(self.tree:remove(object))
	remove(object)

	self:update()

	return object
end

function RangeTracker:update()
	local a, b = self.tree:findsub(self.startTime)
	a = a or b
	if a then
		self.head = (a:prev() or a).key
	else
		self.head = nil
	end

	a, b = self.tree:findsub(self.endTime)
	a = a or b
	if a then
		self.tail = (a:next() or a).key
	else
		self.tail = nil
	end

	a = self.tree:min()
	self.first = a and a.key

	a = self.tree:max()
	self.last = a and a.key
end

return RangeTracker
