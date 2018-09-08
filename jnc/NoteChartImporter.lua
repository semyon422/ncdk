jnc.NoteChartImporter = {}
local NoteChartImporter = jnc.NoteChartImporter

jnc.NoteChartImporter_metatable = {}
local NoteChartImporter_metatable = jnc.NoteChartImporter_metatable
NoteChartImporter_metatable.__index = NoteChartImporter

NoteChartImporter.new = function(self)
	local noteChartImporter = {}
	noteChartImporter.data = {}
	setmetatable(noteChartImporter, NoteChartImporter_metatable)
	
	return noteChartImporter
end

NoteChartImporter.import = function(self, noteChartString)
	self.data = json.decode(noteChartString)
	self:processData()
	self.noteChart:compute()
end

NoteChartImporter.processData = function(self)
	for layerDataIndex, rawLayerData in ipairs(self.data.layerDataSequence) do
		local layerData = self.noteChart.layerDataSequence:requireLayerData(layerDataIndex)
		layerData.invisible = rawLayerData.invisible
		
		local rawTimeData = rawLayerData.timeData
		if rawTimeData.mode == "Measure" then
			layerData.timeData:setMode(ncdk.TimeData.Modes.Measure)
		elseif rawTimeData.mode == "Absolute" then
			layerData.timeData:setMode(ncdk.TimeData.Modes.Absolute)
		end
		
		if rawTimeData.mode == "Measure" then
			for measureIndex, signature in pairs(rawTimeData.signatureTable) do
				layerData:setSignature(
					tonumber(measureIndex),
					ncdk.Fraction:new():fromString(signature)
				)
			end
			
			for _, rawTempoData in ipairs(rawTimeData.tempoDataSequence) do
				layerData:addTempoData(ncdk.TempoData:new(
					ncdk.Fraction:new():fromString(rawTempoData.time),
					rawTempoData.tempo
				))
			end
			
			for _, rawStopData in ipairs(rawTimeData.stopDataSequence) do
				local time = ncdk.Fraction:new():fromString(rawTempoData.time)
				local duration = ncdk.Fraction:new():fromString(rawStopData.duration)
				local stopData = ncdk.StopData:new(time, duration)
				layerData:addStopData(stopData)
			end
		end
		
		local rawSpaceData = rawLayerData.spaceData
		
		for _, rawVelocityData in ipairs(rawSpaceData.velocityDataSequence) do
			local time, visualEndTime = tonumber(rawVelocityData.time), tonumber(rawVelocityData.visualEndTime)
			if rawTimeData.mode == "Measure" then
				time = ncdk.Fraction:new():fromString(rawVelocityData.time)
				visualEndTime = ncdk.Fraction:new():fromString(rawVelocityData.visualEndTime)
			end
			
			local velocityData = ncdk.VelocityData:new(
				layerData:getTimePoint(time, rawVelocityData.side),
				ncdk.Fraction:new():fromString(rawVelocityData.currentSpeed),
				ncdk.Fraction:new():fromString(rawVelocityData.localSpeed),
				ncdk.Fraction:new():fromString(rawVelocityData.globalSpeed),
				layerData:getTimePoint(visualEndTime)
			)
			layerData:addVelocityData(velocityData)
		end
		
		for _, rawNoteData in ipairs(rawLayerData.noteDataSequence) do
			local time = tonumber(rawNoteData.time)
			if rawTimeData.mode == "Measure" then
				time = ncdk.Fraction:new():fromString(rawNoteData.time)
			end
			local timePoint = layerData:getTimePoint(time, rawNoteData.side)
			
			local noteData = ncdk.NoteData:new(timePoint)
			noteData.inputType = rawNoteData.inputType
			noteData.inputIndex = rawNoteData.inputIndex
			
			noteData.soundFileName = rawNoteData.soundFileName
			noteData.noteType = rawNoteData.noteType
			
			layerData:addNoteData(noteData)
		end
	end
end
