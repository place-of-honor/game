local root, expected_frame = assert(arg[1]), assert(arg[2])
local bit = require("bit")
local header = string.dump(function() end)
assert(header:sub(1, 4) == "\27LJ\2")
local frame = bit.band(header:byte(5), 8) == 0 and "fr1" or "fr2"
assert(frame == expected_frame)
local wrong = frame == "fr1" and "fr2" or "fr1"
local wrong_chunk, wrong_error = loadfile(root .. "/compiled/main-" .. wrong .. ".ljbc")
assert(wrong_chunk == nil and wrong_error:find("incompatible bytecode", 1, true))
local calls = {}
local background
local exited = false
love = {
    filesystem = {load = function(path) return loadfile(root .. "/" .. path) end},
    graphics = {
        getDimensions = function() return 960, 540 end,
        setBackgroundColor = function(...) background = {...} end,
        printf = function(...) calls[#calls + 1] = {...} end,
    },
    event = {quit = function() exited = true end},
}
assert(loadfile(root .. "/main.lua"))()
love.load()
assert(background[1] == 0.08 and background[2] == 0.09 and background[3] == 0.12)
love.update(0.01)
love.draw()
assert(#calls == 2)
assert(calls[1][1] == "Game" and calls[1][2] == 0 and calls[1][3] == 246)
assert(calls[2][1] == "Edit main.lua to start building." and calls[2][3] == 282)
assert(calls[1][4] == 960 and calls[2][4] == 960)
assert(calls[1][5] == "center" and calls[2][5] == "center")
love.keypressed("escape")
assert(exited)
print("stock LuaJIT " .. frame .. " packaged callbacks and opposite-frame rejection: PASS")
