assert(love.filesystem.load("loader.lua"))()
local original_draw = love.draw
love.draw = function()
    local width, height = love.graphics.getDimensions()
    local original_printf = love.graphics.printf
    local positions = {}
    love.graphics.printf = function(text, x, y, limit, alignment)
        assert(x == 0 and limit == width and alignment == "center")
        positions[#positions + 1] = y
        original_printf(text, x, y, limit, alignment)
    end
    original_draw()
    love.graphics.printf = original_printf
    assert(#positions == 2)
    -- ASCII compatibility arithmetic intentionally runs in the stock engine.
    assert(positions[1] == height / 2 - 24 and positions[2] == height / 2 + 12)
    print("real LÖVE draw and frame-selected bytecode: PASS")
    love.event.quit(0)
end
