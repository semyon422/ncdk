local LayerData = require("ncdk2.ld.LayerData")
local AbsoluteTimePoint = require("ncdk2.tp.AbsoluteTimePoint")

---@class ncdk2.AbsoluteLayerData: ncdk2.LayerData
---@operator call: ncdk2.AbsoluteLayerData
local AbsoluteLayerData = LayerData + {}

---@return ncdk2.AbsoluteTimePoint
function AbsoluteLayerData:newTimePoint()
	return AbsoluteTimePoint()
end

---@param time number
---@return ncdk2.AbsoluteTimePoint
function AbsoluteLayerData:getTimePoint(time)
	---@type ncdk2.AbsoluteTimePoint
	return LayerData.getTimePoint(self, time)
end

function AbsoluteLayerData:computeTimePoints()
	---@type ncdk2.AbsoluteTimePoint[]
	local timePointList = self:createTimePointList()

	local tempoData = self:getTempoData(1)

	local timePointIndex = 1
	local timePoint = timePointList[timePointIndex]

	while timePoint do
		local nextTempoData = timePoint._tempoData
		if nextTempoData then
			tempoData = nextTempoData
		end

		timePoint.tempoData = tempoData

		timePointIndex = timePointIndex + 1
		timePoint = timePointList[timePointIndex]
	end
end

return AbsoluteLayerData
