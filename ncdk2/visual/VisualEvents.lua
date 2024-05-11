local class = require("class")

---@class ncdk2.VisualEvent
---@field time number
---@field action "hide"|"show"
---@field point ncdk2.VisualPoint

---@class ncdk2.VisualEvents
---@operator call: ncdk2.VisualEvents
local VisualEvents = class()

---@param vps ncdk2.VisualPoint[]
---@param j number
---@param i number
---@param dt number
---@return number|false?
local function intersect(vps, j, i, dt)
	local vp = vps[j]
	local _vp = vps[i]
	local next_vp = vps[i + 1]

	local targetVisualTime = vp.visualTime - _vp.visualTime - dt / _vp.globalSpeed / vp.localSpeed
	local targetTime = targetVisualTime / _vp.currentSpeed + _vp.point.absoluteTime
	if #vps == 1 then
		return targetTime
	end

	local gte = targetTime >= _vp.point.absoluteTime
	if i == #vps then
		return gte and targetTime
	end

	local lt = targetTime < next_vp.point.absoluteTime
	if i == 1 then
		return lt and targetTime
	end

	return gte and lt and targetTime
end

---@param vps ncdk2.VisualPoint[]
---@param range {[1]: number, [2]: number}
---@return ncdk2.VisualEvent[]
function VisualEvents:generate(vps, range)
	---@type ncdk2.VisualEvent[]
	local events = {}

	for j = 1, #vps do
		local vp = vps[j]
		for i = 1, #vps do
			local _vp = vps[i]  -- current time is from i to i+1
			local rightTime = intersect(vps, j, i, range[2])
			local leftTime = intersect(vps, j, i, range[1])
			local speed = _vp.globalSpeed * vp.localSpeed * _vp.currentSpeed
			if rightTime then
				table.insert(events, {
					time = rightTime,
					action = speed >= 0 and "show" or "hide",
					point = vp,
				})
			end
			if leftTime then
				table.insert(events, {
					time = leftTime,
					action = speed >= 0 and "hide" or "show",
					point = vp,
				})
			end
		end
	end

	table.sort(events, function(a, b)
		return a.time < b.time
	end)

	return events
end

return VisualEvents
