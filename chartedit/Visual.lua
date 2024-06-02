local class = require("class")
local table_util = require("table_util")
local VisualPoint = require("chartedit.VisualPoint")

---@class chartedit.Visual
---@operator call: chartedit.Visual
---@field head chartedit.VisualPoint?
---@field p2vp {[chartedit.Point]: chartedit.VisualPoint}
local Visual = class()

function Visual:new()
	self.p2vp = {}
end

---@param point chartedit.Point
function Visual:getPoint(point)
	local p2vp = self.p2vp
	local vp = p2vp[point]
	if vp then
		return vp
	end

	vp = VisualPoint(point)
	p2vp[point] = vp

	if not self.head then
		self.head = vp
		return vp
	end

	local _vp = p2vp[point.prev]
	if not _vp then
		table_util.insert_linked(vp, nil, self.head)
		return vp
	end

	while _vp and _vp.next and _vp.next.point == _vp.point do
		_vp = _vp.next
	end

	table_util.insert_linked(vp, _vp, _vp.next)
	return vp
end

---@param vp chartedit.VisualPoint
---@return chartedit.VisualPoint
function Visual:createAfter(vp)
	local _vp = VisualPoint(vp.point)
	table_util.insert_linked(_vp, vp, vp.next)
	return _vp
end

---@param vp chartedit.VisualPoint
---@return chartedit.VisualPoint
function Visual:createBefore(vp)
	local p2vp = self.p2vp
	local p = vp.point
	local _vp = VisualPoint(p)
	if p2vp[p] == vp then
		p2vp[p] = _vp
	end
	table_util.insert_linked(_vp, vp.prev, vp)
	return _vp
end

return Visual
