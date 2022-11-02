local TimeData = require("ncdk.TimeData")
local SpaceData = require("ncdk.SpaceData")
local NoteDataSequence = require("ncdk.NoteDataSequence")

local LayerData = {}

local mt = {__index = LayerData}

function LayerData:new()
	local layerData = {}

	layerData.timeData = TimeData:new()
	layerData.spaceData = SpaceData:new()
	layerData.noteDataSequence = NoteDataSequence:new()

	layerData.timeData.layerData = layerData
	layerData.spaceData.layerData = layerData
	layerData.noteDataSequence.layerData = layerData

	return setmetatable(layerData, mt)
end

function LayerData:compute()
	self.timeData:sort()
	self.spaceData:sort()
	self.noteDataSequence:sort()

	self.timeData:computeTimePoints()

	if not self.invisible then
		self.spaceData:computeTimePoints()
	end
end

function LayerData:setSignature(...) return self.timeData:setSignature(...) end
function LayerData:getSignature(...) return self.timeData:getSignature(...) end
function LayerData:setSignatureTable(...) return self.timeData:setSignatureTable(...) end
function LayerData:addTempoData(...) return self.timeData:addTempoData(...) end
function LayerData:getTempoData(...) return self.timeData:getTempoData(...) end
function LayerData:getTempoDataCount() return self.timeData:getTempoDataCount() end
function LayerData:addStopData(...) return self.timeData:addStopData(...) end
function LayerData:getStopData(...) return self.timeData:getStopData(...) end
function LayerData:getStopDataCount() return self.timeData:getStopDataCount() end
function LayerData:getTimePoint(...) return self.timeData:getTimePoint(...) end
function LayerData:getZeroTimePoint() return self.timeData:getZeroTimePoint() end
function LayerData:setTimeMode(...) return self.timeData:setMode(...) end
function LayerData:setSignatureMode(...) return self.timeData:setSignatureMode(...) end

function LayerData:addVelocityData(...) return self.spaceData:addVelocityData(...) end
function LayerData:removeLastVelocityData(...) return self.spaceData:removeLastVelocityData(...) end
function LayerData:getVelocityData(...) return self.spaceData:getVelocityData(...) end
function LayerData:getVelocityDataCount() return self.spaceData:getVelocityDataCount() end
function LayerData:getVelocityDataByTimePoint(...) return self.spaceData:getVelocityDataByTimePoint(...) end
function LayerData:getVisualMeasureTime(...) return self.spaceData:getVisualMeasureTime(...) end
function LayerData:getVisualTime(...) return self.spaceData:getVisualTime(...) end

function LayerData:getColumnCount() return self.noteDataSequence:getColumnCount() end
function LayerData:addNoteData(...) return self.noteDataSequence:addNoteData(...) end
function LayerData:getNoteData(...) return self.noteDataSequence:getNoteData(...) end
function LayerData:getNoteDataCount() return self.noteDataSequence:getNoteDataCount() end

return LayerData
