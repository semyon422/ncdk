local class = require("class")

---@class refchart.Note
---@operator call: refchart.Note
---@field point refchart.VisualPointReference
---@field column ncdk2.Column
---@field type ncdk2.NoteType
---@field weight integer
local Note = class()

return Note
