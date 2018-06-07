bms.NoteChartImporter = {}
local NoteChartImporter = bms.NoteChartImporter

bms.NoteChartImporter_metatable = {}
local NoteChartImporter_metatable = bms.NoteChartImporter_metatable
NoteChartImporter_metatable.__index = NoteChartImporter

NoteChartImporter.new = function(self)
	local noteChartImporter = {}
	
	noteChartImporter.wavDataSequence = {}
	noteChartImporter.bpmDataSequence = {}
	noteChartImporter.stopDataSequence = {}
	
	noteChartImporter.primaryTempo = 120
	
	noteChartImporter.data = {}
	noteChartImporter.data.timeMatch = {}
	
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
	
	for _, line in ipairs(noteChartString:split("\n")) do
		self:processLine(line:trim())
	end
	
	table.sort(self.data, function(a, b)
		return a.measureTime < b.measureTime
	end)
	
	self:importBaseTimingData()
	self:processData()
	
	self.noteChart:compute()
end

NoteChartImporter.processLine = function(self, line)
	if line:find("^#WAV.. .+$") then
		local index, fileName = line:match("^#WAV(..) (.+)$")
		self.wavDataSequence[index] = fileName
	elseif line:find("^#BPM.. .+$") then
		local index, tempo = line:match("^#BPM(..) (.+)$")
		self.bpmDataSequence[index] = tonumber(tempo)
	elseif line:find("^#STOP.. .+$") then
		local index, duration = line:match("^#STOP(..) (.+)$")
		self.stopDataSequence[index] = tonumber(duration)
	elseif line:find("^#%d+:.+$") then
		self:processLineData(line)
	elseif line:find("^#[.%S]+ .+$") then
		self:processHeaderLine(line)
	end
end

