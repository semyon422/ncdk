local Interpolator = require("ncdk2.Interpolator")

---@class ncdk2.VisualInterpolator: ncdk2.Interpolator
---@operator call: ncdk2.VisualInterpolator
local VisualInterpolator = Interpolator + {}

---@param p ncdk2.VisualPoint
---@return ncdk2.Point
local function ext_point(p)
	return p.point
end

---@param list ncdk2.VisualPoint[]
---@param index number
---@param vp ncdk2.VisualPoint
---@param mode "absolute"|"visual"
---@return number
function VisualInterpolator:interpolate(list, index, vp, mode)
	if mode == "absolute" then
		index = self:getBaseIndex(list, index, vp, ext_point)
	else
		index = self:getBaseIndex(list, index, vp)
	end

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

return VisualInterpolator
