package.path = "src/?.lua;" .. package.path

require("busted.runner")()
local MessageExpander = require("MessageExpander")

local function assertMessageWithParametersRendersTo(message, parameters, expected)
    local expander = MessageExpander:new(message, parameters)
    assert.are.equals(expander:expand(), expected)
end

describe("MessageExpander", function()
    it("expands a message without parameter values", function()
        assertMessageWithParametersRendersTo("message with missing {{parameter}} values", nil,
                "message with missing {{parameter}} values")
    end)

    it("expands an auto-quoted string", function()
        assertMessageWithParametersRendersTo("before {{string}} after", {string = "replaced-string"},
                "before 'replaced-string' after")
    end)

    it("expands a boolean parameter", function()
        assertMessageWithParametersRendersTo("before {{value}} after", {value = true}, "before true after")
    end)

    it("expands an integer parameter", function()
        assertMessageWithParametersRendersTo("before {{value}} after", {value = 1234}, "before 1234 after")
    end)

    it("expands a float parameter", function()
        assertMessageWithParametersRendersTo("before {{value}} after", {value = 3.14}, "before 3.14 after")
    end)

    it("expands a table parameter", function()
        assertMessageWithParametersRendersTo("before {{a_table}} after", {a_table = {value = 1}}, "before 1 after")
    end)

    it("replaces missing parameter with `<missing value>` given a parameter list supplied", function()
        assertMessageWithParametersRendersTo("before {{value}} after",
                {something_else = "nevermind"}, "before <missing value> after")
    end)

    it("expands a message with an unquoted and quoted parameter", function()
        assertMessageWithParametersRendersTo('The {{string|u}} is "{{number}}".', {string = "answer", number = 42},
                'The answer is "42".')
    end)

    it("expands a parameter that is delimited by only one closing bracket (fault tolerance)", function()
        assertMessageWithParametersRendersTo("1 {{n} 3", {n = 2}, "1 2 3")
    end)

    it("expands a message that uses `uq` instead of a `u` switch (compatibility)", function()
        assertMessageWithParametersRendersTo("1 {{string|uq}} 3", {string = "s"}, "1 s 3")
    end)

    it("expands a message with a `u` switch", function()
        assertMessageWithParametersRendersTo("1 {{string|u}} 3", {string = "s"}, "1 s 3")
    end)

    it("expands a message where the parameter has a description", function()
        assertMessageWithParametersRendersTo("yesterday {{day}} tomorrow",
                {day = {value = "today", description = "current day"}},
                "yesterday 'today' tomorrow")
    end)

    it("replaces a missing parameter value with `<missing value>`", function()
        assertMessageWithParametersRendersTo("yesterday {{day}} tomorrow",
                {day = {description = "current day"}},
                "yesterday <missing value> tomorrow")

    end)
end)
