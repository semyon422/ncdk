local IPoint = require("ncdk2.tp.IPoint")
local table_util = require("table_util")
local Fraction = require("ncdk.Fraction")

---@class chartedit.Point: ncdk2.IPoint
---@operator call: chartedit.Point
---@field _measure ncdk2.Measure?
---@field measure ncdk2.Measure?
---@field _interval chartedit.Interval?
---@field interval chartedit.Interval
---@field absoluteTime number
---@field prev chartedit.Point?
---@field next chartedit.Point?
local Point = IPoint + {}

---@param p chartedit.Point
---@param k any
---@param v any
function Point.__index(p, k, v)
	if k == "absoluteTime" then
		return p:tonumber()
	end
	return Point[k]
end

---@param interval chartedit.Interval
---@param time ncdk.Fraction
function Point:new(interval, time)
	self.interval = interval
	self.time = time
end

---@return chartedit.Interval
---@return ncdk.Fraction
function Point:unpack()
	return self.interval, self.time
end

---@param point chartedit.Point?
---@return chartedit.Point
function Point:clone(point)
	assert(not rawequal(self, point), "not allowed to clone to itself")
	point = point or Point()
	table_util.clear(point)
	table_util.copy(self, point)
	return point
end

---@return ncdk.Fraction
function Point:getBeatModulo()
	local measure = self.measure
	if not measure then
		return self.time % 1
	end
	return (self.time - measure.point.time + measure.start) % 1  -- TODO: fix measure.point
end

---@param interval chartedit.Interval
---@param time ncdk.Fraction
---@return chartedit.Interval
---@return ncdk.Fraction
local function add(interval, time)
	if interval.next and time >= interval:_end() then
		time = time - interval.beats
		interval = interval.next
		return add(interval, time)
	elseif interval.prev and time < interval:start() then
		interval = interval.prev
		time = time + interval.beats
		return add(interval, time)
	end
	return interval, time
end

---@param duration ncdk.Fraction
---@return chartedit.Interval
---@return ncdk.Fraction
function Point:add(duration)
	return add(self.interval, self.time + duration)
end

---@param id1 chartedit.Interval
---@param t1 ncdk.Fraction
---@param id2 chartedit.Interval
---@param t2 ncdk.Fraction
---@return ncdk.Fraction
local function sub(id1, t1, id2, t2)
	if id1 > id2 then
		return sub(id1.prev, t1 + id1.prev.beats, id2, t2)
	elseif id1 < id2 then
		return -sub(id2, t2, id1, t1)
	end
	return t1 - t2
end

---@param point chartedit.Point
---@return ncdk.Fraction
function Point:sub(point)
	return sub(
		self.interval,
		self.time,
		point.interval,
		point.time
	)
end

---@return number
function Point:tonumber()
	local ivl = self.interval
	if type(ivl) == "number" then
		return ivl
	end
	if ivl:isSingle() then
		return ivl.offset
	end
	local a, b, offset = ivl:getPair()
	local time = self.time:tonumber() - a:startn() + (offset and a.beats or 0)
	return a.offset + a:getBeatDuration() * time
end

---@param ivl chartedit.Interval
---@param t number
---@param limit number
---@param measure ncdk2.Measure?
---@param round boolean?
function Point:fromnumber(ivl, t, limit, measure, round)
	local a, b, offset = ivl:getPair()
	local time = (t - a.offset) / a:getBeatDuration() + a:startn()
	if offset then
		time = time - a.beats
		a = b
	end
	local measureOffset = measure and measure.point.time - measure.start or 0  -- TODO: fix measure.point
	time = Fraction(time - measureOffset, limit, not not round) + measureOffset  -- TODO: better code
	if not offset and time == a:_end() then
		time = b:start()
		a = b
	end
	self:new(a, time)
end

---@param a chartedit.Point
---@return string
function Point.__tostring(a)
	return ("Point(%s, %s)"):format(a.interval, a.time)
end

---@param a chartedit.Point
---@param b chartedit.Point
---@return number?
---@return number?
local function number_intervals(a, b)
	local ia, ib = a.interval, b.interval
	local ta, tb = type(ia) == "table", type(ib) == "table"
	if ta and tb then
		return
	end
	if ta then
		ia = a.absoluteTime
	end
	if tb then
		ib = b.absoluteTime
	end
	return ia, ib
end

---@param a chartedit.Point
---@param b chartedit.Point
---@return boolean
function Point.__eq(a, b)
	local na, nb = number_intervals(a, b)
	if na then return na == nb end
	local ai, bi = a.interval, b.interval
	return ai == bi and a.time == b.time
end

---@param a chartedit.Point
---@param b chartedit.Point
---@return boolean
function Point.__lt(a, b)
	local na, nb = number_intervals(a, b)
	if na then return na < nb end
	local ai, bi = a.interval, b.interval
	return ai < bi or ai == bi and a.time < b.time
end

---@param a chartedit.Point
---@param b chartedit.Point
---@return boolean
function Point.__le(a, b)
	local na, nb = number_intervals(a, b)
	if na then return na <= nb end
	local ai, bi = a.interval, b.interval
	return ai < bi or ai == bi and a.time < b.time or ai == bi and a.time == b.time
end

return Point
