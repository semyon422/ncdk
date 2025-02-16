local class = require("class")
local rbtree = require("rbtree")
local table_util = require("table_util")
local LinkedNote = require("ncdk2.notes.LinkedNote")

---@class chartedit.Notes
---@operator call: chartedit.Notes
---@field trees {[ncdk2.Column]: rbtree.Tree}
local Notes = class()

function Notes:new()
	self.trees = {}
end

---@param column ncdk2.Column
---@return rbtree.Tree
function Notes:getTree(column)
	return table_util.get_or_create(self.trees, column, rbtree.new)
end

---@param note ncdk2.Note
---@return rbtree.Node?
function Notes:findNote(note)
	local tree = self:getTree(note.column)
	return (tree:find(note))
end

---@param note ncdk2.Note
---@return rbtree.Node?
---@return string?
function Notes:addNote(note)
	local tree = self:getTree(note.column)
	return tree:insert(note)
end

---@param note ncdk2.Note
---@return rbtree.Node?
---@return string?
function Notes:removeNote(note)
	local tree = self:getTree(note.column)
	return tree:remove(note)
end

---@param note ncdk2.Note
local function ex_vp(note)
	return note.visualPoint
end

---@param vp chartedit.VisualPoint
function Notes:removeAll(vp)
	for _, tree in pairs(self.trees) do
		local a = tree:findex(vp, ex_vp)
		if a then
			---@type ncdk2.Note
			local note = a.key
			tree:remove(note)
		end
	end
end

---@param note ncdk2.Note
local function ex_time(note)
	return note:getTime()
end

---@param start_time number?
---@param end_time number?
---@return fun(): ncdk2.Note, ncdk2.Column
function Notes:iter(start_time, end_time)
	start_time = start_time or -math.huge
	end_time = end_time or math.huge
	return coroutine.wrap(function()
		for column, tree in pairs(self.trees) do
			local a, b = tree:findex(start_time, ex_time)
			a = a or b
			a = a and a:prev() or a
			while a do
				---@type ncdk2.Note
				local note = a.key
				if note:getTime() > end_time then
					break
				end
				coroutine.yield(note, column)
				a = a:next()
			end
		end
	end)
end

---@param ctn_stack {[ncdk2.Column]: {[ncdk2.NoteType]: ncdk2.Note[]}}
local function is_ctn_stack_empty(ctn_stack)
	for _, t in pairs(ctn_stack) do
		for _, notes in pairs(t) do
			if notes[1] then
				return false
			end
		end
	end
	return true
end

---@param start_time number?
---@param end_time number?
---@return fun(): ncdk2.LinkedNote, ncdk2.Column
function Notes:iterLinked(start_time, end_time)
	start_time = start_time or -math.huge
	end_time = end_time or math.huge

	return coroutine.wrap(function()
		for column, tree in pairs(self.trees) do
			local a, b = tree:findex(start_time, ex_time)
			a = a or b
			a = a and a:prev() or a

			---@type {[ncdk2.Column]: {[ncdk2.NoteType]: ncdk2.Note[]}}
			local ctn_stack = {}

			while a do
				---@type ncdk2.Note
				local note = a.key
				if note:getTime() > end_time and is_ctn_stack_empty(ctn_stack) then
					break
				end

				local c, t = note.column, note.type
				if note.weight == 0 then
					coroutine.yield(LinkedNote(note), column)
				elseif note.weight == 1 then
					ctn_stack[c] = ctn_stack[c] or {}
					ctn_stack[c][t] = ctn_stack[c][t] or {}
					table.insert(ctn_stack[c][t], note)
				elseif note.weight == -1 and ctn_stack[c] and ctn_stack[c][t] then
					local start_note = table.remove(ctn_stack[c][t])
					coroutine.yield(LinkedNote(start_note, note), column)
				end

				a = a:next()
			end
		end
	end)
end

---@param start_time number?
---@param end_time number?
---@return ncdk2.Note[]
function Notes:getNotes(start_time, end_time)
	---@type ncdk2.Note[]
	local notes = {}
	for note in self:iter(start_time, end_time) do
		table.insert(notes, note)
	end
	table.sort(notes)
	return notes
end

---@param start_time number?
---@param end_time number?
---@return ncdk2.LinkedNote[]
function Notes:getLinkedNotes(start_time, end_time)
	---@type ncdk2.LinkedNote[]
	local notes = {}
	for note in self:iterLinked(start_time, end_time) do
		table.insert(notes, note)
	end
	table.sort(notes)
	return notes
end

return Notes
