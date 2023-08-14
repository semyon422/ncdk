local ncdk = require("ncdk")

local InputMode = ncdk.InputMode

assert(InputMode() == InputMode())
assert(InputMode() == InputMode())
assert(InputMode("4key") == InputMode({key = 4}))
assert(InputMode("7key1scratch") == InputMode({key = 7, scratch = 1}))
assert(tostring(InputMode("7key1scratch")) == "7key1scratch")
