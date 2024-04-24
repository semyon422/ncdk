local class = require("class")

---@class ncdk2.NoteDatas
---@operator call: ncdk2.NoteDatas
---@field data {[string]: {[number]: ncdk2.NoteData[]}}
local NoteDatas = class()

function NoteDatas:new()
	self.data = {}
end

function NoteDatas:sort()
	for _, r in pairs(self.data) do
		for _, noteDatas in pairs(r) do
			table.sort(noteDatas)
		end
	end
end

---@param noteData ncdk2.NoteData
---@param inputType string
---@param inputIndex number
function NoteDatas:addNoteData(noteData, inputType, inputIndex)
	local noteDatas = self:getNoteDatasList(inputType, inputIndex)
	table.insert(noteDatas, noteData)
	noteData.id = #noteDatas
end

---@param inputType string
---@param inputIndex number
---@return ncdk2.NoteData[]
function NoteDatas:getNoteDatasList(inputType, inputIndex)
	local data = self.data
	data[inputType] = data[inputType] or {}
	data[inputType][inputIndex] = data[inputType][inputIndex] or {}
	return data[inputType][inputIndex]
end

return NoteDatas
