local Layer = require("ncdk2.layers.Layer")
local MeasureTimePoint = require("ncdk2.tp.MeasureTimePoint")
local MeasureAbsolute = require("ncdk2.conv.MeasureAbsolute")
local Visual = require("ncdk2.visual.Visual")

---@class ncdk2.MeasureLayer: ncdk2.Layer
---@operator call: ncdk2.MeasureLayer
local MeasureLayer = Layer + {}

function MeasureLayer:new()
	Layer.new(self)
	self.measureAbsolute = MeasureAbsolute()
	self.visual = Visual()
end

---@param mode string
function MeasureLayer:setSignatureMode(mode)
	assert(mode == "long" or mode == "short", "Wrong signature mode")
	self.signatureMode = mode
end

---@param tempo number
function MeasureLayer:setPrimaryTempo(tempo)
	assert(tempo >= 0, "Wrong primary tempo")
	self.primaryTempo = tempo
end

---@param time ncdk.Fraction
---@return ncdk2.MeasureTimePoint
function MeasureLayer:newTimePoint(time)
	return MeasureTimePoint(time)
end

---@param time ncdk.Fraction
---@return ncdk2.MeasureTimePoint
function MeasureLayer:getTimePoint(time)
	---@type ncdk2.MeasureTimePoint
	return Layer.getTimePoint(self, time)
end

function MeasureLayer:computeTimePoints()
	local timePointList = self:getTimePointList()
	self.measureAbsolute:convert(timePointList)

	self.visual:compute(self.visualTimePoints)
end

return MeasureLayer
