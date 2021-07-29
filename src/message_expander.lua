---
-- This module provides a parser for messages with named parameters and can expand the message using the parameter
-- values.
-- 
-- @module M 
--
local M = {}

local FROM_STATE_INDEX = 1
local GUARD_INDEX = 2
local ACTION_INDEX = 3
local TO_STATE_INDEX = 4

---
-- Create a new instance of a message expander.
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
    self.tokens_ = {}
    self.last_parameter_ = {characters = {}, quote = true}
    return object
end

---
-- Create new instance of a message expander.
--
-- @parameter message to be expanded
-- @parameter ... values used to replace the placeholders
--
function M.create(message, ...)
    return M:new({
        message = message,
        parameters = {...},
    })
end

local function tokenize(text)
    return string.gmatch(text, ".")
end

---
-- Expand the message.
-- <p>
-- Note that if no parameter values are supplied, the message will be returned as is, without any replacements.
-- </p>
--
-- @return expanded message
--
function M:expand()
    if (self.parameters == nil) or (not next(self.parameters)) then
        return self.message
    else
        self:run_()
    end
    return table.concat(self.tokens_)
end

function M:run_()
    self.state = "TEXT"
    local token_iterator = tokenize(self.message)
    for token in token_iterator do
        self.state = self:transit_(token)
    end
end

function M:transit_(token)
    for _, transition in ipairs(M.transitions_) do
        local from_state = transition[FROM_STATE_INDEX]
        local guard = transition[GUARD_INDEX]
        if(from_state == self.state and guard(token)) then
            local action = transition[ACTION_INDEX]
            action(self, token)
            local to_state = transition[TO_STATE_INDEX]
            return to_state
        end
    end
end

local function is_any()
    return true
end

local function is_opening_bracket(token)
    return token == "{"
end

local function is_closing_bracket(token)
    return token == "}"
end

local function is_pipe(token)

    return token == "|"
end

local function is_u (token)
    return token == "u"
end

local function is_not_bracket(token)
    return not is_opening_bracket(token) and not is_closing_bracket(token)
end

local function add_token(self, token)
    table.insert(self.tokens_, token)
end

local function add_open_plus_token(self, token)
    table.insert(self.tokens_, "{")
    table.insert(self.tokens_, token)
end

local function add_parameter_name(self, token)
    table.insert(self.last_parameter_.characters, token)
end

local function set_unquoted(self)
    self.last_parameter_.quote = false
end

local function unwrap_parameter_value(parameter)
    if parameter == nil then
        return "missing value"
    else
        local type = type(parameter)
        if (type == "table") then
            return parameter.value
        else
            return parameter
        end
    end
end

local function replace_parameter(self)
    local parameter_name = table.concat(self.last_parameter_.characters)
    local value = unwrap_parameter_value(self.parameters[parameter_name])
    local type = type(value)
    if (type == "string") and (self.last_parameter_.quote) then
        table.insert(self.tokens_, "'")
        table.insert(self.tokens_, value)
        table.insert(self.tokens_, "'")
    else
        table.insert(self.tokens_, value)
    end
    self.last_parameter_.characters = {}
    self.last_parameter_.quote = true
end

local function replace_and_add(self, token)
    replace_parameter(self)
    add_token(self, token)
end

local function do_nothing() end

M.transitions_ = {
    {"TEXT"     , is_not_bracket    , add_token          , "TEXT"     },
    {"TEXT"     , is_opening_bracket, do_nothing         , "OPEN_1"   },
    {"OPEN_1"   , is_opening_bracket, do_nothing         , "PARAMETER"},
    {"OPEN_1"   , is_any            , add_open_plus_token, "TEXT"     },
    {"PARAMETER", is_closing_bracket, do_nothing         , "CLOSE_1"  },
    {"PARAMETER", is_pipe           , do_nothing         , "SWITCH"   },
    {"PARAMETER", is_any            , add_parameter_name , "PARAMETER"},
    {"SWITCH"   , is_closing_bracket, do_nothing         , "CLOSE_1"  },
    {"SWITCH"   , is_u              , set_unquoted       , "SWITCH"   },
    {"SWITCH"   , is_any            , do_nothing         , "SWITCH"   },
    {"CLOSE_1"  , is_closing_bracket, replace_parameter  , "TEXT"     },
    {"CLOSE_1"  , is_any            , replace_and_add    , "TEXT"     }
}

return M
