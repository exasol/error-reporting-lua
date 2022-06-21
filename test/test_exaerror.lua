package.path = "src/?.lua;" .. package.path

local luaunit = require("luaunit")
local ExaError = require("ExaError")

-- Lua 5.1 backward compatibility
_G.unpack = table.unpack or _G.unpack

test_exaerror = {}

function test_exaerror.test_get_code()
    local msg = ExaError:new("E-FOOBAR-1")
    luaunit.assertEquals(msg:get_code(), "E-FOOBAR-1")
end

function test_exaerror.test_get_message()
    local msg = ExaError:new("E-FOOBAR-1", "This is a message.")
    luaunit.assertEquals(msg:get_message(), "This is a message.")
end

function test_exaerror.test_get_interpolated_message_with_single_string()
    local msg = ExaError:new("W-BARZOO-2", "Foo {{string}}", {string = "a text"})
    luaunit.assertEquals(msg:get_message(), "Foo 'a text'")
end

function test_exaerror.test_get_interpolated_message_with_string_and_number()
    local msg = ExaError:new("W-BARZOO-2", 'The {{string}} is "{{number}}".', {string = "answer", number = 42})
    luaunit.assertEquals(msg:get_message(), "The 'answer' is \"42\".")
end

function test_exaerror.test_get_interpolated_message_with_boolean()
    local msg = ExaError:new("W-BARZOO-2", 'The result is {{bool}}.', {bool=true})
    luaunit.assertEquals(msg:get_message(), "The result is true.")
end

function test_exaerror.test_get_interpolated_message_with_nil()
    local msg = ExaError:new("W-BARZOO-2", 'The result is {{value}}.', {value=nil})
    luaunit.assertEquals(msg:get_message(), "The result is {{value}}.")
end

function test_exaerror.test_get_interpolated_message_with_float()
    local msg = ExaError:new("W-BARZOO-2", 'The value of pi is {{pi}}.', {pi=3.14})
    luaunit.assertEquals(msg:get_message(), "The value of pi is 3.14.")
end

function test_exaerror.test_get_interpolated_message_with_value_in_table()
    local msg = ExaError:new("W-BARZOO-2", 'The result is {{table}}.', {table={value="value"}})
    luaunit.assertEquals(msg:get_message(), "The result is 'value'.")
end

function test_exaerror.test_get_interpolated_message_with_table()
    local msg = ExaError:new("W-BARZOO-2", 'The result is {{table}}.', {table={a=1}})
    luaunit.assertEquals(msg:get_message(), "The result is .")
end

function test_exaerror.test_get_parameter_description()
    local msg = ExaError:new("E-A-1", "A, {{b}}, {{c}}", {
            b = {value = "B", description = "the B"},
            c = {value = "C", description = "the C"}
        }
    )
    luaunit.assertEquals(msg:get_parameter_description("c"), "the C")
end

function test_exaerror.test_get_missing_parameter_description()
    local msg = ExaError:new("E-A-1", "A, {{b}}, {{c}}", {
            b = {value = "B"},
            c = {value = "C", description = "the C"}
        }
    )
    luaunit.assertEquals(msg:get_parameter_description("b"), "<missing parameter description>")
end

function test_exaerror.test_get_mitigations()
    local msg = ExaError:new("F-FOO-BAR-123"):add_mitigations("Do A.", "Don't do B.")
    luaunit.assertEquals(msg:get_mitigations(), "Do A.", "Don't do B.")
end

function test_exaerror.test_tostring_metamethod_with_code_only()
    local msg = ExaError:new("E-FOOBAR-1")
    luaunit.assertEquals(tostring(msg), "E-FOOBAR-1")
end

function test_exaerror.test_tostring_metamethod_with_message_only()
    local msg = ExaError:new(nil, "Hello test!")
    luaunit.assertEquals(tostring(msg), "Hello test!")
end

function test_exaerror.test_tostring_metamethod_with_mitigations_only()
    local msg = ExaError:new(nil, nil, nil, {"Turn off.", "Turn on again."})
    luaunit.assertEquals(tostring(msg), [[
<Missing error message. This should not happen. Please contact the software maker.>

Mitigations:

* Turn off.
* Turn on again.]])
end

function test_exaerror.test_tostring_metamethod_with_undefined_error()
    local msg = ExaError:new()
    luaunit.assertEquals(tostring(msg),
        "<Missing error message. This should not happen. Please contact the software maker.>")
end

function test_exaerror.test_tostring_metamethod_with_mitigation_parameters()
    local msg = ExaError:new("Unexpected error.", nil, {url = "www.example.org/issues?create"},
            {"Please create an error report under {{url}}"})
    luaunit.assertEquals(tostring(msg),
        [[Unexpected error.

Mitigations:

* Please create an error report under 'www.example.org/issues?create']])
end

