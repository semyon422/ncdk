local TimeData = require("ncdk.TimeData")
local SpaceData = require("ncdk.SpaceData")
local NoteDataSequence = require("ncdk.NoteDataSequence")

local LayerData = {}

local LayerData_metatable = {}
LayerData_metatable.__index = LayerData

LayerData.new = function(self)
	local layerData = {}
	
	layerData.timeData = TimeData:new()
	layerData.spaceData = SpaceData:new()
	layerData.noteDataSequence = NoteDataSequence:new()
	
	layerData.timeData.layerData = layerData
	layerData.spaceData.layerData = layerData
	layerData.noteDataSequence.layerData = layerData
	
	setmetatable(layerData, LayerData_metatable)
	
	return layerData
end

LayerData.compute = function(self)
	self.timeData:sort()
	self.spaceData:sort()
	self.noteDataSequence:sort()
	
	self:updateZeroTimePoint()
	
	self.timeData:createTimePointList()
	self.timeData:computeTimePoints()
	
	if not self.invisible then
		self.spaceData:computeTimePoints()
	end
end

LayerData.setSignature = function(self, ...) return self.timeData:setSignature(...) end
LayerData.getSignature = function(self, ...) return self.timeData:getSignature(...) end
LayerData.setSignatureTable = function(self, ...) return self.timeData:setSignatureTable(...) end
LayerData.addTempoData = function(self, ...) return self.timeData:addTempoData(...) end
LayerData.getTempoData = function(self, ...) return self.timeData:getTempoData(...) end
LayerData.getTempoDataCount = function(self) return self.timeData:getTempoDataCount() end
LayerData.addStopData = function(self, ...) return self.timeData:addStopData(...) end
LayerData.getStopData = function(self, ...) return self.timeData:getStopData(...) end
LayerData.getStopDataCount = function(self) return self.timeData:getStopDataCount() end
LayerData.getTimePoint = function(self, ...) return self.timeData:getTimePoint(...) end
LayerData.updateZeroTimePoint = function(self) return self.timeData:updateZeroTimePoint() end
LayerData.getZeroTimePoint = function(self) return self.timeData:getZeroTimePoint() end
LayerData.setTimeMode = function(self, ...) return self.timeData:setMode(...) end
LayerData.setSignatureMode = function(self, ...) return self.timeData:setSignatureMode(...) end

LayerData.addVelocityData = function(self, ...) return self.spaceData:addVelocityData(...) end
LayerData.removeLastVelocityData = function(self, ...) return self.spaceData:removeLastVelocityData(...) end
LayerData.getVelocityData = function(self, ...) return self.spaceData:getVelocityData(...) end
LayerData.getVelocityDataCount = function(self) return self.spaceData:getVelocityDataCount() end
LayerData.getVelocityDataByTimePoint = function(self, ...) return self.spaceData:getVelocityDataByTimePoint(...) end
LayerData.getVisualMeasureTime = function(self, ...) return self.spaceData:getVisualMeasureTime(...) end
LayerData.getVisualTime = function(self, ...) return self.spaceData:getVisualTime(...) end

LayerData.getColumnCount = function(self) return self.noteDataSequence:getColumnCount() end
LayerData.addNoteData = function(self, ...) return self.noteDataSequence:addNoteData(...) end
LayerData.getNoteData = function(self, ...) return self.noteDataSequence:getNoteData(...) end
LayerData.getNoteDataCount = function(self) return self.noteDataSequence:getNoteDataCount() end

return LayerData
