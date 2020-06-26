local MetaData = {}

MetaData.defaults = {}

MetaData.new = function(self)
	local metaData = {}
	
	metaData.data = {}
	
	setmetatable(metaData, self)
	self.__index = self
	
	return metaData
end

MetaData.setDefaults = function(self)
	local defaults = self.defaults
	local data = self.data

	for k, v in pairs(defaults) do
		data[k] = v
	end
end

MetaData.set = function(self, key, value)
	local typeDefault = type(self.defaults[key])

	if typeDefault == "string" then
		self.data[key] = tostring(value)
	elseif typeDefault == "number" then
		self.data[key] = tonumber(value)
	end
end

MetaData.get = function(self, key)
	return self.data[key]
end

MetaData.setTable = function(self, t)
	for k, v in pairs(t) do
		self:set(k, v)
	end
end

MetaData.getTable = function(self)
	local t = {}

	for k, v in pairs(self.data) do
		t[k] = v
	end

	return t
end

return MetaData
