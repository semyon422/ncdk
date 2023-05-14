package.path = package.path .. ";./?.lua;./?/init.lua"
package.loaded.rbtree = dofile("../aqua/rbtree.lua")

io.write("fraction: ")
require("tests.fraction")
print("OK!")

io.write("input_mode: ")
require("tests.input_mode")
print("OK!")

io.write("base: ")
require("tests.base")
print("OK!")

print("dynamic: ")
require("tests.dynamic")
print("OK!")

print("TimeData_unit: ")
require("tests.TimeData_unit")
print("OK!")

print("RangeTracker: ")
require("tests.tracker")
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
