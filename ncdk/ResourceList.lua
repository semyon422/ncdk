local ResourceList = {}

local ResourceList_metatable = {}
ResourceList_metatable.__index = ResourceList

ResourceList.new = function(self)
	local resourceList = {}
	
	resourceList.data = {}
	
	setmetatable(resourceList, ResourceList_metatable)
	
	return resourceList
end

ResourceList.add = function(self, type, name, sequence)
	local data = self.data
	data[type] = data[type] or {}
	data[type][name] = sequence
end

ResourceList.getIterator = function(self)
	local list = {}
	for type, data in pairs(self.data) do
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
