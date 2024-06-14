local class = require("class")
local VisualEvents = require("ncdk2.visual.VisualEvents")
local EventScroller = require("ncdk2.visual.EventScroller")

---@class ncdk2.FullEventScroller
---@operator call: ncdk2.FullEventScroller
local FullEventScroller = class()

local start_po2 = -1  -- 0.5s

---@param points ncdk2.VisualPoint[]
function FullEventScroller:generate(points)
	local duration = self:getVisualDuration(points)
	local end_po2 = start_po2
	if duration > 0 then
		end_po2 = math.max(math.ceil(math.log(duration, 2)), start_po2)
	end

	local ve = VisualEvents()

	---@type ncdk2.EventScroller[]
	local scrollers = {}
	self.scrollers = scrollers

	for i = start_po2, end_po2 do
		local range = 2 ^ i
		if i == end_po2 then
			range = math.huge
		end
		local events = ve:generate(points, {-range, range})
		scrollers[i] = EventScroller(events)
	end

	self.end_po2 = end_po2
	self.scroller_index = start_po2
end

---@param points ncdk2.VisualPoint[]
---@return number
function FullEventScroller:getVisualDuration(points)
	if #points == 0 then
		return 0
	end
	local min_vt, max_vt = math.huge, -math.huge
	for _, vp in ipairs(points) do
		min_vt = math.min(min_vt, vp.visualTime)
		max_vt = math.max(max_vt, vp.visualTime)
	end
	return max_vt - min_vt
end

---@param currentTime number
---@param f fun(vp: ncdk2.VisualPoint, action: -1|1)
function FullEventScroller:scroll(currentTime, f)
	local scrollers = self.scrollers
	local scroller_index = self.scroller_index
	for i = start_po2, self.end_po2 do
		if i == scroller_index then
			scrollers[i]:scroll(currentTime, f)
		else
			scrollers[i]:scroll(currentTime)
		end
	end
end

---@param _old {[ncdk2.VisualPoint]: true}
---@param _new {[ncdk2.VisualPoint]: true}
---@return {[ncdk2.VisualPoint]: true}
---@return {[ncdk2.VisualPoint]: true}
local function map_update(_new, _old)
	local old = {}
	local new = {}
	for v in pairs(_new) do
		if not _old[v] then
			new[v] = true
		end
	end
	for v in pairs(_old) do
		if not _new[v] then
			old[v] = true
		end
	end
	return new, old
end

---@param range number
---@param f fun(vp: ncdk2.VisualPoint, action: -1|1)
function FullEventScroller:scale(range, f)
	local scrollers = self.scrollers

	local index = self.scroller_index
	local new_index = math.ceil(math.log(range, 2)) + 1
	new_index = math.min(math.max(new_index, start_po2), self.end_po2)
	if new_index == index then
		return
	end

	self.scroller_index = new_index

	local points = scrollers[index].visible_points
	local new_points = scrollers[new_index].visible_points

	local new_ps, old_ps = map_update(new_points, points)
	for vp in pairs(old_ps) do
		f(vp, -1)
	end
	for vp in pairs(new_ps) do
		f(vp, 1)
	end
end

return FullEventScroller
