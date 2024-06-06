local class = require("class")
local Points = require("chartedit.Points")
local Intervals = require("chartedit.Intervals")
local Visual = require("chartedit.Visual")

---@alias chartedit.PointNotes {[ncdk2.Column]: ncdk2.Note}
---@type chartedit.PointNotes
local empty_point_notes = {}

---@class chartedit.Layer
---@operator call: chartedit.Layer
---@field point_notes {[chartedit.VisualPoint]: chartedit.PointNotes}
local Layer = class()

function Layer:new()
	self.visual = Visual()
	self.points = Points(
		function(p) self.visual:getPoint(p) end,
		function(p) self.visual:removeAll(p) end
	)
	self.intervals = Intervals(self.points)
	self.point_notes = {}
end

---@param start_time number
---@param end_time number
---@return fun(): chartedit.Point, chartedit.VisualPoint, chartedit.PointNotes
function Layer:iter(start_time, end_time)
	local p2vp = self.visual.p2vp
	local point_notes = self.point_notes
	return coroutine.wrap(function()
		local _p = self.points:interpolateAbsolute(1, start_time)
		local p = _p.prev or _p.next
		while p and p.absoluteTime <= end_time do
			local vp = p2vp[p]
			while vp and vp.point == p do
				coroutine.yield(p, vp, point_notes[vp] or empty_point_notes)
				vp = vp.next
			end
			p = p.next
		end
	end)
end

---@param note ncdk2.Note
---@param column ncdk2.Column
function Layer:addNote(note, column)
	local point_notes = self.point_notes
	local vp = note.visualPoint
	point_notes[vp] = point_notes[vp] or {}
	point_notes[vp][column] = note
end

---@param note ncdk2.Note
---@param column ncdk2.Column
function Layer:removeNote(note, column)
	local point_notes = self.point_notes
	local vp = note.visualPoint
	if point_notes[vp] then
		point_notes[vp][column] = nil
	end
end

return Layer
