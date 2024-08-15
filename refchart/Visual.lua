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
		self[i] = VisualPoint(
			vp,
			p_to_index[vp.point --[[@as ncdk2.AbsolutePoint]]]
		)
	end
end

return Visual
