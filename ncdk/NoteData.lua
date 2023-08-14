local class = require("class")

local NoteData = class()

NoteData.id = 0  -- for consistent sorting purposes only

function NoteData:new(timePoint)
	self.timePoint = timePoint
end

function NoteData:clone()
	local noteData = NoteData()
	for k, v in pairs(self) do
		noteData[k] = v
	end
	return noteData
end

function NoteData.__tostring(a)
	return ("note %s"):format(a.timePoint)
end

function NoteData.__eq(a, b)
	return a.timePoint == b.timePoint
end
function NoteData.__lt(a, b)
	return a.timePoint < b.timePoint or a.timePoint == b.timePoint and a.id < b.id
end
function NoteData.__le(a, b)
	return a.timePoint <= b.timePoint
end

return NoteData
