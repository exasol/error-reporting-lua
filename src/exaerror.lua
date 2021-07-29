local M = {
    VERSION = "1.0.0",
}

local msgexpander = require("message_expander")

-- Lua 5.1 backward compatibility
_G.unpack = table.unpack or _G.unpack

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
            table.insert(lines, "* " .. mitigation)
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
function M:add_mitigations(...)
    for _, mitigation in ipairs({...}) do
        table.insert(self.mitigations, mitigation)
    end
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
    return msgexpander:new({message = self.message, parameters = self.parameters}):expand()
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
-- @return parameter description or <code>nil</code> if the description does not exist
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
--
-- @raise Lua error for the given error object
--
function M:raise()
    error(self)
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
