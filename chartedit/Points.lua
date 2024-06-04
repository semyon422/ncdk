local class = require("class")
local table_util = require("table_util")
local rbtree = require("rbtree")
local Fraction = require("ncdk.Fraction")
local Point = require("chartedit.Point")
local Interval = require("chartedit.Interval")

local fraction_0 = Fraction(0)

---@class chartedit.Points
---@operator call: chartedit.Points
local Points = class()

---@param on_create function?
---@param on_remove function?
function Points:new(on_create, on_remove)
	self.on_create = on_create
	self.on_remove = on_remove
	self.points_tree = rbtree.new()
	self.search_point = Point()
	self.search_interval = Interval()
	self:initDefault()
end

function Points:initDefault()
	local ivl_1 = Interval(0, 1)
	local ivl_2 = Interval(1, 1)
	ivl_1.next, ivl_2.prev = ivl_2, ivl_1
	ivl_1.point = self:getPoint(ivl_1, Fraction(0))
	ivl_2.point = self:getPoint(ivl_2, Fraction(0))
	ivl_1.point._interval = ivl_1
	ivl_2.point._interval = ivl_2
	self:compute()
end

---@return chartedit.Point?
function Points:getFirstPoint()
	local node = self.points_tree:min()
	return node and node.key
end

---@param interval chartedit.Interval
---@param time ncdk.Fraction
---@return chartedit.Point
function Points:getPoint(interval, time)
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
	table_util.insert_linked(point, prev_point, next_point)
	if self.on_create then
		self.on_create(point)
	end

	return point
end

---@param point chartedit.Point
function Points:removePoint(point)
	assert(not rawequal(point, self.search_point), "can't remove search point")

	if self.on_remove then
		self.on_remove(point)
	end
	local node = self.points_tree:remove(point)
	table_util.remove_linked(point)

	--TODO: notes, sv
end

---@param object chartedit.Point
---@return chartedit.Point?
---@return chartedit.Point?
function Points:getInterp(object)
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

---@param interval chartedit.Interval
---@param time ncdk.Fraction
---@return chartedit.Point?
function Points:interpolateFraction(interval, time)
	local search_point = self.search_point

	search_point:new(interval, time)

	local a, b = self:getInterp(search_point)
	if not a and not b then
		return
	elseif a == b then
		return a:clone(search_point)
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

	search_point.absoluteTime = search_point:tonumber()
	search_point.measure = a.measure

	return search_point
end

---@param limit number
---@param absoluteTime number
---@return chartedit.Point
function Points:interpolateAbsolute(limit, absoluteTime)
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

function Points:compute()
	for _, p in self.points_tree:iter() do
		---@cast p chartedit.Point
		p.absoluteTime = p:tonumber()
	end
end

---@return chartedit.Point
function Points:saveSearchPoint()
	local sp = self.search_point
	local p = self:getPoint(sp:unpack())
	p.absoluteTime = sp.absoluteTime
	return p
end

return Points
