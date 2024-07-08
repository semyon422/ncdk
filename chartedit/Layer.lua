local class = require("class")
local Points = require("chartedit.Points")
local Intervals = require("chartedit.Intervals")
local Visual = require("chartedit.Visual")
local Notes = require("chartedit.Notes")

---@alias chartedit.PointNotes {[ncdk2.Column]: ncdk2.Note}

---@class chartedit.Layer
---@operator call: chartedit.Layer
local Layer = class()

function Layer:new()
	self.notes = Notes()
	self.visual = Visual(function(vp) self.notes:removeAll(vp) end)
	self.points = Points(
		function(p) self.visual:getPoint(p) end,
		function(p) self.visual:removeAll(p) end
	)
	self.intervals = Intervals(self.points)
end

---@param start_time number
---@param end_time number
---@return fun(): chartedit.Point
function Layer:iter(start_time, end_time)
	return coroutine.wrap(function()
		local _p = self.points:interpolateAbsolute(1, start_time)
		local p = _p.prev or _p.next
		while p and p.absoluteTime <= end_time do
			coroutine.yield(p)
			p = p.next
		end
	end)
end

return Layer
