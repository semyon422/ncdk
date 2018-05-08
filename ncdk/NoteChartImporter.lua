ncdk.NoteChartImporter = {}
local NoteChartImporter = ncdk.NoteChartImporter

ncdk.NoteChartImporter_metatable = {}
local NoteChartImporter_metatable = ncdk.NoteChartImporter_metatable
NoteChartImporter_metatable.__index = NoteChartImporter

NoteChartImporter.new = function(self)
	local noteChartImporter = {}
	
	setmetatable(noteChartImporter, NoteChartImporter_metatable)
	
	return noteChartImporter
end

NoteChartImporter.objectTypeEnum = {
	SignatureTable = 0,
	TempoData = 1,
	VelocityData = 2,
	NoteData = 3
}

NoteChartImporter.ObjectDataEnum = {
	LayerDataIndex = 1,
	ObjectType = 2
}

NoteChartImporter.import = function(self, noteChartString)
	for _, line in ipairs(noteChartString:split("\n")) do
		line = line:trim()
		if #line > 0 then
			local lineTable = line:split(",")
			
			local layerDataIndex = tonumber(lineTable[self.ObjectDataEnum.LayerDataIndex])
			local objectType = tonumber(lineTable[self.ObjectDataEnum.ObjectType])
			
			local layerData = self.noteChart.layerDataSequence:requireLayerData(layerDataIndex)
			
			if objectType == self.objectTypeEnum.TempoData then
				layerData:addTempoData(ncdk.TempoDataImporter:new(lineTable):getTempoData())
			elseif objectType == self.objectTypeEnum.SignatureTable then
				layerData:setSignatureTable(ncdk.SignatureTableImporter:new(lineTable):getSignatureTable())
			elseif objectType == self.objectTypeEnum.VelocityData then
				layerData:addVelocityData(ncdk.VelocityDataImporter:new(lineTable):getVelocityData(layerData.timeData))
			elseif objectType == self.objectTypeEnum.NoteData then
				layerData:addNoteData(ncdk.NoteDataImporter:new(lineTable):getNoteData(layerData))
			end
		end
	end
end