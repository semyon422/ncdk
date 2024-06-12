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
	self.visual = Visual()
	self.points = Points(
		function(p) self.visual:getPoint(p) end,
		function(p) self.visual:removeAll(p) end
	)
	self.intervals = Intervals(self.points)
	self.notes = Notes()
end

---@param start_time number
---@param end_time number
---@return fun(): chartedit.Point, chartedit.VisualPoint, chartedit.PointNotes
function Layer:iter(start_time, end_time)
	local p2vp = self.visual.p2vp
	return coroutine.wrap(function()
		local _p = self.points:interpolateAbsolute(1, start_time)
		local p = _p.prev or _p.next
		while p and p.absoluteTime <= end_time do
			local vp = p2vp[p]
			while vp and vp.point == p do
				coroutine.yield(p, vp)
				vp = vp.next
			end
			p = p.next
		end
	end)
end

---@param note ncdk2.Note
---@param column ncdk2.Column
function Layer:addNote(note, column)
	self.notes:addNote(note, column)
end

---@param note ncdk2.Note
---@param column ncdk2.Column
function Layer:removeNote(note, column)
	self.notes:removeNote(note, column)
end

return Layer
