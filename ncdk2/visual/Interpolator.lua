local class = require("class")

---@class ncdk2.Interpolator
---@operator call: ncdk2.Interpolator
local Interpolator = class()

---@param list ncdk2.VisualPoint[]
---@param index number
---@param t ncdk2.VisualPoint
---@return number
function Interpolator:getBaseIndex(list, index, t)
	index = math.min(math.max(index, 1), #list)

	local _t = list[index]
	if t == _t or t:compare(_t) and index == 1 then
		-- skip
	elseif _t:compare(t) then  -- t > point
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

---@param list ncdk2.VisualPoint[]
---@param index number
---@param vp ncdk2.VisualPoint
---@param mode "absolute"|"visual"
---@return number
function Interpolator:interpolate(list, index, vp, mode)
	index = self:getBaseIndex(list, index, vp)

	local a = list[index]
	local a_p = a.point
	local vp_p = vp.point

	if mode == "absolute" then
		vp.visualTime = a.visualTime + (vp_p.absoluteTime - a_p.absoluteTime) * a.currentSpeed
	elseif mode == "visual" then
		vp_p.absoluteTime = a_p.absoluteTime + (vp.visualTime - a.visualTime) / a.currentSpeed
	end

	vp.section = a.section

	vp.currentSpeed = a.currentSpeed
	vp.localSpeed = a.localSpeed
	vp.globalSpeed = a.globalSpeed

	return index
end

return Interpolator
