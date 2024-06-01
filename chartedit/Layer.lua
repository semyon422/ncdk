local class = require("class")
local rbtree = require("rbtree")
local table_util = require("table_util")
local Point = require("chartedit.Point")
local Interval = require("chartedit.Interval")
local Fraction = require("ncdk.Fraction")

local fraction_0 = Fraction(0)

---@class chartedit.Layer
---@operator call: chartedit.Layer
local Layer = class()

Layer.minBeatDuration = 60 / 1000

function Layer:new()
	self.points_tree = rbtree.new()
	self.search_point = Point()
	self.search_interval = Interval()
end

function Layer:init()
	local ivl_1 = Interval(0, 1)
	local ivl_2 = Interval(1, 1)
	ivl_1.next, ivl_2.prev = ivl_2, ivl_1
	ivl_1.point = self:getPoint(ivl_1, Fraction(0))
	ivl_2.point = self:getPoint(ivl_2, Fraction(0))
	self:compute()
end

---@return chartedit.Point?
function Layer:getFirstPoint()
	local node = self.points_tree:min()
	return node and node.key
end

---@param a table
---@param _prev table?
---@param _next table?
local function insert(a, _prev, _next)
	a.prev, a.next = nil, nil
	if _prev then
		_prev.next = a
		a.prev = _prev
	end
	if _next then
		_next.prev = a
		a.next = _next
	end
end

---@generic T
---@param a T
---@return T?
---@return T?
local function remove(a)
	local prev, next = a.prev, a.next
	if prev then prev.next = next end
	if next then next.prev = prev end
	a.prev, a.next = nil, nil
	return prev, next
end

---@param interval chartedit.Interval
---@param time ncdk.Fraction
---@return chartedit.Point
function Layer:getPoint(interval, time)
	self.search_point:new(interval, time)

	local node = self.points_tree:find(self.search_point)
	if node then
		return node.key
	end

	local point = Point(interval, time)
	node = assert(self.points_tree:insert(point))
	local prev_node = node:prev()
	local next_node = node:next()
	local prev_point = prev_node and prev_node.key
	local next_point = next_node and next_node.key
	insert(point, prev_point, next_point)

	return point
end

---@param object chartedit.Point
---@return chartedit.Point?
---@return chartedit.Point?
function Layer:getInterp(object)
	local a, b = self.points_tree:find(object)
	a = a or b
	if not a then
		return
	end

	---@type chartedit.Point
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

---@param limit number
---@param absoluteTime number
---@return chartedit.Point
function Layer:interpolateAbsolute(limit, absoluteTime)
	local search_point = self.search_point
	local search_interval = self.search_interval

	table_util.clear(search_point)

	local t = absoluteTime
	search_interval:new(t, 1)
	search_point:new(search_interval, fraction_0)

	local a, b = self:getInterp(search_point)
	if not a and not b then
		return
	elseif a == b then
		a:clone(search_point)
		return search_point
	end

	if search_point == a then
		a:clone(search_point)
		return search_point
	end
	if search_point == b then
		b:clone(search_point)
		return search_point
	end

	search_point.prev = a
	search_point.next = b

	a = a or b

	search_point:fromnumber(a.interval, t, limit, a.measure, true)
	search_point.absoluteTime = search_point:tonumber()
	search_point.measure = a.measure

	return search_point
end

function Layer:compute()
	for _, p in self.points_tree:iter() do
		---@cast p chartedit.Point
		p.absoluteTime = p:tonumber()
	end
end

---@return chartedit.Point
function Layer:saveSearchPoint()
	local sp = self.search_point
	local p = self:getPoint(sp:unpack())
	p.absoluteTime = sp.absoluteTime
	return p
end

---@param point chartedit.Point
---@param beats integer
---@return chartedit.Interval
function Layer:_setInterval(point, beats)
	local new_ivl = Interval(point.absoluteTime, beats)
	new_ivl.point = point
	point._interval = new_ivl
	return new_ivl
end

---@param point chartedit.Point
function Layer:splitInterval(point)
	assert(not rawequal(point, self.search_point), "can't split search point")
	local _interval = assert(point.interval)

	local time = point.time
	local _beats = time:floor()

	---@type chartedit.Interval
	local interval
	if time[1] > 0 then
		local beats = _interval.next and _interval.beats - _beats or 1
		interval = self:_setInterval(point, beats)
		insert(interval, _interval, _interval.next)
		_interval.beats = _beats
	else
		interval = self:_setInterval(point, -_beats)
		insert(interval, nil, _interval)
		point = self:getFirstPoint()
	end
	while point and point.interval == _interval do
		point.interval = interval
		point.time = point.time - _beats
		point = point.next
	end
end

---@param point chartedit.Point
function Layer:mergeInterval(point)
	assert(not rawequal(point, self.search_point), "can't merge search point")
	local _interval = point._interval
	if not _interval then
	-- if not _interval or self.ranges.interval.tree.size == 2 then
		return
	end

	point._interval = nil
	local _prev, _next = remove(_interval)

	local _beats, interval
	if _prev then
		_beats = _prev.beats
		_prev.beats = _next and _prev.beats + _interval.beats or 1
		interval = _prev
	elseif _next then
		_beats = -_interval.beats
		point = self:getFirstPoint()
		interval = _next
	end

	while point and point.interval == _interval do
		point.interval = interval
		point.time = point.time + _beats
		point = point.next
	end
end

---@param interval chartedit.Interval
---@param offset number
function Layer:moveInterval(interval, offset)
	if interval.offset == offset then
		return
	end
	local minTime, maxTime = -math.huge, math.huge
	if interval.prev then
		minTime = interval.prev.offset + self.minBeatDuration * interval.prev:getDuration()
	end
	if interval.next then
		maxTime = interval.next.offset - self.minBeatDuration * interval:getDuration()
	end
	if minTime >= maxTime then
		return
	end
	interval.offset = math.min(math.max(offset, minTime), maxTime)
	self:compute()
end

return Layer
