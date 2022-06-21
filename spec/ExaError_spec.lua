package.path = "src/?.lua;" .. package.path

require("busted.runner")()
local ExaError = require("ExaError")

describe("ExaError", function() 
    it("provides the error code", function() 
        local msg = ExaError:new("E-FOOBAR-1")
        assert.are.equals(msg:get_code(), "E-FOOBAR-1")
    end)

    it("provides a plain error message without parameters", function()
        local msg = ExaError:new("E-FOOBAR-1", "This is a message.")
        assert.are.equals(msg:get_message(), "This is a message.")
    end)

    it("replaces a single string parameter in the error message", function()
        local msg = ExaError:new("W-BARZOO-2", "Foo {{string}}", {string = "a text"})
        assert.are.equals(msg:get_message(), "Foo 'a text'")
    end)

    it("replaces a string parameter together with a number parameter in the error message", function()
        local msg = ExaError:new("W-BARZOO-2", 'The {{string}} is "{{number}}".', {string = "answer", number = 42})
        assert.are.equals(msg:get_message(), "The 'answer' is \"42\".")
    end)

    it("replaces a boolean parameter in the error message", function()
        local msg = ExaError:new("W-BARZOO-2", 'The result is {{bool}}.', {bool=true})
        assert.are.equals(msg:get_message(), "The result is true.")
    end)

    it("keeps the placeholder in the error message when the value is `nil`", function()
        local msg = ExaError:new("W-BARZOO-2", 'The result is {{value}}.', {value=nil})
        assert.are.equals(msg:get_message(), "The result is {{value}}.")
    end)

    it("replaces a float parameter in the error message", function()
        local msg = ExaError:new("W-BARZOO-2", 'The value of pi is {{pi}}.', {pi=3.14})
        assert.are.equals(msg:get_message(), "The value of pi is 3.14.")
    end)

    it("replaces a parameter provided in field `value` of a table in the error message", function()
        local msg = ExaError:new("W-BARZOO-2", 'The result is {{table}}.', {table={value="value"}})
        assert.are.equals(msg:get_message(), "The result is 'value'.")
    end)

    it("adds `<missing value>` to the message if the `value` field of the parameter definition table is missing",
            function()
                local msg = ExaError:new("W-BARZOO-2", 'The result is {{table}}.', {table={a=1}})
                assert.are.equals(msg:get_message(), "The result is <missing value>.")
            end
    )

    it("provides the description of a given parameter", function()
        local msg = ExaError:new("E-A-1", "A, {{b}}, {{c}}", {
                b = {value = "B", description = "the B"},
                c = {value = "C", description = "the C"}
            }
        )
        assert.are.equals(msg:get_parameter_description("c"), "the C")
    end)

    it("reports if the parameter the user request the description for is missing", function()
        local msg = ExaError:new("E-A-1", "A, {{b}}, {{c}}", {
                b = {value = "B"},
                c = {value = "C", description = "the C"}
            }
        )
        assert.are.equals(msg:get_parameter_description("b"), "<missing parameter description>")
    end)

    it("provides mitigations", function()
        local msg = ExaError:new("F-FOO-BAR-123"):add_mitigations("Do A.", "Don't do B.")
        assert.are.equals(msg:get_mitigations(), "Do A.", "Don't do B.")
    end)

    it("supports `tostring` with only the error code given", function()
        local msg = ExaError:new("E-FOOBAR-1")
        assert.are.equals(tostring(msg), "E-FOOBAR-1")
    end)

    it("supports `tostring` with only the error message given (fault tolerance)", function()
        local msg = ExaError:new(nil, "Hello test!")
        assert.are.equals(tostring(msg), "Hello test!")
    end)

    it("supports `tostring` with only mitigations given (fault tolerance)", function()
    local msg = ExaError:new(nil, nil, nil, {"Turn off.", "Turn on again."})
    assert.are.equals(tostring(msg), [[
<Missing error message. This should not happen. Please contact the software maker.>

Mitigations:

* Turn off.
* Turn on again.]])
    end)

    it("given an empty error object answers `tostring` with an error text", function()
        local msg = ExaError:new()
        assert.are.equals(tostring(msg),
            "<Missing error message. This should not happen. Please contact the software maker.>")
    end)

    it("supports `tostring` with only error code and mitigations", function()
        local msg = ExaError:new("Unexpected error.", nil, {url = "www.example.org/issues?create"},
                {"Please create an error report under {{url}}"})
        assert.are.equals(tostring(msg),
            [[Unexpected error.

Mitigations:

* Please create an error report under 'www.example.org/issues?create']])
    end)

    describe("supports Lua's concat method:", function()
        local err = ExaError:new("I-CONCAT-1")
        local tests = {
            {left = "left", right = err, expected = "leftI-CONCAT-1"},
            {left = 12345, right = err, expected = "12345I-CONCAT-1"},
            {left = err, right = "right", expected = "I-CONCAT-1right"},
            {left = err, right = 54321, expected = "I-CONCAT-154321"}
        }
        for _, test in ipairs(tests) do
            it(expected, function()
                local text = test.left .. test.right
                assert.are.equals(text, test.expected)
            end)
        end
    end)

    describe("supports `tostring` of a full error object with code, message, parameter and mitigations", function()
        local msg = ExaError:new("SQL-1234", "Metadata query timed out after {{timeout}} seconds.",
                {timeout = 500},
                {
                    "Use lock-free metadata queries.",
                    "Check for recursion."
                }
        )
        assert.are.equals(tostring(msg),
            [[SQL-1234: Metadata query timed out after 500 seconds.

Mitigations:

* Use lock-free metadata queries.
* Check for recursion.]])
    end)

    it("supports parameter descriptions", function()
        local msg = ExaError:new("SQL-2777", "Connection refused by host {{host}}" ,
            {host = {description = "Host or IP address", value = "jupiter.example.com"}})
        assert.are.equals(tostring(msg), "SQL-2777: Connection refused by host 'jupiter.example.com'")
        assert.are.same(msg:get_parameters(),
            {host = {description = "Host or IP address", value = "jupiter.example.com"}})
    end)

    it("embeds an error object into Lua's built-in `error` function", function()
        assert.has_error(
            function ()
                error(ExaError:new("E-IO-13", "Need {{needed}} MiB space, but only {{remaining}} MiB.",
                    {needed = 500.2, remaining = 14.8}))
            end,
            "E-IO-13: Need 500.2 MiB space, but only 14.8 MiB."
        )
    end)

    it("raises an error with code, message and parameters directly", function()
        assert.has_error(
            function ()
                ExaError.error("I-IO-1", "{{a}} down, {{b}} to go.", {a = 7, b = 4})
            end,
            "I-IO-1: 7 down, 4 to go."
        )
    end)

    it("raises an error with code, message, parameters and mitigation directly", function()
        assert.has_error(
            function ()
                ExaError.error(
                        "E-IO-13",
                        "Need {{needed}} MiB space, but only {{remaining}} MiB left on device {{device}}.",
                        {needed = 500.2, remaining = 14.8, device = "/dev/sda4"},
                        {"Try #1.", "Or #2."}
                )
            end,
            [[E-IO-13: Need 500.2 MiB space, but only 14.8 MiB left on device '/dev/sda4'.

Mitigations:

* Try #1.
* Or #2.]])
    end)

    it("supports adding a standard mitigation that asks the user to create an issue ticket", function()
        local err = ExaError:new("F-REQ-1", "Unsupported request type detected.")
                            :add_ticket_mitigation()
        assert.are.equals(tostring(err), [[F-REQ-1: Unsupported request type detected.

Mitigations:

* This is an internal software error. Please report it via the project's ticket tracker.]])
    end)

    local function nest_raise_call(level)
        ExaError:new("E-1", "Test stack trace levels"):raise(level)
    end

    it("removes the stack trace from the raised error when user sets level to zero", function()
        local err = ExaError:new("E-1: Test stack trace level 0")
        assert.has_error(function () err:raise(0) end,
                "E-1: Test stack trace level 0")
    end)

    it("starts the stack trace in the `ExaError` module when user sets the level to one", function()
        local err = ExaError:new("E-1: Test stack trace level 1")
        ok, result = pcall(function() err:raise(1) end)
        assert.falsy(ok)
        assert.matches(".*/ExaError%.lua:[0-9]+: E%-1: Test stack trace level 1", result)
    end)

    it("starts the stack trace in the module calling `ExaError` when user sets the level to two", function()
        local err = ExaError:new("E-1: Test stack trace level 2")
        local ok, result = pcall(function() err:raise(2) end)
        assert.is_false(ok)
        assert.matches(".*/ExaError_spec%.lua:[0-9]+: E%-1: Test stack trace level 2", result)
    end)

    it("uses the default stack trace report level of two", function()
        local err = ExaError:new("E-1: Test stack trace level 2")
        -- The following two calls need to in in the SAME line to produce the same line number in the error message!
        local ok_l2, res_l2 = pcall(function() err:raise(2) end); local ok, res = pcall(function() err:raise() end)
        assert.is_false(ok_l2)
        assert.is_false(ok)
        assert.are.equals(res_l2, res)
    end)
end)
