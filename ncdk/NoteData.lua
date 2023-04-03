local NoteData = {}

local mt = {__index = NoteData}

NoteData.id = 0  -- for consistent sorting purposes only

function NoteData:new(timePoint)
	return setmetatable({timePoint = timePoint}, mt)
end

function NoteData:clone()
	local noteData = NoteData:new()
	for k, v in pairs(self) do
		noteData[k] = v
	end
	return noteData
end

function mt.__tostring(a)
	return ("note %s"):format(a.timePoint)
end

function mt.__eq(a, b)
	return a.timePoint == b.timePoint
end
function mt.__lt(a, b)
	return a.timePoint < b.timePoint or a.timePoint == b.timePoint and a.id < b.id
end
function mt.__le(a, b)
	return a.timePoint <= b.timePoint
end

return NoteData
