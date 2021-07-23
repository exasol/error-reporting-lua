local luaunit = require("luaunit")
local msgexpander = require("message_expander")

-- Lua 5.1 backward compatibility
_G.unpack = table.unpack or _G.unpack

test_message_expander = {}

local function assertMessageWithParametersRendersTo(message, parameters, expected)
    local expander = msgexpander:new({message = message, parameters = parameters})
   luaunit.assertEquals(expander:expand(), expected)
end

function test_message_expander.test_expand_clean_messages()
    local tests = {
        {
            message = "message with missing {{parameter}} values",
            expected = "message with missing {{parameter}} values"
        },
        {
            message = "before {{string}} after",
            parameters = {string = "replaced-string"},
            expected = "before 'replaced-string' after"
        },
        {
            message = 'The {{string|u}} is "{{number}}".',
            parameters = {string = "answer", number = 42},
            expected = "The answer is \"42\"."
        }
    }
    for _, test in ipairs(tests) do
        assertMessageWithParametersRendersTo(test.message, test.parameters, test.expected)
    end
end

function test_message_expander.test_expand_with_only_one_closing_bracket()
    assertMessageWithParametersRendersTo("1 {{n} 3", {n = 2}, "1 2 3")
end

function test_message_expander.test_expand_with_uq_switch()
    assertMessageWithParametersRendersTo("1 {{string|uq}} 3", {string = "s"}, "1 s 3")
end

os.exit(luaunit.LuaUnit.run())