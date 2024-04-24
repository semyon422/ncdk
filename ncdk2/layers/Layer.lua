local class = require("class")
local NoteDatas = require("ncdk2.notes.NoteDatas")

---@class ncdk2.Layer
---@operator call: ncdk2.Layer
local Layer = class()

function Layer:new()
	self.noteDatas = NoteDatas()
	self.timePoints = {}
	self.visualTimePoints = {}
end

function Layer:compute()
	-- for _, name in ipairs(listNames) do
	-- 	table.sort(self[name])
	-- end

	self.noteDatas:sort()

	-- local intervalDatas = self.intervalDatas
	-- for i = 1, #intervalDatas do
	-- 	intervalDatas[i].next = intervalDatas[i + 1]
	-- 	intervalDatas[i].prev = intervalDatas[i - 1]
	-- end

	self:computeTimePoints()
end

---@param ... any
---@return ncdk.TimePoint
function Layer:getTimePoint(...)
	self.testTimePoint = self.testTimePoint or self:newTimePoint()
	self.testTimePoint:setTime(...)

	local timePoints = self.timePoints
	local key = tostring(self.testTimePoint)
	local timePoint = timePoints[key]
	if timePoint then
		return timePoint
	end

	timePoint = self:newTimePoint()
	timePoint:setTime(...)
	timePoints[key] = timePoint

	return timePoint
end

return Layer
