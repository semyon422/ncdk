package.path = package.path .. ";./?.lua;./?/init.lua"

io.write("fraction: ")
require("tests.fraction")
print("OK!")

io.write("reference_create_measure: ")
require("tests.reference_create_measure")
print("OK!")

io.write("reference_create_absolute: ")
require("tests.reference_create_absolute")
print("OK!")

io.write("reference_use_notechart: ")
require("tests.reference_use_notechart")
print("OK!")

io.write("base: ")
require("tests.base")
print("OK!")
