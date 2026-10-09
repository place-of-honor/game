-- Packaging bootstrap for the unchanged LuaJIT 2.1 bytecode format.
-- The maintained game source remains main.lua; the producer emits both frames.
local bit = require("bit")
local header = string.dump(function() end)
assert(header:sub(1, 4) == "\27LJ\2", "This game requires LuaJIT bytecode version 2")
local frame = bit.band(header:byte(5), 8) == 0 and "fr1" or "fr2"
assert(love.filesystem.load("compiled/main-" .. frame .. ".ljbc"))()
