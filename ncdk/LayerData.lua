local TimeData = require("ncdk.TimeData")

local LayerData = {}

local mt = {__index = LayerData}

function LayerData:new()
	local layerData = {}

	layerData.timeData = TimeData:new()
	layerData.noteDatas = {}

	return setmetatable(layerData, mt)
end

local function sortNotes(a, b)
	if a.timePoint == b.timePoint then
		return a.id < b.id
	end
	return a.timePoint < b.timePoint
end

function LayerData:compute()
	self.timeData:sort()
	table.sort(self.noteDatas, sortNotes)

	self.timeData:computeTimePoints()
end

function LayerData:setSignature(...) return self.timeData:setSignature(...) end
function LayerData:getSignature(...) return self.timeData:getSignature(...) end
function LayerData:addTempoData(...) return self.timeData:addTempoData(...) end
function LayerData:getTempoData(...) return self.timeData:getTempoData(...) end
function LayerData:getTempoDataCount() return self.timeData:getTempoDataCount() end
function LayerData:addStopData(...) return self.timeData:addStopData(...) end
function LayerData:getStopData(...) return self.timeData:getStopData(...) end
function LayerData:getStopDataCount() return self.timeData:getStopDataCount() end
function LayerData:getTimePoint(...) return self.timeData:getTimePoint(...) end
function LayerData:setTimeMode(...) return self.timeData:setMode(...) end
function LayerData:setSignatureMode(...) return self.timeData:setSignatureMode(...) end

function LayerData:addVelocityData(...) return self.timeData:addVelocityData(...) end
function LayerData:removeLastVelocityData(...) return self.timeData:removeLastVelocityData(...) end
function LayerData:getVelocityData(...) return self.timeData:getVelocityData(...) end
function LayerData:getVelocityDataCount() return self.timeData:getVelocityDataCount() end
function LayerData:getVisualMeasureTime(...) return self.timeData:getVisualMeasureTime(...) end
function LayerData:getVisualTime(...) return self.timeData:getVisualTime(...) end

function LayerData:addNoteData(noteData)
	local noteDatas = self.noteDatas
	table.insert(noteDatas, noteData)
	noteData.id = #noteDatas

	self.noteChart:increaseInputCount(noteData.inputType, noteData.inputIndex, 1)
end

function LayerData:getNoteData(i) return self.noteDatas[i] end
function LayerData:getNoteDataCount() return #self.noteDatas end

return LayerData
