local luaunit = require("luaunit")
local msgexpander = require("message_expander")

-- Lua 5.1 backward compatibility
_G.unpack = table.unpack or _G.unpack

test_message_expander = {}

local function assertMessageWithParametersRendersTo(message, parameters, expected)
    local expander = msgexpander:new({message = message, parameters = parameters})
    luaunit.assertEquals(expander:expand(), expected)
end

function test_message_expander.test_expand_message_without_parameter_values()
    assertMessageWithParametersRendersTo("message with missing {{parameter}} values", nil,
        "message with missing {{parameter}} values")
end

function test_message_expander.test_expand_autoquoted_string()
    assertMessageWithParametersRendersTo("before {{string}} after", {string = "replaced-string"},
        "before 'replaced-string' after")
end

function test_message_expander.test_expand_boolean_parameter()
    assertMessageWithParametersRendersTo("before {{value}} after", {value = true},
        "before true after")
end

function test_message_expander.test_expand_integer_parameter()
    assertMessageWithParametersRendersTo("before {{value}} after", {value = 1234},
        "before 1234 after")
end

function test_message_expander.test_expand_float_parameter()
    assertMessageWithParametersRendersTo("before {{value}} after", {value = 3.14},
        "before 3.14 after")
end

function test_message_expander.test_expand_table_parameter()
    assertMessageWithParametersRendersTo("before {{value}} after", {value = {a=1}},
        "before  after")
end

function test_message_expander.test_unquoted()
    assertMessageWithParametersRendersTo('The {{string|u}} is "{{number}}".', {string = "answer", number = 42},
        'The answer is "42".')
end

function test_message_expander.test_expand_with_only_one_closing_bracket()
    assertMessageWithParametersRendersTo("1 {{n} 3", {n = 2}, "1 2 3")
end

function test_message_expander.test_expand_with_u_plus_q_switch()
    assertMessageWithParametersRendersTo("1 {{string|uq}} 3", {string = "s"}, "1 s 3")
end

function test_message_expander.test_expand_with_u_switch()
    assertMessageWithParametersRendersTo("1 {{string|u}} 3", {string = "s"}, "1 s 3")
end

function test_message_expander.test_expand_with_parameter_description()
    assertMessageWithParametersRendersTo("yesterday {{day}} tomorrow",
        {day = {value = "today", description = "current day"}},
        "yesterday 'today' tomorrow")
end

os.exit(luaunit.LuaUnit.run())
