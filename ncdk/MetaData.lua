ncdk.MetaData = {}
local MetaData = ncdk.MetaData

ncdk.MetaData_metatable = {}
local MetaData_metatable = ncdk.MetaData_metatable
MetaData_metatable.__index = MetaData

MetaData.new = function(self)
	local metaData = {}
	metaData.hash = {}
	setmetatable(metaData, MetaData_metatable)
	
	return metaData
end

MetaData.hashSet = function(self, key, value)
	self.hash[key] = value
end

MetaData.hashGet = function(self, key)
	return self.hash[key]
end