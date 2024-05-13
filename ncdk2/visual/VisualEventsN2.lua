local class = require("class")
local math_util = require("math_util")

---@class ncdk2.VisualEventsN2
---@operator call: ncdk2.VisualEventsN2
local VisualEventsN2 = class()

-- function math_util.map(x, a, b, c, d)
-- 	return (x - a) * (d - c) / (b - a) + c
-- end

---@param vps ncdk2.VisualPoint[]
---@param j number
---@param i number
---@param dt number
---@return number|false?
local function intersect(vps, j, i, dt)
	local vp = vps[j]
	local _vp = vps[i]
	local next_vp = vps[i + 1]

	local next_visualTime = next_vp and next_vp.visualTime or _vp.visualTime + 1 * _vp.currentSpeed
	local next_absoluteTime = next_vp and next_vp.point.absoluteTime or _vp.point.absoluteTime + 1

	local targetVisualTime = vp.visualTime - dt / _vp.globalSpeed / vp.localSpeed

	-- local targetTime = 0
	-- local dv = targetVisualTime - _vp.visualTime
	-- local _dv = next_visualTime - _vp.visualTime
	-- local _da = next_absoluteTime - _vp.point.absoluteTime
	-- if dv == 0 then
	-- 	targetTime = _vp.point.absoluteTime
	-- elseif _dv == 0 then
	-- 	if _da ~= 0 then
	-- 	end
	-- end

	if _vp.currentSpeed == 0 then  -- todo
		-- targetTime = ???
	end

	local targetTime = math_util.map(
		targetVisualTime,
		_vp.visualTime,
		next_visualTime,
		_vp.point.absoluteTime,
		next_absoluteTime
	)
	-- if _vp.visualTime == next_visualTime then
	-- 	print("--------------")
	-- 	print(j, i, targetTime,
	-- 		targetVisualTime,
	-- 		_vp.visualTime,
	-- 		next_visualTime,
	-- 		_vp.point.absoluteTime,
	-- 		next_absoluteTime)
	-- end

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
function VisualEventsN2:generate(vps, range)
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
					action = speed >= 0 and 1 or -1,
					point = vp,
				})
			end
			if leftTime then
				table.insert(events, {
					time = leftTime,
					action = speed >= 0 and -1 or 1,
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

	return events
end

return VisualEventsN2
