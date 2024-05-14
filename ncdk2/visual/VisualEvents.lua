local class = require("class")

---@class ncdk2.VisualEvent
---@field time number
---@field action -1|1
---@field point ncdk2.VisualPoint

---@class ncdk2.VisualEvents
---@operator call: ncdk2.VisualEvents
local VisualEvents = class()

---@param vps ncdk2.VisualPoint[]
---@param range {[1]: number, [2]: number}
---@return ncdk2.VisualEvent[]
function VisualEvents:generate(vps, range)
	---@type ncdk2.VisualEvent[]
	local events = {}

	for j = 1, #vps do
		local vp = vps[j]
		table.insert(events, {
			time = vp.visualTime - range[2] / vp.localSpeed,
			action = 1,
			point = vp,
		})
		table.insert(events, {
			time = vp.visualTime - range[1] / vp.localSpeed,
			action = -1,
			point = vp,
		})
	end

	table.sort(events, function(a, b)
		if a.time ~= b.time then
			return a.time < b.time
		end
		return a.point.point < b.point.point
	end)

	self.events = events

	self.startOffset = vps[1].currentSpeed >= 0 and 0 or #events  -- todo: handle zero speed
	self.endOffset = vps[#vps].currentSpeed < 0 and 0 or #events  -- todo: handle zero speed

	return events
end

-- nil instead of false to clear values in tables
---@param action number
---@return true?
local function get_action_value(action)
	if action > 0 then
		return true
	end
end

---@param index number
---@param time number
---@return number?
---@return ncdk2.VisualPoint?
---@return true?
function VisualEvents:next(index, time)
	local event = self.events[index]
	local next_event = self.events[index + 1]

	if event and next_event and time >= event.time and time < next_event.time then
		return
	elseif next_event and time >= next_event.time then
		return index + 1, next_event.point, get_action_value(1 * next_event.action)
	elseif event and time < event.time then
		return index - 1, event.point, get_action_value(-1 * event.action)
	end
end

return VisualEvents
