local class = require("class")

---@class ncdk.ResourceList
---@operator call: ncdk.ResourceList
local ResourceList = class()

---@param type string
---@param name string
---@param sequence table
function ResourceList:add(type, name, sequence)
	self[type] = self[type] or {}
	self[type][name] = sequence
end

---@return function
function ResourceList:getIterator()
	local list = {}
	for type, data in pairs(self) do
		for name, sequence in pairs(data) do
			list[#list + 1] = {type, name, sequence}
		end
	end
	local counter = 1

	return function()
		local resourceData = list[counter]
		if not resourceData then return end
		counter = counter + 1
		return unpack(resourceData)
	end
end

return ResourceList
