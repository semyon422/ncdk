o2jam.NoteChartImporter = {}
local NoteChartImporter = o2jam.NoteChartImporter

o2jam.NoteChartImporter_metatable = {}
local NoteChartImporter_metatable = o2jam.NoteChartImporter_metatable
NoteChartImporter_metatable.__index = NoteChartImporter

NoteChartImporter.new = function(self)
	local noteChartImporter = {}
	noteChartImporter.primaryTempo = 120
	
	setmetatable(noteChartImporter, NoteChartImporter_metatable)
	
	return noteChartImporter
end

NoteChartImporter.import = function(self, noteChartString)
	self.foregroundLayerData = self.noteChart.layerDataSequence:requireLayerData(1)
	self.backgroundLayerData = self.noteChart.layerDataSequence:requireLayerData(2)
	self.backgroundLayerData.invisible = true
	
	self.foregroundLayerData.timeData:setMode(ncdk.TimeData.Modes.Measure)
	self.backgroundLayerData.timeData:setMode(ncdk.TimeData.Modes.Measure)
	
	self.backgroundLayerData.timeData = self.foregroundLayerData.timeData
	
	self.ojn = o2jam.OJN:new(noteChartString)
	self:processData()
	self.noteChart:compute()
end

NoteChartImporter.processData = function(self)
	local longNoteData = {}
	
	for _, event in ipairs(self.ojn.charts[self.chartIndex].event_list) do
		local measureTime = ncdk.Fraction:new():fromNumber(event.measure + event.position, 1000)
		if event.channel == "BPM_CHANGE" then
			self.currentTempoData = ncdk.TempoData:new(
				measureTime,
				event.value
			)
			self.foregroundLayerData:addTempoData(self.currentTempoData)
			
			local timePoint = self.foregroundLayerData:getTimePoint(measureTime, -1)
			self.currentVelocityData = ncdk.VelocityData:new(timePoint, ncdk.Fraction:new():fromNumber(self.currentTempoData.tempo / self.primaryTempo, 1000))
			self.foregroundLayerData:addVelocityData(self.currentVelocityData)
		end
		if event.channel == "TIME_SIGNATURE" then
			self.foregroundLayerData:setSignature(
				event.measure,
				ncdk.Fraction:new():fromNumber(event.value * 4, 32768)
			)
		end
		if event.channel:find("NOTE") or event.channel:find("AUTO") then
			local timePoint = self.foregroundLayerData:getTimePoint(measureTime, -1)
			
			local noteData = ncdk.NoteData:new(timePoint)
			noteData.inputType = event.channel:find("NOTE") and "key" or "auto"
			noteData.inputIndex = event.channel:find("NOTE") and tonumber(event.channel:sub(-1, -1)) or 0
			
			-- noteData.soundFileName = tostring(event.value)
			noteData.soundFileIndex = event.value
			
			if noteData.inputType == "auto" then
				noteData.noteType = "SoundNote"
				self.backgroundLayerData:addNoteData(noteData)
			else
				if longNoteData[noteData.inputIndex] and event.type == "RELEASE" then
					longNoteData[noteData.inputIndex].noteType = "LongNoteStart"
					noteData.noteType = "LongNoteEnd"
					longNoteData[noteData.inputIndex] = nil
				else
					noteData.noteType = "ShortNote"
					if event.type == "HOLD" then
						longNoteData[noteData.inputIndex] = noteData
					end
				end
				self.foregroundLayerData:addNoteData(noteData)
			end
		end
	end
end

NoteChartImporter.processHeaderLine = function(self, line)
	local key, value = line:match("^#(%S+) (.+)$")
	self.noteChart:hashSet(key, value)
	
	if key == "BPM" then
		self.baseTempo = tonumber(value)
	elseif key == "LNOBJ" then
		self.lnobj = value
	end
end

NoteChartImporter.importBaseTimingData = function(self)
	if self.baseTempo then
		local measureTime = ncdk.Fraction:new(-1, 6)
		self.currentTempoData = ncdk.TempoData:new(measureTime, self.baseTempo)
		self.foregroundLayerData:addTempoData(self.currentTempoData)
		
		local timePoint = self.foregroundLayerData:getTimePoint(measureTime, 1)
		self.currentVelocityData = ncdk.VelocityData:new(timePoint, ncdk.Fraction:new():fromNumber(self.baseTempo / self.primaryTempo, 1000))
		self.foregroundLayerData:addVelocityData(self.currentVelocityData)
	end
end
