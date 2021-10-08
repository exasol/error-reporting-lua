---
-- This module provides a uniform way to define errors in a Lua application.
--
-- @module M
--
local M = {
    VERSION = "1.1.0",
}

local msgexpander = require("message_expander")

-- Lua 5.1 backward compatibility
_G.unpack = table.unpack or _G.unpack

local function expand(message, parameters)
    return msgexpander:new({message =message, parameters = parameters}):expand()
end

---
-- Convert error to a string representation.
-- <p>
-- Note that <code>__tostring</code> is the metamethod called by Lua's global <code>tostring</code> function.
-- This allows using the error message in places where Lua expects a string.
-- </p>
--
-- @return string representation of the error object
--
function M:__tostring()
    local lines = {}
    if self.code then
        if self.message then
            table.insert(lines, self.code .. ": " .. self:get_message())
        else
            table.insert(lines, self.code)
        end
    else
        if self.message then
            table.insert(lines, self:get_message())
        else
            table.insert(lines, "<Missing error message. This should not happen. Please contact the software maker.>")
        end
    end
    if (self.mitigations ~= nil) and (#self.mitigations > 0) then
        table.insert(lines, "\nMitigations:\n")
        for _, mitigation in ipairs(self.mitigations) do
            table.insert(lines, "* " .. expand(mitigation, self.parameters))
        end
    end
    return table.concat(lines, "\n")
end

---
-- Concatenate an error object with another object.
--
-- @return String representing the concatenation.
--
function M.__concat(left, right)
    return tostring(left) .. tostring(right)
end

---
-- Create a new instance of an error message.
--
-- @param object pre-initialized object to be used for the instance
--        (optional) a new object is created if you don't provide one
--
-- @return created object
--
function M:new(object)
    object = object or {}
    self.__index = self
    setmetatable(object, self)
    return object
end

---
-- Factory method for a new error message.
--
-- @param code error code
-- @param message message body
-- @param parameters parameters to replace the placeholders in the message (if any)
--
-- @return created object
--
function M.create(code, message, parameters)
    return M:new({code = code, message = message, parameters = parameters, mitigations = {}})
end

---
-- Add mitigations.
--
-- @param ... one or more mitigation descriptions
--
-- @return error message object
--
function M:add_mitigations(...)
    for _, mitigation in ipairs({...}) do
        table.insert(self.mitigations, mitigation)
    end
    return self
end

---
-- Add issue ticket mitigation
-- <p>
-- This is a special kind of mitigation which you should use in case of internal software errors that should not happen.
-- For example when a path in the code is reached that should be unreachable if the code is correct.
-- </p>
--
-- @return error message object
--
function M:add_ticket_mitigation()
    table.insert(self.mitigations,
        "This is an internal software error. Please report it via the project's ticket tracker.")
    return self
end


---
-- Get the error code.
--
-- @return error code
--
function M:get_code()
    return self.code
end

---
-- Get the error message.
-- <p>
-- This method supports Lua's standard string interpolation used in <code>string.format</code>.
-- Placeholders in the raw message are replaced by the parameters given when building the error message object.
-- </p>
-- <p>
-- For fault tolerance, this method returns the raw message in case the parameters are missing.
-- </p>
--
-- @return error message
--
function M:get_message()
    return expand(self.message, self.parameters)
end

function M:get_raw_message()
    return self.message or ""
end

---
-- Get parameter definitions.
--
function M:get_parameters()
    return self.parameters
end

---
-- Get the description of a parameter.
--
-- @parameter parameter_name name of the parameter
--
-- @return parameter description or the string "<code><missing parameter description></code>"
--
function M:get_parameter_description(parameter_name)
    return self.parameters[parameter_name].description or "<missing parameter description>"
end

---
-- Get the mitigations for the error.
--
-- @return list of mitigations
--
function M:get_mitigations()
    return unpack(self.mitigations)
end

---
-- Raise the error.
-- <p>
-- Like in Lua's <code>error</code> function, you can optionally specify if and from which level down the stack trace
-- is included in the error message.
-- </p>
-- <ul>
-- <li>0: no stack trace</li>
-- <li>1: stack trace starts at the point inside <code>exaerror</code> where the error is raised
-- <li>2: stack trace starts at the calling function (default)</li>
-- <li>3+: stack trace starts below the calling function</li>
-- </ul>
--
-- @parameter level (optional) level from which down the stack trace will be displayed
--
-- @raise Lua error for the given error object
--
function M:raise(level)
    level = (level == nil) and 2 or level
    error(tostring(self), level)
end

---
-- Raise an error that represents the error object's contents.
-- <p>
-- This function supports two calling styles. Either like <code>exaerror:create</code> with a flat list of parameters.
-- Or like <code>exaerror:new</code> with a table to preinitialize the error object.
-- </p>
-- <p>The first parameter decides on the calling convention. If it is a table, <code>exaerror:new</code is used.
--
-- @see M.create
-- @see M:new
--
-- @raise Lua error for the given error object
--
function M.error(arg1, ...)
    if type(arg1) == "table" then
        M:new(arg1):raise()
    else
        M.create(arg1, ...):raise()
    end
end

return M
