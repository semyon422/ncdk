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
	for _, object in ipairs(self.data) do
		if object.object == "meta" then
			self:processMetaData(object)
		elseif object.object == "layer" then
			self:processLayerData(object)
		elseif object.object == "velocity" then
			self:processVelocityData(object)
		elseif object.object == "note" then
			self:processNoteData(object)
		end
	end
end

NoteChartImporter.processMetaData = function(self, object)
	for key, value in pairs(object.data) do
		self.noteChart:hashSet(key, value)
	end
end

NoteChartImporter.processLayerData = function(self, object)
	local layerData = self.noteChart.layerDataSequence:requireLayerData(object.index)
	layerData.invisible = object.invisible
	
	if object.mode == "Measure" then
		layerData.timeData:setMode(ncdk.TimeData.Modes.Measure)
	elseif object.mode == "Absolute" then
		layerData.timeData:setMode(ncdk.TimeData.Modes.Absolute)
	end
end

NoteChartImporter.processVelocityData = function(self, object)
	local layerData = self.noteChart.layerDataSequence:requireLayerData(object.layer)
	
	local timeData = object.time:split(",")
	local time = tonumber(timeData[1])
	local side = tonumber(timeData[2]) or -1
	
	if layerData.timeData.mode == ncdk.TimeData.Modes.Measure then
		time = ncdk.Fraction:new():fromString(time)
	end
	
	local speedData = object.speed:split(",")
	
	local velocityData = ncdk.VelocityData:new(
		layerData:getTimePoint(time, side),
		ncdk.Fraction:new():fromString(speedData[1] or "1"),
		ncdk.Fraction:new():fromString(speedData[1] or "2"),
		ncdk.Fraction:new():fromString(speedData[1] or "3")
	)
	layerData:addVelocityData(velocityData)
end

NoteChartImporter.processNoteData = function(self, object)
	local layerData = self.noteChart.layerDataSequence:requireLayerData(object.layer)
	
	local timeData = object.time:split(",")
	local time = tonumber(timeData[1])
	local side = tonumber(timeData[2]) or -1
	
	if layerData.timeData.mode == ncdk.TimeData.Modes.Measure then
		time = ncdk.Fraction:new():fromString(time)
	end
	
	local timePoint = layerData:getTimePoint(time, side)
	
	local noteData = ncdk.NoteData:new(timePoint)
	noteData.inputType, noteData.inputIndex = object.input:match("^[a-z]+"), tonumber(object.input:match("[0-9]+$"))
	
	noteData.soundFileName = object.sound
	noteData.noteType = object.type
	
	layerData:addNoteData(noteData)
end
