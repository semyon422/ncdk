local class = require("class")
local VisualPoint = require("refchart.VisualPoint")
local VisualPointReference = require("refchart.VisualPointReference")

---@class refchart.Visual
---@operator call: refchart.Visual
---@field [integer] refchart.VisualPoint
local Visual = class()

---@param visual ncdk2.Visual
---@param p_to_index {[ncdk2.AbsolutePoint]: integer}
---@param vp_ref {[ncdk2.VisualPoint]: refchart.VisualPointReference}
---@param l_name string
---@param v_name string
function Visual:new(visual, p_to_index, vp_ref, l_name, v_name)
	for i, vp in ipairs(visual.points) do
		vp_ref[vp] = VisualPointReference(l_name, v_name, i)

		local p = vp.point
		---@cast p ncdk2.AbsolutePoint

		local p_index = p_to_index[p]

		local _vp = VisualPoint()

		_vp.point = p_index
		if vp._expand then
			_vp.expand = vp._expand.duration
		end
		if vp._velocity then
			_vp.velocity = {
				vp._velocity.currentSpeed,
				vp._velocity.localSpeed,
				vp._velocity.globalSpeed,
			}
		end

		self[i] = _vp
	end
end

return Visual
