local class = require("class")

---@class ncdk2.VisualEvent
---@field time number
---@field action -1|1
---@field point ncdk2.VisualPoint

---@class ncdk2.VisualEvents
---@operator call: ncdk2.VisualEvents
local VisualEvents = class()

---@param vps ncdk2.VisualPoint[]
---@param gc_vps ncdk2.VisualPoint[]
---@param j number
---@param i number
---@param dt number
---@return number|false?
local function intersect(vps, gc_vps, j, i, dt)
	local vp = vps[j]
	local _vp = gc_vps[i]

	local targetVisualTime = vp.visualTime - dt / _vp.globalSpeed / vp.localSpeed
	if #gc_vps == 1 then
		return targetVisualTime
	end

	local gte = targetVisualTime >= _vp.visualTime
	if i == #gc_vps then
		return gte and targetVisualTime
	end

	local next_vp = gc_vps[i + 1]
	local lt = targetVisualTime < next_vp.visualTime
	if i == 1 then
		return lt and targetVisualTime
	end

	return gte and lt and targetVisualTime
end

---@param vps ncdk2.VisualPoint[]
---@param range {[1]: number, [2]: number}
---@return ncdk2.VisualEvent[]
function VisualEvents:generate(vps, range)
	---@type ncdk2.VisualPoint[]
	local gc_vps = {}

	---@type number
	local globalSpeed
	for _, vp in ipairs(vps) do
		if globalSpeed ~= vp.globalSpeed then
			globalSpeed = vp.globalSpeed
			table.insert(gc_vps, vp)
		end
	end

	---@type ncdk2.VisualEvent[]
	local events = {}
	for i = 1, #gc_vps do
		local _vp = gc_vps[i]
		for j = 1, #vps do
			local vp = vps[j]
			local rightTime = intersect(vps, gc_vps, j, i, range[2])
			local leftTime = intersect(vps, gc_vps, j, i, range[1])
			if rightTime then
				table.insert(events, {
					time = rightTime,
					action = 1,
					point = vp,
				})
			end
			if leftTime then
				table.insert(events, {
					time = leftTime,
					action = -1,
					point = vp,
				})
			end
		end
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
