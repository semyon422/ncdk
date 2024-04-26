local class = require("class")

---@class ncdk2.Interpolator
---@operator call: ncdk2.Interpolator
local Interpolator = class()

---@param list ncdk2.VisualPoint[]
---@param index number
---@param vp ncdk2.VisualPoint
---@return number
function Interpolator:getBaseIndex(list, index, vp)
	index = math.min(math.max(index, 1), #list)

	local _vp = list[index]
	if vp == _vp or vp:compare(_vp) and index == 1 then
		-- skip
	elseif _vp:compare(vp) then  -- vp > _vp
		local next_vp = list[index + 1]
		while next_vp do
			if not vp:compare(next_vp) then  -- vp >= next_vp
				index = index + 1
				next_vp = list[index + 1]
			else
				break
			end
		end
	elseif vp:compare(_vp) then
		index = index - 1
		local prev_t = list[index]
		while prev_t do
			if vp:compare(prev_t) then
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
