local class = require("class")
local TimePoint = require("ncdk2.tp.TimePoint")
local NoteDatas = require("ncdk2.notes.NoteDatas")
local VisualTimePoint = require("ncdk2.visual.VisualTimePoint")
local Visual = require("ncdk2.visual.Visual")

---@class ncdk2.Layer
---@operator call: ncdk2.Layer
---@field timePoints {[string]: ncdk2.TimePoint}
---@field visualTimePoints ncdk2.VisualTimePoint[]
local Layer = class()

function Layer:new()
	self.noteDatas = NoteDatas()
	self.timePoints = {}
	self.visualTimePoints = {}
	self.testTimePoint = self:newTimePoint()
	self.visual = Visual()
end

---@param ... any
---@return ncdk2.TimePoint
function Layer:newTimePoint(...)
	return TimePoint(...)
end

function Layer:compute()
	self.visual:compute(self.visualTimePoints)
end

---@param ... any
---@return ncdk2.TimePoint
function Layer:getTimePoint(...)
	print("get time point", ...)
	self.testTimePoint:new(...)

	local timePoints = self.timePoints
	local key = tostring(self.testTimePoint)
	local timePoint = timePoints[key]
	if timePoint then
		return timePoint
	end

	timePoint = self:newTimePoint(...)
	timePoints[key] = timePoint

	return timePoint
end

---@return ncdk2.TimePoint[]
function Layer:getTimePointList()
	local timePointList = {}
	for _, timePoint in pairs(self.timePoints) do
		table.insert(timePointList, timePoint)
	end
	table.sort(timePointList)
	return timePointList
end

---@param timePoint ncdk2.TimePoint
---@return ncdk2.VisualTimePoint
function Layer:newVisualTimePoint(timePoint)
	local visualTimePoint = VisualTimePoint(timePoint)
	table.insert(self.visualTimePoints, visualTimePoint)
	return visualTimePoint
end

return Layer
