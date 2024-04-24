local class = require("class")

---@class ncdk2.Interpolator
---@operator call: ncdk2.Interpolator
local Interpolator = class()

---@param list ncdk2.VisualTimePoint[]
---@param index number
---@param t ncdk2.VisualTimePoint
---@return number
function Interpolator:getBaseIndex(list, index, t)
	index = math.min(math.max(index, 1), #list)

	local _t = list[index]
	if t == _t or t:compare(_t) and index == 1 then
		-- skip
	elseif _t:compare(t) then  -- t > timePoint
		local next_t = list[index + 1]
		while next_t do
			if not t:compare(next_t) then  -- t >= nextTimePoint
				index = index + 1
				next_t = list[index + 1]
			else
				break
			end
		end
	elseif t:compare(_t) then
		index = index - 1
		local prev_t = list[index]
		while prev_t do
			if t:compare(prev_t) then
				index = index - 1
				prev_t = list[index]
			else
				break
			end
		end
	end

	return math.max(index, 1)
end

---@param list ncdk2.VisualTimePoint[]
---@param index number
---@param vtp ncdk2.VisualTimePoint
---@param mode "absolute"|"visual"
---@return number
function Interpolator:interpolate(list, index, vtp, mode)
	index = self:getBaseIndex(list, index, vtp)

	local a = list[index]
	local a_tp = a.timePoint

	local vtp_tp = vtp.timePoint

	if mode == "absolute" then
		vtp.visualTime = a.visualTime + (vtp_tp.absoluteTime - a_tp.absoluteTime) * a.currentSpeed
	elseif mode == "visual" then
		vtp_tp.absoluteTime = a_tp.absoluteTime + (vtp.visualTime - a.visualTime) / a.currentSpeed
	end

	vtp.visualSection = a.visualSection

	vtp.currentSpeed = a.currentSpeed
	vtp.localSpeed = a.localSpeed
	vtp.globalSpeed = a.globalSpeed

	return index
end

return Interpolator
