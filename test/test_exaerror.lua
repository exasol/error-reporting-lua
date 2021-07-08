local luaunit = require("luaunit")
local exaerror = require("exaerror")

-- Lua 5.1 backward compatibility
_G.unpack = table.unpack or _G.unpack

test_exaerror = {}

function test_exaerror.test_get_code()
    local msg = exaerror.create("E-FOOBAR-1")
    luaunit.assertEquals(msg:get_code(), "E-FOOBAR-1")
end

function test_exaerror.test_get_message()
    local msg = exaerror.create("E-FOOBAR-1", "This is a message.")
    luaunit.assertEquals(msg:get_message(), "This is a message.")
end

function test_exaerror.test_get_interpolated_message()
    local tests = {
        {message = "Foo '%s'", parameters = {"the a parameter"}, expected = "Foo 'the a parameter'"},
        {message = 'The %s is "%d".', parameters = {"answer", 42}, expected = 'The answer is "42".'}
    }
    for _, test in ipairs(tests) do
        local msg = exaerror.create("W-BARZOO-2", test.message, unpack(test.parameters))
        luaunit.assertEquals(msg:get_message(), test.expected)
    end
end

function test_exaerror.test_get_mitigations()
    local msg = exaerror.create("F-FOO-BAR-123"):add_mitigations("Do A.", "Don't do B.")
    luaunit.assertEquals(msg:get_mitigations(), "Do A.", "Don't do B.")
end

function test_exaerror.test_tostring_metamethod_with_code_only()
    local msg = exaerror.create("E-FOOBAR-1")
    luaunit.assertEquals(tostring(msg), "E-FOOBAR-1")
end

function test_exaerror.test_tostring_metamethod_with_message_only()
    local msg = exaerror:new({message = "Hello test!"})
    luaunit.assertEquals(tostring(msg), "Hello test!")
end

function test_exaerror.test_tostring_metamethod_with_mitigations_only()
    local msg = exaerror:new({mitigations = {"Turn off.", "Turn on again."}})
    luaunit.assertEquals(tostring(msg), [[
<Missing error message. This should not happen. Please contact the software maker.>

Mitigations:

* Turn off.
* Turn on again.]])
end

function test_exaerror.test_tostring_metamethod_with_undefined_error()
    local msg = exaerror.create()
    luaunit.assertEquals(tostring(msg),
        "<Missing error message. This should not happen. Please contact the software maker.>")
end

function test_exaerror.test_concatenation_metamethod()
    local err = exaerror.create("I-CONCAT-1")
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
    local msg = exaerror:new(
        {
            code = "SQL-1234",
            message = "Metadata query timed out after %d seconds.",
            parameters = {500},
            mitigations = {
                "Use lock-free metadata queries.",
                "Check for recursion."
            }
        }
    )
    luaunit.assertEquals(tostring(msg),
        [[SQL-1234: Metadata query timed out after 500 seconds.

Mitigations:

* Use lock-free metadata queries.
* Check for recursion.]])
end

function test_exaerror.test_embedding_in_lua_error()
    luaunit.assertErrorMsgContains(
        "E-IO-13: Need 500.2 MiB space, but only 14.8 MiB left on device /dev/sda4.",
        function ()
            error(exaerror.create("E-IO-13", "Need %.1f MiB space, but only %.1f MiB left on device %s.",
                500.2, 14.8, "/dev/sda4"))
        end
    )
end

function test_exaerror.test_throw_error_directly()
    luaunit.assertErrorMsgContains(
        "E-IO-13: Need 500.2 MiB space, but only 14.8 MiB left on device /dev/sda4.",
        function ()
            exaerror.error("E-IO-13", "Need %.1f MiB space, but only %.1f MiB left on device %s.",
                500.2, 14.8, "/dev/sda4")
        end
    )
end

function test_exaerror.test_throw_error_directly_with_mitigations()
    luaunit.assertErrorMsgContains(
        [[E-IO-13: Need 500.2 MiB space, but only 14.8 MiB left on device /dev/sda4.

Mitigations:

* Try #1.
* Or #2.]],
        function ()
            exaerror.error({
                code = "E-IO-13",
                message = "Need %.1f MiB space, but only %.1f MiB left on device %s.",
                parameters = {500.2, 14.8, "/dev/sda4"},
                mitigations = {"Try #1.", "Or #2."}
            })
        end
    )
end

os.exit(luaunit.LuaUnit.run())
