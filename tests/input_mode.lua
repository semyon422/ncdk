local ncdk = require("ncdk")

local InputMode = ncdk.InputMode

assert(InputMode() == InputMode())
assert(InputMode:new() == InputMode:new())
assert(InputMode:new("4key") == InputMode:new({key = 4}))
assert(InputMode:new("7key1scratch") == InputMode:new({key = 7, scratch = 1}))
assert(tostring(InputMode:new("7key1scratch")) == "7key1scratch")
