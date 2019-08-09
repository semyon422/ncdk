package.path = package.path .. ";./?.lua;./?/init.lua"

io.write("fraction: ")
require("tests.fraction")
print("OK!")

io.write("base: ")
require("tests.base")
print("OK!")
