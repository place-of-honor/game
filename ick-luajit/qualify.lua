local function evaluate(source, split)
    local chunk, message
    if split then
        local index = 0
        chunk, message = load(function()
            index = index + 1
            if index <= #source then return source:sub(index, index) end
        end, "=division-reader")
    else
        chunk, message = loadstring(source, "=division-reader")
    end
    assert(chunk, message)
    return chunk()
end

local fixtures = {
    {"return 7÷2", 3.5},
    {"return 24÷3÷2", 4},
    {"return 2+12÷3", 6},
    {"return -7÷2", -3.5},
    {"return 0x18÷3", 8},
    {"local value=24; return value÷3", 8},
    {"local café=18; return café÷3", 6},
    {"-- ÷ and café remain comment bytes\nreturn 8÷2", 4},
    {"--[=[ ÷ ]=]\nreturn 8÷2", 4},
    {"return #('÷')", 2},
    {"return #([=[÷]=])", 2},
    {"return 8 / 2", 4},
}
for _, fixture in ipairs(fixtures) do
    assert(evaluate(fixture[1], false) == fixture[2])
    assert(evaluate(fixture[1], true) == fixture[2])
end
assert(7 ÷ 2 == 3.5)
local calls = 0
local box = setmetatable({value = 24}, {
    __div = function(left, right)
        calls = calls + 1
        return left.value / right
    end,
})
assert(box ÷ 3 == 8 and calls == 1)
assert("÷" == "\195\183" and [=[÷]=] == "\195\183")
assert(loadstring("return 8÷=2") == nil)
assert(loadstring("return 8∕2") == nil)
assert(loadstring("return 8//2") == nil)
assert(evaluate("return 1÷0", true) == math.huge)
print("division lexer, raw strings/comments, UTF-8 identifiers and split readers: PASS")