function test_exaerror.test_concatenation_metamethod()
    local err = ExaError:new("I-CONCAT-1")
    local tests = {
        {left = "left", right = err, expected = "leftI-CONCAT-1"},
        {left = 12345, right = err, expected = "12345I-CONCAT-1"},
        {left = err, right = "right", expected = "I-CONCAT-1right"},
        {left = err, right = 54321, expected = "I-CONCAT-154321"}
    }
    for _, test in ipairs(tests) do
        local text = test.left .. test.right
        luaunit.assertEquals(text, test.expected)
    end
end

function test_exaerror.test_new()
    local msg = ExaError:new("SQL-1234", "Metadata query timed out after {{timeout}} seconds.",
            {timeout = 500},
            {
                "Use lock-free metadata queries.",
                "Check for recursion."
            }
    )
    luaunit.assertEquals(tostring(msg),
        [[SQL-1234: Metadata query timed out after 500 seconds.

Mitigations:

* Use lock-free metadata queries.
* Check for recursion.]])
end

function test_exaerror.test_new_with_parameter_descriptions()
    local msg = ExaError:new("SQL-2777", "Connection refused by host {{host}}" ,
        {host = {description = "Host or IP address", value = "jupiter.example.com"}})
    luaunit.assertEquals(tostring(msg), "SQL-2777: Connection refused by host 'jupiter.example.com'")
    luaunit.assertEquals(msg:get_parameters(),
        {host = {description = "Host or IP address", value = "jupiter.example.com"}})
end

function test_exaerror.test_create_with_parameter_descriptions()
    local msg = ExaError:new("SQL-2777", "Connection refused by host {{host}}",
        {host = {description = "Host or IP address", value = "jupiter.example.com"}}    )
    luaunit.assertEquals(tostring(msg), "SQL-2777: Connection refused by host 'jupiter.example.com'")
    luaunit.assertEquals(msg:get_parameters(),
        {host = {description = "Host or IP address", value = "jupiter.example.com"}})
end

function test_exaerror.test_embedding_in_lua_error()
    luaunit.assertErrorMsgContains(
        "E-IO-13: Need 500.2 MiB space, but only 14.8 MiB.",
        function ()
            error(ExaError:new("E-IO-13", "Need {{needed}} MiB space, but only {{remaining}} MiB.",
                {needed = 500.2, remaining = 14.8}))
        end
    )
end

function test_exaerror.test_throw_error_directly()
    luaunit.assertErrorMsgContains(
        "I-IO-1: 7 down, 4 to go.",
        function ()
            ExaError.error("I-IO-1", "{{a}} down, {{b}} to go.", {a = 7, b = 4})
        end
    )
end

function test_exaerror.test_throw_error_directly_with_mitigations()
    luaunit.assertErrorMsgContains(
        [[E-IO-13: Need 500.2 MiB space, but only 14.8 MiB left on device '/dev/sda4'.

Mitigations:

* Try #1.
* Or #2.]],
        function ()
            ExaError.error(
                    "E-IO-13",
                    "Need {{needed}} MiB space, but only {{remaining}} MiB left on device {{device}}.",
                    {needed = 500.2, remaining = 14.8, device = "/dev/sda4"},
                    {"Try #1.", "Or #2."}
            )
        end
    )
end

function test_exaerror.test_add_ticket_mitigation()
    local err = ExaError:new("F-REQ-1", "Unsupported request type detected.")
                        :add_ticket_mitigation()
    luaunit.assertEquals(tostring(err), [[F-REQ-1: Unsupported request type detected.

Mitigations:

* This is an internal software error. Please report it via the project's ticket tracker.]])
end

local function nest_raise_call(level)
    ExaError:new("E-1", "Test stack trace levels"):raise(level)
end

function test_exaerror.test_raise_with_stack_trace_disabled_by_setting_level_0()
    luaunit.assertErrorMsgEquals("E-1: Test stack trace levels", nest_raise_call, 0)
end

function test_exaerror.test_raise_with_stack_trace_level_1()
    luaunit.assertErrorMsgMatches(".*/ExaError%.lua:[0-9]+: E%-1: Test stack trace levels", nest_raise_call, 1)
end

function test_exaerror.test_raise_with_stack_trace_level_2()
    luaunit.assertErrorMsgMatches(".*/test_exaerror%.lua:[0-9]+: E%-1: Test stack trace levels", nest_raise_call, 2)
end

function test_exaerror.test_raise_uses_default_stack_trace_level_2()
    luaunit.assertErrorMsgMatches(".*/test_exaerror%.lua:[0-9]+: E%-1: Test stack trace levels", nest_raise_call)
end

os.exit(luaunit.LuaUnit.run())
