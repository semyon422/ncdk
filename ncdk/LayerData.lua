ncdk.LayerData = {}
local LayerData = ncdk.LayerData

ncdk.LayerData_metatable = {}
local LayerData_metatable = ncdk.LayerData_metatable
LayerData_metatable.__index = LayerData

LayerData.new = function(self)
	local layerData = {}
	
	layerData.timeData = ncdk.TimeData:new()
	layerData.spaceData = ncdk.SpaceData:new()
	layerData.noteDataSequence = ncdk.NoteDataSequence:new()
	
	layerData.timeData.layerData = layerData
	layerData.spaceData.layerData = layerData
	layerData.noteDataSequence.layerData = layerData
	
	setmetatable(layerData, LayerData_metatable)
	
	return layerData
end

LayerData.compute = function(self)
	self:computeTimePoints()
	self:computeNoteData()
end

LayerData.computeTimePoints = function(self)
	for _, timePoint in pairs(self.timeData.timePoints) do
		timePoint.velocityData = timePoint.velocityData or self:getVelocityDataByTimePoint(timePoint)
	end
end

LayerData.computeNoteData = function(self)
	self.noteDataSequence:sort()
	for noteDataIndex = 1, self.noteDataSequence:getNoteDataCount() do
		local noteData = self.noteDataSequence:getNoteData(noteDataIndex)
		
		noteData.zeroClearVisualTime = self:getVisualTime(noteData.timePoint, self:getZeroTimePoint(), true)
		noteData.currentVisualTime = noteData.zeroClearVisualTime
	end
end

LayerData.setSignature = function(self, ...) self.timeData:setSignature(...) end
LayerData.getSignature = function(self, ...) return self.timeData:getSignature(...) end
LayerData.setSignatureTable = function(self, ...) self.timeData:setSignatureTable(...) end
LayerData.addTempoData = function(self, ...) self.timeData:addTempoData(...) end
LayerData.getTempoData = function(self, ...) return self.timeData:getTempoData(...) end
LayerData.addStopData = function(self, ...) self.timeData:addStopData(...) end
LayerData.getStopData = function(self, ...) return self.timeData:getStopData(...) end
LayerData.getTimePoint = function(self, ...) return self.timeData:getTimePoint(...) end

LayerData.addVelocityData = function(self, ...) self.spaceData:addVelocityData(...) end
LayerData.getVelocityDataByTimePoint = function(self, ...) return self.spaceData:getVelocityDataByTimePoint(...) end
LayerData.getVisualMeasureTime = function(self, ...) return self.spaceData:getVisualMeasureTime(...) end
LayerData.getVisualTime = function(self, ...) return self.spaceData:getVisualTime(...) end
LayerData.computeVisualTime = function(self, ...) return self.spaceData:computeVisualTime(...) end
LayerData.updateZeroTimePoint = function(self) return self.spaceData:updateZeroTimePoint() end
LayerData.getZeroTimePoint = function(self) return self.spaceData:getZeroTimePoint() end

LayerData.getColumnCount = function(self) return self.noteDataSequence:getColumnCount() end
LayerData.addNoteData = function(self, ...) return self.noteDataSequence:addNoteData(...) end
LayerData.getNoteData = function(self, ...) return self.noteDataSequence:getNoteData(...) end
LayerData.getNoteDataCount = function(self) return self.noteDataSequence:getNoteDataCount() end
