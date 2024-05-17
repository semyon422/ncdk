local Layer = require("ncdk2.layers.Layer")
local MeasurePoint = require("ncdk2.tp.MeasurePoint")
local MeasureAbsolute = require("ncdk2.compute.MeasureAbsolute")

---@class ncdk2.MeasureLayer: ncdk2.Layer
---@operator call: ncdk2.MeasureLayer
local MeasureLayer = Layer + {}

function MeasureLayer:new()
	Layer.new(self)
	self.measureAbsolute = MeasureAbsolute()
end

---@param mode string
function MeasureLayer:setSignatureMode(mode)
	assert(mode == "long" or mode == "short", "Wrong signature mode")
	self.signatureMode = mode
end

---@param time ncdk.Fraction
---@param isRightSide boolean?
---@return ncdk2.MeasurePoint
function MeasureLayer:newPoint(time, isRightSide)
	return MeasurePoint(time, isRightSide)
end

---@param time ncdk.Fraction
---@param isRightSide boolean?
---@return ncdk2.MeasurePoint
function MeasureLayer:getPoint(time, isRightSide)
	---@type ncdk2.MeasurePoint
	return Layer.getPoint(self, time, isRightSide)
end

function MeasureLayer:compute()
	local pointList = self:getPointList()
	self.measureAbsolute:convert(pointList)
	Layer.compute(self)
end

return MeasureLayer
