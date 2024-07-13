local class = require("class")
local rbtree = require("rbtree")
local table_util = require("table_util")

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
---@param column ncdk2.Column
---@return rbtree.Node?
function Notes:findNote(note, column)
	local tree = self:getTree(column)
	return (tree:find(note))
end

---@param note ncdk2.Note
---@param column ncdk2.Column
---@return rbtree.Node?
---@return string?
function Notes:addNote(note, column)
	local tree = self:getTree(column)
	return tree:insert(note)
end

---@param note ncdk2.Note
---@param column ncdk2.Column
---@return rbtree.Node?
---@return string?
function Notes:removeNote(note, column)
	local tree = self:getTree(column)
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

return Notes
