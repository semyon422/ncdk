local class = require("class")
local rbtree = require("rbtree")
local Point = require("chartedit.Point")
local Interval = require("chartedit.Interval")
local Fraction = require("ncdk.Fraction")

---@class chartedit.Layer
---@operator call: chartedit.Layer
local Layer = class()

function Layer:new()
	self.points_tree = rbtree.new()
	self.search_point = Point()
end

function Layer:init()
	local ivl_1 = Interval(0, 1)
	local ivl_2 = Interval(1, 1)
	ivl_1.next, ivl_2.prev = ivl_2, ivl_1
	self:getPoint(ivl_1, Fraction(0))
	self:getPoint(ivl_2, Fraction(0))
	-- self:compute()
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
	self.points_tree:insert(point)

	return point
end

---@param point chartedit.Point
---@param beats integer
---@return chartedit.Interval
function Layer:_getInterval(point, beats)
	point._interval = Interval(point.absoluteTime, beats)
	return point._interval
end

---@param point chartedit.Point
---@return chartedit.Interval
function Layer:splitInterval(point)
	-- point = self:checkTimePoint(point)
	local _interval = assert(point.interval)

	local time = point.time
	local _beats = time:floor()

	---@type chartedit.Interval
	local interval
	local tp
	local dir
	if time[1] > 0 then
		local beats = _interval.next and _interval.beats - _beats or 1
		interval = self:_getInterval(point, beats)
		point:new(interval, time % 1)
		_interval.beats = _beats

		tp = point.next
		dir = "next"
	else
		interval = self:_getInterval(point, -_beats)
		interval.point:new(_interval, time)
		tp = _interval.point.prev
		dir = "prev"
	end
	while tp and tp.interval == _interval do
		tp.interval = interval
		tp.time = tp.time - _beats
		tp = tp[dir]
	end

	return interval
end

return Layer
