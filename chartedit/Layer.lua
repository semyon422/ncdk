local class = require("class")
local Points = require("chartedit.Points")
local Intervals = require("chartedit.Intervals")
local Visual = require("chartedit.Visual")

---@class chartedit.Layer
---@operator call: chartedit.Layer
local Layer = class()

function Layer:new()
	self.points = Points()
	self.intervals = Intervals(self.points)
	self.visual = Visual()
end

return Layer