NoteChartImporter.processLineData = function(self, line)
	local measureIndex, channelIndex, indexDataString = line:match("^#(%d%d%d)(%d%d):(.+)$")
	measureIndex = tonumber(measureIndex)
	
	if not bms.ChannelEnum[channelIndex] then
		return
	end
	
	if bms.ChannelEnum[channelIndex].name == "Signature" then
		self.foregroundLayerData:setSignature(
			measureIndex,
			ncdk.Fraction:new():fromNumber(tonumber((indexDataString:gsub(",", "."))) * 4, 32768)
		)
		return
	end
	
	local compound = bms.ChannelEnum[channelIndex].name ~= "BGM"
	
	if #indexDataString % 2 ~= 0 then
		print("warning")
		indexDataString = indexDataString:sub(1, -2)
	end
	
	for indexDataIndex = 1, #indexDataString / 2 do
		local value = indexDataString:sub(2 * indexDataIndex - 1, 2 * indexDataIndex)
		if value ~= "00" then
			local measureTime = measureIndex + ncdk.Fraction:new(indexDataIndex - 1, #indexDataString / 2)
			local measureTimeString = tostring(measureTime)
			
			local timeData
			if self.data.timeMatch[measureTimeString] then
				timeData = self.data.timeMatch[measureTimeString]
			else
				timeData = {}
				self.data.timeMatch[measureTimeString] = timeData
				table.insert(self.data, timeData)
				
				timeData.measureTime = measureTime
			end
			
			timeData[channelIndex] = timeData[channelIndex] or {}
			if compound then
				timeData[channelIndex][1] = value
			else
				table.insert(timeData[channelIndex], value)
			end
		end
	end
end

NoteChartImporter.processData = function(self)
	local longNoteData = {}
	
	for _, timeData in ipairs(self.data) do
		if timeData[bms.BackChannelEnum["Tempo"]] then
			local value = timeData[bms.BackChannelEnum["Tempo"]][1]
			self.currentTempoData = ncdk.TempoData:new(
				timeData.measureTime,
				tonumber(value, 16)
			)
			self.foregroundLayerData:addTempoData(self.currentTempoData)
			
			local timePoint = self.foregroundLayerData:getTimePoint(timeData.measureTime, -1)
			self.currentVelocityData = ncdk.VelocityData:new(timePoint, ncdk.Fraction:new():fromNumber(self.currentTempoData.tempo / self.primaryTempo, 1000))
			self.foregroundLayerData:addVelocityData(self.currentVelocityData)
		end
		if timeData[bms.BackChannelEnum["ExtendedTempo"]] then
			local value = timeData[bms.BackChannelEnum["ExtendedTempo"]][1]
			self.currentTempoData = ncdk.TempoData:new(
				timeData.measureTime,
				self.bpmDataSequence[value]
			)
			self.foregroundLayerData:addTempoData(self.currentTempoData)
			
			local timePoint = self.foregroundLayerData:getTimePoint(timeData.measureTime, -1)
			self.currentVelocityData = ncdk.VelocityData:new(timePoint, ncdk.Fraction:new():fromNumber(self.currentTempoData.tempo / self.primaryTempo, 1000))
			self.foregroundLayerData:addVelocityData(self.currentVelocityData)
		end
		if timeData[bms.BackChannelEnum["Stop"]] then
			local value = timeData[bms.BackChannelEnum["Stop"]][1]
			local measureDuration = ncdk.Fraction:new(self.stopDataSequence[value], 192)
			local stopData = ncdk.StopData:new(timeData.measureTime, measureDuration)
			stopData.duration = measureDuration:tonumber() * self.currentTempoData:getBeatDuration() * 4
			self.foregroundLayerData:addStopData(stopData)
			
			local timePoint = self.foregroundLayerData:getTimePoint(timeData.measureTime, -1)
			if self.currentVelocityData.timePoint == timePoint then
				self.foregroundLayerData:removeLastVelocityData()
			end
			self.currentVelocityData = ncdk.VelocityData:new(timePoint, ncdk.Fraction:new(0))
			self.foregroundLayerData:addVelocityData(self.currentVelocityData)
			
			local timePoint = self.foregroundLayerData:getTimePoint(timeData.measureTime)
			self.currentVelocityData = ncdk.VelocityData:new(timePoint, ncdk.Fraction:new():fromNumber(self.currentTempoData.tempo / self.primaryTempo, 1000))
			self.foregroundLayerData:addVelocityData(self.currentVelocityData)
		end
		
		for channelIndex, indexDataValues in pairs(timeData) do
			local channelInfo = bms.ChannelEnum[channelIndex]
			if channelInfo and (channelInfo.name == "Note" or channelInfo.name == "BGM") then
				for _, value in ipairs(indexDataValues) do
					local timePoint = self.foregroundLayerData:getTimePoint(timeData.measureTime, -1)
					
					local noteData = ncdk.NoteData:new(timePoint)
					noteData.inputType = channelInfo.inputType
					noteData.inputIndex = channelInfo.inputIndex
					
					noteData.soundFileName = self.wavDataSequence[value]
					
					if channelInfo.inputType == "auto" then
						noteData.noteType = "SoundNote"
						self.backgroundLayerData:addNoteData(noteData)
					elseif channelInfo.long then
						longNoteData[channelInfo.inputType] = longNoteData[channelInfo.inputType] or {}
						if not longNoteData[channelInfo.inputType][channelInfo.inputIndex] then
							noteData.noteType = "LongNoteStart"
							longNoteData[channelInfo.inputType][channelInfo.inputIndex] = true
						else
							noteData.noteType = "LongNoteEnd"
							longNoteData[channelInfo.inputType][channelInfo.inputIndex] = false
						end
						self.foregroundLayerData:addNoteData(noteData)
					else
						noteData.noteType = "ShortNote"
						self.foregroundLayerData:addNoteData(noteData)
					end
				end
			end
		end
	end
end

NoteChartImporter.processHeaderLine = function(self, line)
	if line:find("^#BPM %d+$") then
		self.baseTempo = tonumber(line:match("^#BPM (.+)$"))
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
