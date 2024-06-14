local class = require("class")

---@class ncdk2.EventScroller
---@operator call: ncdk2.EventScroller
local EventScroller = class()

---@param events ncdk2.VisualEvent[]
function EventScroller:new(events)
	self.events = events
	self.offset = 0

	---@type {[ncdk2.VisualPoint]: true}
	self.visible_points = {}
end

---@param currentTime number
---@param f fun(vp: ncdk2.VisualPoint, action: -1|1)?
function EventScroller:scroll(currentTime, f)
	local events = self.events
	local visible_points = self.visible_points

	local event = events[self.offset + 1]
	while event and event.time <= currentTime do
		if f then
			f(event.point, event.action)
		end
		if event.action == 1 then
			visible_points[event.point] = true
		else
			visible_points[event.point] = nil
		end
		self.offset = self.offset + 1
		event = events[self.offset + 1]
	end
end

return EventScroller
